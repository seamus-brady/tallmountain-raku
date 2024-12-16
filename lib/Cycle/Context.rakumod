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
use Normative::Agent;
use Cycle::Buffer::Chat;

class Cycle::Context {
    # used to store useful information about a specific cognitive cycle

    has $.LOGGER = Util::Logger.new(namespace => "<Cycle::Context>");

    has Int $.index = 0;
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
        say "hello 2";
        self.LOGGER.debug("increment-index called");
        $.index++;
    }

    method reset-index() {
        self.LOGGER.debug("reset-index called");
        $.index = 0;
    }
}
