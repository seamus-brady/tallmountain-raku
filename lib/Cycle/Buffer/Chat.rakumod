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

    has Memory::ConversationBuffer $.message_buffer = Memory::ConversationBuffer.new();

    method messages {
        $.message_buffer.get_recent();
    }

    method add_message($message) {
        $.message_buffer.add_entry($message);
    }

    method add_user_message($user-request) {
        my $llm-messages = LLM::Messages.new();
        my %user-message = $llm-messages.build_user_prompt($user-request);
        $.message_buffer.add_entry(%user-message);
    }

    method add_assistant_message($assistant-response) {
        my $llm-messages = LLM::Messages.new();
        my %assistant-message = $llm-messages.build_assistant_prompt($assistant-response);
        $.message_buffer.add_entry(%assistant-message);
    }
}
