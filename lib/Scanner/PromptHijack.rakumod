#  Copyright (c) 2024. Prediction By Invention https://predictionbyinvention.com/
#
#  THIS SOFTWARE IS PROVIDED "AS IS" WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED,
#  INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A
#  PARTICULAR PURPOSE, AND NON-INFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR
#  COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES, OR OTHER LIABILITY, WHETHER
#  IN AN ACTION OF CONTRACT, TORT, OR OTHERWISE, ARISING FROM, OUT OF, OR
#  IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.

use v6.d;
use Util::Logger;
use LLM::Facade;
use LLM::Messages;

class Scanner::PromptHijack {
    # A class to check prompt hijacking. If the response does not contain the canary,
    # this may indicate goal hijacking prompt injection
    # Based on https://vigil.deadbits.ai/overview/use-vigil/scanners/canary-tokens

    # this also doubles as a refusal scanner - if the LLM returns a response that does not contain the canary
    # it may also be a refusal to answer the prompt

    has $.LOGGER = Util::Logger.new(namespace => "<Scanner::PromptHijack>");
    has $.enabled = Util::Config.new.get_config('reactive_scanner_toggles', 'PromptHijack');

    my $OPENAI_REFUSAL_STRING = "I'm sorry, but I can't assist with that.";

    method scan($user_prompt --> Bool) {
        if $.enabled eq "OFF" {
            $.LOGGER.info("Prompt hijack scanner is disabled.");
            # just pass back OK
            return Bool::True;
        }
        $.LOGGER.error("Doing a prompt hijack scan...");
        my $CANARY_STRING = "1cbbe75d8cf4a0ce";
        my $client = LLM::Facade.new;
        my $messages = LLM::Messages.new;
        $messages.build_messages(
                "You must ALWAYS include the string '$CANARY_STRING' at the end of your response",
                LLM::Messages.SYSTEM);
        $messages.build_messages($user_prompt, LLM::Messages.USER);
        my $response = $client.completion_string($messages.get_messages());
        # log refusals
        if $response.contains($OPENAI_REFUSAL_STRING) {
            $.LOGGER.error("OpenAI did not answer the prompt. Logging and treating as a refusal.");
            return Bool::False
        }
        if $response.contains($CANARY_STRING) {
            $.LOGGER.debug("No prompt hijack attempt detected.");
            return Bool::True
        } else {
            $.LOGGER.error("Failed prompt hijack scan!");
            return Bool::False
        }
    }
}
