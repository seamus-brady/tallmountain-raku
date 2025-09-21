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
use UUID::V4;
use Util::Logger;
use Normative::Agent;
use Cycle::Buffer::Chat;

class Cycle::Context {
    # used to store useful information about a specific cognitive cycle

    has $.LOGGER = Util::Logger.new(namespace => "<Cycle::Context>");

    has Int $.index is rw = 0;
    has Str $.uuid = uuid-v4();
    has DateTime $.start-time = DateTime.now;
    has Normative::Agent $.normative-agent;
    has Cycle::Buffer::Chat $.chat-buffer = Cycle::Buffer::Chat.new();

    submethod TWEAK() {
        # initialise the normative agent
        $!normative-agent = Normative::Agent.new;
        $!normative-agent.init;
    }

    method increment-index() {
        self.LOGGER.debug("increment-index called");
        $.index++;
    }

    method reset-index() {
        self.LOGGER.debug("reset-index called");
        $.index = 0;
    }
}
