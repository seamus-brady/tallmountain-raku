#  Copyright (c) 2024. Prediction By Invention https://predictionbyinvention.com/
#
#  THIS SOFTWARE IS PROVIDED "AS IS" WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED,
#  INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A
#  PARTICULAR PURPOSE, AND NON-INFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR
#  COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES, OR OTHER LIABILITY, WHETHER
#  IN AN ACTION OF CONTRACT, TORT, OR OTHERWISE, ARISING FROM, OUT OF, OR
#  IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.

use v6.d;
use UUID::V4;
use Util::Logger;
use Cycle::Payload::TaintedString;
use Cycle::Buffer::Chat;
use LLM::Messages;
use LLM::Facade;
use Normative::UserTask;

class Cycle::Cognitive {
    # Represents a single cognitive cycle for handling a prompt input.

    has $.LOGGER = Util::Logger.new(namespace => "<Cycle::Cognitive>");

    has Int $.index = 0;
    has Str $.uuid = uuid-v4();
    has DateTime $.start-time = DateTime.now;
    has LLM::Facade $.llm_client = LLM::Facade.new();
    has Cycle::Buffer::Chat $.chat-buffer = Cycle::Buffer::Chat.new();

    method increment-index() {
        self.LOGGER.debug("increment-index called");
        $!index++;
    }

    method reset-index() {
        self.LOGGER.debug("reset-index called");
        $!index = 0;
    }

    method run-one-cycle(Cycle::TaintedString $tainted-string) {
        self.increment-index();
        self.LOGGER.debug("Starting new cognitive cycle index for " ~ self.gist);
        # build a response
        self.chat-buffer.add-user-message($tainted-string.payload);
        my $user_task = Normative::UserTask.get-from-statement($tainted-string.payload);
        # my $response = $.llm_client.completion-string(self.chat-buffer.messages);
        self.chat-buffer.add-assistant-message($user_task.gist);
        return $user_task.gist;
    }

    method gist() {
        return "Cycle UUID: $.uuid, Current Index: $.index";
    }

}
