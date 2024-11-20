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

    method add-entry($entry) {
        self.buffer.push($entry);
    }

    method entries() {
        return self.buffer;
    }

    method get-last-n-entries(Int $n) {
        return self.buffer[* - $n .. *];
    }

    method get-recent() {
        my $n = RECENT_ENTRY_WINDOW;
        if self.buffer.elems >= $n {
            my @return = self.buffer[* - $n .. *];
            return @return.reverse;
        }
        # If fewer than $n messages, return all
        return self.buffer.reverse;
    }
}