use v6.d;
use LLM::Messages;
use Memory::ConversationBuffer;

class Cycle::Buffer::Chat {

    has Memory::ConversationBuffer $.message-buffer = Memory::ConversationBuffer.new();

    method as-llm-messages(--> LLM::Messages) {
        # convert to LLM::Messages, just a wrapper but useful
        my $llm-messages = LLM::Messages.new();
        $llm-messages.set-messages(self.messages());
        return $llm-messages;
    }

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
