use v6.d;
use Array::Circular;

class Memory::ConversationBuffer {
    #     A circular buffer with a fixed storage size where messages get "forgotten" after a few rounds of
    #    conversation. Only shows N number of entries when asked.

    # Constants
    constant INITIAL_SIZE = 30;
    constant RECENT_ENTRY_WINDOW = 15;

    # Attributes
    has Int $.size;
    has @.buffer;

    submethod TWEAK {
        my @temp is circular(INITIAL_SIZE);
        self.buffer = @temp;
    }

    method add-entry(Str $entry) {
        self.buffer.push($entry);
    }

    method get-last-n-entries(Int $n) {
        return self.buffer[* - $n .. *];
    }

    method get-recent() {
        my $n = RECENT_ENTRY_WINDOW;
        return self.buffer[* - $n .. *];
    }
}