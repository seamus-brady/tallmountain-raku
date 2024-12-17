#  Copyright (c) 2024. Prediction By Invention https://predictionbyinvention.com/
#
#  THIS SOFTWARE IS PROVIDED "AS IS" WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED,
#  INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A
#  PARTICULAR PURPOSE, AND NON-INFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR
#  COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES, OR OTHER LIABILITY, WHETHER
#  IN AN ACTION OF CONTRACT, TORT, OR OTHERWISE, ARISING FROM, OUT OF, OR
#  IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.

use v6.d;
use Array::Circular;
use Util::Config;

class Memory::ConversationBuffer {
    #     A circular buffer with a fixed storage size where messages get "forgotten" after a few rounds of
    #    conversation. Only shows N number of entries when asked.

    # max size of the buffer
    constant INITIAL_SIZE = 30;

    # how many recent entries to show
    constant RECENT_ENTRY_WINDOW = 15;

    # circular array to store the messages
    has @.buffer;

    submethod TWEAK {
        my @temp is circular(INITIAL_SIZE);
        self.buffer = @temp;
    }

    method add_entry($entry) {
        self.buffer.push($entry);
    }

    method entries() {
        return self.buffer;
    }

    method get_last_n_entries(Int $n) {
        return self.buffer[* - $n .. *];
    }

    method get_recent() {
        my $n = RECENT_ENTRY_WINDOW;
        return self.buffer[* - $n .. *] if self.buffer.elems >= $n;
        return self.buffer; # If fewer than $n messages, return all
    }
}