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

    my $.ASSISTANT = 'assistant';
    my $.USER      = 'user';
    my $.SYSTEM    = 'system';

    has $.LOGGER = Util::Logger.new(namespace => "<LLMMessages>");

    has @!messages;

    method get-messages() {
        return @!messages
    }

    method set-messages(@new-messages) {
        @!messages = @new-messages>>.clone;
    }

    method build-user-prompt(Str $content) {
        return { role => 'user', content => $content };
    }

    method build-assistant-prompt(Str $content) {
        return { role => 'assistant', content => $content };
    }

    method build-system-prompt(Str $content) {
        return { role => 'system', content => $content };
    }

    method build-tool-prompt(Any $tool-call, Str $function-name, Str $content) {
        return {
            tool_call_id => $tool-call.id,
            role         => 'tool',
            name         => $function-name,
            content      => $content
        };
    }

    method build-messages(Str $content, Str $type) {
        try {
            my %message;
            if $type eq LLM::Messages.SYSTEM {
                say "Building system prompt";
                %message = self.build-system-prompt($content);
            }
            elsif $type eq LLM::Messages.USER {
                %message = self.build-user-prompt($content);
            }
            elsif $type eq LLM::Messages.ASSISTANT {
                %message = self.build-assistant-prompt($content);
            }
            @!messages.push(%message) if %message;
            return self;
        }
        CATCH {
            default {
                self.LOGGER.error($_.message);
                die X::TallMountain::LLMException.new(message => $_.message);
            }
        }
    }
}

class X::TallMountain::LLMException is Exception {
    has Str $.message;
}