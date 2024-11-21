use v6.d;
use UUID::V4;
use Util::Logger;
use Cycle::Payload::TaintedString;
use Cycle::Buffer::Chat;
use LLM::Messages;
use LLM::Facade;

class Cycle::Cognitive {
    # Represents a single cognitive cycle for handling a prompt input.

    has $.LOGGER = Util::Logger.new(namespace => "<Cycle::Cognitive>");

    has Int $.index = 0;
    has Str $.uuid = uuid-v4();
    has DateTime $.start-time = DateTime.now;
    has LLM::Facade $.llm_client = LLM::Facade.new();
    has Cycle::Buffer::Chat $.chat-buffer = Cycle::Buffer::Chat.new();

    method increment-index() {
        self.LOGGER.debug("increment-index called");
        $!index++;
    }

    method reset-index() {
        self.LOGGER.debug("reset-index called");
        $!index = 0;
    }

    method run-one-cycle(Cycle::TaintedString $tainted-string) {
        self.increment-index();
        self.LOGGER.debug("Starting new cognitive cycle index for " ~ self.gist);
        # build a response
        self.chat-buffer.add-user-message($tainted-string.payload);
        my $response = $.llm_client.completion-string(self.chat-buffer.as-llm-messages);
        self.chat-buffer.add-assistant-message($response);
        return $response;
    }

    method gist() {
        return "Cycle UUID: $.uuid, Current Index: $.index";
    }

}
