#  Copyright (c) 2024. Prediction By Invention https://predictionbyinvention.com/
#
#  THIS SOFTWARE IS PROVIDED "AS IS" WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED,
#  INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A
#  PARTICULAR PURPOSE, AND NON-INFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR
#  COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES, OR OTHER LIABILITY, WHETHER
#  IN AN ACTION OF CONTRACT, TORT, OR OTHERWISE, ARISING FROM, OUT OF, OR
#  IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.

use v6.d;
use LLM::Messages;
use Memory::ConversationBuffer;

class Cycle::Buffer::Chat {

    has Memory::ConversationBuffer $.message-buffer = Memory::ConversationBuffer.new();

    method messages {
        $.message-buffer.get-recent();
    }

    method add-message($message) {
        $.message-buffer.add-entry($message);
    }

    method add-user-message($user-request) {
        my $llm-messages = LLM::Messages.new();
        my %user-message = $llm-messages.build-user-prompt($user-request);
        $.message-buffer.add-entry(%user-message);
    }

    method add-assistant-message($assistant-response) {
        my $llm-messages = LLM::Messages.new();
        my %assistant-message = $llm-messages.build-assistant-prompt($assistant-response);
        $.message-buffer.add-entry(%assistant-message);
    }
}
