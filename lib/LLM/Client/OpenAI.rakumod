#  Copyright (c) 2024. Prediction By Invention https://predictionbyinvention.com/
#
#  THIS SOFTWARE IS PROVIDED "AS IS" WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED,
#  INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A
#  PARTICULAR PURPOSE, AND NON-INFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR
#  COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES, OR OTHER LIABILITY, WHETHER
#  IN AN ACTION OF CONTRACT, TORT, OR OTHERWISE, ARISING FROM, OUT OF, OR
#  IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.

use v6.d;
use HTTP::Tinyish;
use JSON::Fast;
use Util::DotEnv;
use Util::Logger;
use Util::Config;
use LLM::Role::Client;
use LLM::AdaptiveRequestMode;
use LLM::Messages;
use LLM::Util::Instructor;

# load openai key from .env, if available

Util::DotEnv.load_env_file();

# exception class for OpenAI API errors
class LLM::Client::OpenAIException is Exception {
	has Str $.message;
}

class LLM::Client::OpenAI does LLM::Role::Client {
	has Str $.api-key = %*ENV{"OPENAI_API_KEY"};
	has Str $.api-url = "https://api.openai.com/v1/chat/completions";
	has Str $.model = Util::Config.get_config('openai', 'openai_chat_completion_model');

	has $.LOGGER = Util::Logger.new(namespace => "<LLM::Client::OpenAI>");


	method completion_string(
				@messages is copy,
				LLM::AdaptiveRequestMode $mode = LLM::AdaptiveRequestMode.balanced_mode
				--> Str) {

		self.LOGGER.debug("completion-string starting...");

		my $client = HTTP::Tinyish.new;

		# Prepare the payload for the OpenAI API
		my %payload = (
		model => $.model,
		messages => @messages,
		temperature => $mode.temperature,
		max_tokens => $mode.max_tokens,
		);

		# Prepare headers with API key for authorization
		my %headers = (
			"Content-Type" => "application/json",
			"Authorization" => "Bearer " ~ $.api-key
		);

		# Send a POST request with the JSON-encoded payload
		my $response = $client.post(
            $.api-url,
            headers => %headers,
            content => to-json(%payload)
        );

		# Handle the response
		if $response<success> {
			my %result = from-json($response<content>);
			return %result<choices>[0]<message><content>;
		}
		else {
			my Str $message = "Error: { $response<status> } - { $response<reason> }";
			self.LOGGER.error($message);
			LLM::Client::OpenAIException.new(message => $message).throw;
		}
	}

	method completion_structured_output(
			@messages is copy,
			Str $xml_schema is copy,
			Str $xml_example is copy,
			LLM::AdaptiveRequestMode $mode = LLM::AdaptiveRequestMode.balanced_mode
			--> Hash) {
		# calls the inner logic to get the structured output in xml format
		# repeats n times if the output is not valid xml and then dies
		# returns a Raku hash

		self.LOGGER.debug("completion_structured_output starting...");
		my $instructor_util = LLM::Util::Instructor.new;
		my $xml_output;
		my $attempts = 0;
		my $allowed_attempts = Util::Config.get_config('openai', 'openai_structured_output_attempts');

		# Validate XML example against XML schema
		unless $instructor_util.is_valid_xml($xml_example, $xml_schema) {
			my Str $message = "Error: Provided XML example is not valid according to the XML schema!";
			self.LOGGER.error($message);
			LLM::Client::OpenAIException.new(message => $message).throw;
		}

		while $attempts <  $allowed_attempts {
			self.LOGGER.debug("completion_structured_output starting attempt number $attempts...");
			$xml_output = self.completion_structured_output_as_xml(@messages, $xml_schema, $xml_example, $mode);
			if $instructor_util.is_valid_xml($xml_output, $xml_schema) {
				return $instructor_util.hash_from_xml($xml_output);
			}
			$attempts++;
		}

		my Str $message = "Error: unable to get structured output in alloted number of attempts!";
		self.LOGGER.error($message);
		LLM::Client::OpenAIException.new(message => $message).throw;
	}

	method completion_structured_output_as_xml(
			@messages is copy,
			Str $xml_schema is copy,
			Str $xml_example is copy,
			LLM::AdaptiveRequestMode $mode = LLM::AdaptiveRequestMode.balanced_mode
			--> Str) {

		self.LOGGER.debug("completion_structured_output_xml starting...");

		my Str $prompt-string = self.get_completion_prompt(@messages, $xml_schema, $xml_example);

		my $xml_messages = LLM::Messages.new;
		$xml_messages.build_messages('You are an expert in xml data extraction.', LLM::Messages.SYSTEM);
		$xml_messages.build_messages($prompt-string, LLM::Messages.USER);

		my $client = HTTP::Tinyish.new;

		# Prepare the payload for the OpenAI API
		my %payload = (
		model => $.model,
		messages => $xml_messages.get_messages,
		temperature => $mode.temperature,
		max_tokens => $mode.max_tokens,
		);

		# Prepare headers with API key for authorization
		my %headers = (
		"Content-Type" => "application/json",
		"Authorization" => "Bearer " ~ $.api-key
		);

		# Send a POST request with the JSON-encoded payload
		my $response = $client.post(
				$.api-url,
				headers => %headers,
				content => to-json(%payload)
				);

		# Handle the response
		if $response<success> {
			my %result = from-json($response<content>);
			my $message_content = %result<choices>[0]<message><content>;
			my $instructor_util = LLM::Util::Instructor.new;
			my $xml_output = $instructor_util.remove_code_block_markers($message_content)
					andthen $instructor_util.strip_xml_declaration($xml_output);
			return $xml_output;
		}
		else {
			my Str $message = "Error: { $response<status> } - { $response<reason> }";
			self.LOGGER.error($message);
			LLM::Client::OpenAIException.new(message => $message).throw;
		}
	}

	method get_completion_prompt(
			@messages is copy,
			Str $xml_schema is copy,
			Str $xml_example is copy --> Str){

		# formats the completion prompt for structured output

		my Str $conversation_context = @messages.gist;
		my Str $prompt_string = qq:to/END/;
		=== TASK ===

		- Your task is to extract the correct information from the conversation context below.
		- You must provided the structured output in XML format using the xml-schema provided.
		- You are also provided with an example of the expected output in xml.
		- You must escape any strings embedded in the XML output as follows:
				' is replaced with &apos;
				" is replaced with &quot;
				& is replaced with &amp;
				< is replaced with &lt;
				> is replaced with &gt;
		- Your output must be valid XML.

		=== START CONVERSATION CONTEXT ===
		$conversation_context
		=== END CONVERSATION CONTEXT ===

		=== START XML SCHEMA ===
		$xml_schema
		=== END XML SCHEMA ===

		=== START XML EXAMPLE ===
		$xml_example
		=== END XML EXAMPLE ===

		END

		return $prompt_string.trim;
	}
}

