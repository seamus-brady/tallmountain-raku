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
use Util::Config;
use Cycle::Context;
use Cycle::Payload::TaintedString;
use Cycle::Payload::OkString;
use Cycle::Buffer::Chat;
use Cycle::Stage::Reactive;
use Cycle::Stage::ReactiveScan;
use Cycle::Stage::EarlyExit;
use Cycle::Stage::ReactiveReturn;
use Cycle::Stage::Deliberative;
use LLM::Messages;
use LLM::Facade;
use LLM::AdaptiveRequestMode;
use Normative::UserTask;
use Normative::Agent;
use Normative::Analysis::RiskProfile;
use Normative::Analysis::RiskProfileRunner;
use Normative::Analysis::RiskAnalyser;

# exception class for cognitive cycle error
class Cycle::CognitiveCycleException is Exception {
    has Str $.message;
}


class Cycle::Cognitive {
    # Represents a single cognitive cycle for handling a prompt input.

    has $.LOGGER = Util::Logger.new(namespace => "<Cycle::Cognitive>");
    has Cycle::Context $.context;
    has Cycle::Stage::Reactive $.reactive-stage;

    submethod TWEAK() {
        # initialise the cycle context
        $!context = Cycle::Context.new();
        # set up the stages
        $!reactive-stage = Cycle::Stage::Reactive.new(normative-agent => $!context.normative-agent);
    }

    method increment-index() {
        $.context.increment-index;
    }

    method reset-index() {
        $.context.reset-index;
    }

    method index() {
        return $.context.index;
    }

    method uuid() {
        return $.context.uuid;
    }
    
    method run-one-cycle(Cycle::Payload::TaintedString $tainted-string) {
        try {
            self.increment-index();

            self.LOGGER.debug("Starting new cognitive cycle index for " ~ self.gist);

            # run the reactive stage, it only looks at the incoming string from the user
            my Cycle::Stage::ReactiveReturn $reactive-return = $.reactive-stage.run($tainted-string);

            if $reactive-return ~~ Cycle::Stage::EarlyExit {
                # the reactive stage has decided to exit early, handle it
                return self.handle-reactive-early-exit($reactive-return);
            }

            # reactive stage passed OK, now run the deliberative stage
            if $reactive-return ~~ Cycle::Stage::ReactiveScan {
                self.LOGGER.debug("Reactive scan result: " ~ $reactive-return.gist);

                # add the user message to the chat buffer using an OKString
                my Cycle::Payload::OkString $ok-string = Cycle::Payload::OkString.new(
                        payload => $tainted-string.payload
                );
                self.chat-buffer.add-user-message($ok-string.payload);
                my $response = $.llm_client.completion-string(self.chat-buffer.messages);
                self.chat-buffer.add-assistant-message($response);
                return $response;
            } else {
                my Str $message = "Exiting cycle as unknown return from reactive stage: " ~ $reactive-return.gist;
                self.LOGGER.error($message);
                Cycle::CognitiveCycleException.new(message => $message).throw;
            }

        }
        CATCH {
            my $error = $_;
            self.LOGGER.error("Exception caught in cognitive cycle index {self.context.index}: $error");
            my Str $error_response = "Sorry there was an error processing your request. Please try again.";
            self.chat-buffer.add-assistant-message($error_response);
            return $error_response;
        }
    }

    method handle-reactive-early-exit(Cycle::Stage::EarlyExit $early-exit --> Str){
        self.LOGGER.debug("Exiting early due to prompt attack or LLM refusal: " ~ $early-exit.exit-details);
        self.chat-buffer.add-user-message($early-exit.user-message);
        self.chat-buffer.add-assistant-message($early-exit.ai-message);
        return $early-exit.ai-message;
    }

    method gist() {
        return "Cycle UUID: $.uuid, Current Index: $.index";
    }

}
