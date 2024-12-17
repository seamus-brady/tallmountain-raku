#  Copyright (c) 2024. Prediction By Invention https://predictionbyinvention.com/
#
#  THIS SOFTWARE IS PROVIDED "AS IS" WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED,
#  INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A
#  PARTICULAR PURPOSE, AND NON-INFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR
#  COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES, OR OTHER LIABILITY, WHETHER
#  IN AN ACTION OF CONTRACT, TORT, OR OTHERWISE, ARISING FROM, OUT OF, OR
#  IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.

use v6.d;
use Util::Config;
use LLM::Role::Client;
use LLM::Client::OpenAI;
use LLM::AdaptiveRequestMode;

class LLM::Facade {
    # calls the default LLM provider

    has Str $.default_client = Util::Config.get_config('llm', 'default_llm_provider');
    has LLM::Role::Client $.client;

    has $.LOGGER = Util::Logger.new(namespace => "<LLM::Facade>");

    submethod TWEAK() {
        given $!default_client {
            when "open_ai" {
                $!LOGGER.info("Using OpenAI as the default provider");
                $!client = LLM::Client::OpenAI.new();
            }
            default {
                # OpenAI is the default provider :)
                $!LOGGER.info("Using OpenAI as the default provider");
                $!client = LLM::Client::OpenAI.new();
            }
        }
    }

    method completion_string(
            @messages,
            LLM::AdaptiveRequestMode $mode = LLM::AdaptiveRequestMode.balanced_mode
            --> Str) {
            return $.client.completion_string(@messages, $mode);
    }

    method completion_structured_output(
            @messages is copy,
            Str $xml_schema is copy,
            Str $xml_example is copy,
            LLM::AdaptiveRequestMode $mode = LLM::AdaptiveRequestMode.balanced_mode
            --> Hash) {
            return $.client.completion_structured_output(@messages, $xml_schema, $xml_example, $mode);
    }
}