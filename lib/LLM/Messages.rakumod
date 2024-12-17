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

class LLM::Messages {

    our $.ASSISTANT = 'assistant';
    our $.USER      = 'user';
    our $.SYSTEM    = 'system';

    has $.LOGGER = Util::Logger.new(namespace => "<LLM::Messages>");

    has @!messages;

    method get_messages() {
        return @!messages
    }

    method set_messages(@new-messages) {
        @!messages = @new-messages>>.clone;
    }

    method build_user_prompt(Str $content) {
        return { role => 'user', content => $content };
    }

    method build_assistant_prompt(Str $content) {
        return { role => 'assistant', content => $content };
    }

    method build_system_prompt(Str $content) {
        return { role => 'system', content => $content };
    }

    method build_tool_prompt(Any $tool_call, Str $function_name, Str $content) {
        return {
            tool_call_id => $tool_call.id,
            role         => 'tool',
            name         => $function_name,
            content      => $content
        };
    }

    method build_messages(Str $content, Str $type) {
        my %message;
        if $type eq LLM::Messages.SYSTEM {
            %message = self.build_system_prompt($content);
        }
        elsif $type eq LLM::Messages.USER {
            %message = self.build_user_prompt($content);
        }
        elsif $type eq LLM::Messages.ASSISTANT {
            %message = self.build_assistant_prompt($content);
        }
        @!messages.push(%message) if %message;
        return self;
    }
}
