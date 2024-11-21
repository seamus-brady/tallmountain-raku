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


	method completion-string(
			    LLM::Messages $messages is copy,
				LLM::AdaptiveRequestMode $mode = LLM::AdaptiveRequestMode.balanced-mode
				--> Str) {

		self.LOGGER.debug("completion-string starting...");

		my $client = HTTP::Tinyish.new;

		# Prepare the payload for the OpenAI API
		my %payload = (
			model => $.model,
			messages => $messages.get-messages,
			temperature => $mode.temperature,
			max_tokens => $mode.max-tokens,
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
			self.LOGGER.error($response);
			LLM::Client::OpenAIException.new(message => $message).throw;
		}
	}


	method completion-tools(
			LLM::Messages $messages is copy,
			Str $tools is copy;
			Str $tool-choice = "auto",
			LLM::AdaptiveRequestMode $mode = LLM::AdaptiveRequestMode.balanced-mode()
			--> Any) {

		self.LOGGER.debug("completion-tool starting...");

		my $client = HTTP::Tinyish.new;
		my Str $json-messages = $messages.to-json;

		my $payload = q:to/END/;
		{
		  "messages":
		END
		$payload = $payload ~ $json-messages ~ ",\n";
		$payload = $payload ~ $tools;
		$payload = $payload  ~ "\"tool_choice\": \"$tool-choice\",\n";
		$payload = $payload  ~ "\"temperature\": $mode.temperature(),\n";
		$payload = $payload  ~ "\"top_p\": $mode.top-p(),\n";
		$payload = $payload  ~ "\"model\": \"$.model\"\n}";

		# Prepare headers with API key for authorization
		my %headers = (
		"Content-Type" => "application/json",
		"Authorization" => "Bearer " ~ $.api-key
		);

		# Send a POST request with the JSON-encoded payload
		my $response = $client.post(
				$.api-url,
				headers => %headers,
				content => $payload
				);

		# Handle the response
		if $response<success> {
			my %result = from-json($response<content>);
			return %result;
		}
		else {
			my Str $message = "Error: { $response<status> } - { $response<reason> }";
			self.LOGGER.error($message);
			self.LOGGER.error("OpenAI API response:\n$response ");
			LLM::Client::OpenAIException.new(message => $message).throw;
		}
	}


	method completion-structured-output(
			LLM::Messages $messages is copy,
			Str $xml-schema is copy,
			Str $xml-example is copy,
			LLM::AdaptiveRequestMode $mode = LLM::AdaptiveRequestMode.balanced-mode
			--> Hash) {
		# calls the inner logic to get the structured output in xml format
		# repeats n times if the output is not valid xml and then dies
		# returns a Raku hash

		self.LOGGER.debug("completion-structured-output starting...");
		my $instructor-util = LLM::Util::Instructor.new;
		my $xml-output;
		my $attempts = 0;
		my $allowed_attempts = Util::Config.get_config('openai', 'openai_structured_output_attempts');

		# Validate XML example against XML schema
		unless $instructor-util.is-valid-xml($xml-example, $xml-schema) {
			my Str $message = "Error: Provided XML example is not valid according to the XML schema!";
			self.LOGGER.error($message);
			LLM::Client::OpenAIException.new(message => $message).throw;
		}

		while $attempts <  $allowed_attempts {
			self.LOGGER.debug("completion-structured-output starting attempt number $attempts...");
			$xml-output = self.completion-structured-output-as-xml($messages, $xml-schema, $xml-example, $mode);
			if $instructor-util.is-valid-xml($xml-output, $xml-schema) {
				return $instructor-util.hash-from-xml($xml-output);
			}
			$attempts++;
		}

		my Str $message = "Error: unable to get structured output in alloted number of attempts!";
		self.LOGGER.error($message);
		LLM::Client::OpenAIException.new(message => $message).throw;
	}

	method completion-structured-output-as-xml(
			LLM::Messages $messages is copy,
			Str $xml-schema is copy,
			Str $xml-example is copy,
			LLM::AdaptiveRequestMode $mode = LLM::AdaptiveRequestMode.balanced-mode
			--> Str) {

		self.LOGGER.debug("completion-structured-output-xml starting...");

		my Str $prompt-string = self.get-completion-prompt($messages.get-messages, $xml-schema, $xml-example);

		my $xml-messages = LLM::Messages.new;
		$xml-messages.build-messages('You are an expert in xml data extraction.', LLM::Messages.SYSTEM);
		$xml-messages.build-messages($prompt-string, LLM::Messages.USER);

		my $client = HTTP::Tinyish.new;

		# Prepare the payload for the OpenAI API
		my %payload = (
			model => $.model,
			messages => $xml-messages.get-messages,
			temperature => $mode.temperature,
			max_tokens => $mode.max-tokens,
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
			my $message-content = %result<choices>[0]<message><content>;
			my $instructor-util = LLM::Util::Instructor.new;
			my $xml-output = $instructor-util.remove-code-block-markers($message-content)
					andthen $instructor-util.strip-xml-declaration($xml-output);
			return $xml-output;
		}
		else {
			my Str $message = "Error: { $response<status> } - { $response<reason> }";
			self.LOGGER.error($message);
			LLM::Client::OpenAIException.new(message => $message).throw;
		}
	}

	method get-completion-prompt(
			@messages is copy,
			Str $xml-schema is copy,
			Str $xml-example is copy --> Str){

		# formats the completion prompt for structured output

		my Str $conversation-context = @messages.gist;
		my Str $prompt-string = qq:to/END/;
		=== TASK ===

		- Your task is to extract the correct information from the conversation context below.
		- You must provided the structured output in XML format using the xml-schema provided.
		- You are also provided with an example of the expected output in xml.


		=== START CONVERSATION CONTEXT ===
		$conversation-context
		=== END CONVERSATION CONTEXT ===

		=== START XML SCHEMA ===
		$xml-schema
		=== END XML SCHEMA ===

		=== START XML EXAMPLE ===
		$xml-example
		=== END XML EXAMPLE ===

		END

		return $prompt-string.trim;
	}
}

