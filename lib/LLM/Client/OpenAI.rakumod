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
				@messages,
				LLM::AdaptiveRequestMode $mode = LLM::AdaptiveRequestMode.balanced-mode
				--> Str) {
		my $client = HTTP::Tinyish.new;

		self.LOGGER.debug("completion-string starting...");

		# Prepare the payload for the OpenAI API
		my %payload = (
			model => $.model,
			messages => @messages,
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
			LLM::Client::OpenAIException.new(message => $message).throw;
		}
	}
}

