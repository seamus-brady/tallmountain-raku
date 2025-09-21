#  MIT License
#  
#  Copyright (c) 2024 seamus@corvideon.ie
#  
#  Permission is hereby granted, free of charge, to any person obtaining a copy
#  of this software and associated documentation files (the "Software"), to deal
#  in the Software without restriction, including without limitation the rights
#  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
#  copies of the Software, and to permit persons to whom the Software is
#  furnished to do so, subject to the following conditions:
#  
#  The above copyright notice and this permission notice shall be included in all
#  copies or substantial portions of the Software.
#  
#  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
#  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
#  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
#  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
#  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
#  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
#  SOFTWARE.

use v6.d;
use Util::Logger;

class LLM::Messages {

    our $.ASSISTANT = 'assistant';
    our $.USER      = 'user';
    our $.SYSTEM    = 'system';

    has $.LOGGER = Util::Logger.new(namespace => "<LLM::Messages>");

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
        my %message;
        if $type eq LLM::Messages.SYSTEM {
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
}
