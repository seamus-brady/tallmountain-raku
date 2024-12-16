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
use Util::Config;
use Cycle::Payload::TaintedString;
use Cycle::Payload::OkString;
use Cycle::Buffer::Chat;
use Cycle::Stage::Reactive;
use Cycle::Stage::ReactiveScan;
use Cycle::Stage::EarlyExit;
use Cycle::Stage::ReactiveReturn;
use LLM::Messages;
use LLM::Facade;
use LLM::AdaptiveRequestMode;
use Normative::UserTask;
use Normative::Agent;
use Normative::Analysis::RiskProfile;
use Normative::Analysis::RiskProfileRunner;
use Normative::Analysis::RiskAnalyser;



class Cycle::Cognitive {
    # Represents a single cognitive cycle for handling a prompt input.

    has $.LOGGER = Util::Logger.new(namespace => "<Cycle::Cognitive>");

    has Int $.index = 0;
    has Str $.uuid = uuid-v4();
    has DateTime $.start-time = DateTime.now;
    has LLM::Facade $.llm_client = LLM::Facade.new();
    has Cycle::Buffer::Chat $.chat-buffer = Cycle::Buffer::Chat.new();
    has Normative::Agent $.normative-agent;
    has Cycle::Stage::Reactive $.reactive-stage;

    submethod TWEAK() {
        # initialise the normative agent
        $!normative-agent = Normative::Agent.new;
        $!normative-agent.init;
        # set up the stages
        $!reactive-stage = Cycle::Stage::Reactive.new(normative-agent => $!normative-agent);
    }

    method increment-index() {
        self.LOGGER.debug("increment-index called");
        $!index++;
    }

    method reset-index() {
        self.LOGGER.debug("reset-index called");
        $!index = 0;
    }

    method run-one-cycle(Cycle::Payload::TaintedString $tainted-string) {
        try {
            self.increment-index();
            self.LOGGER.debug("Starting new cognitive cycle index for " ~ self.gist);

            # run the reactive stage
            my Cycle::Stage::ReactiveReturn $reactive-return = $.reactive-stage.run($tainted-string);

            # scan finds a prompt based attack - handle it
            if $reactive-return ~~ Cycle::Stage::EarlyExit {
                return self.handle-reactive-early-exit($reactive-return);
            }

            # scan is OK
            if $reactive-return ~~ Cycle::Stage::ReactiveScan {
                self.LOGGER.debug("Reactive scan result: " ~ $reactive-return.gist);
            }

            # add the user message to the chat buffer using an OKString
            my Cycle::Payload::OkString $ok-string = Cycle::Payload::OkString.new(payload => $tainted-string.payload);
            self.chat-buffer.add-user-message($tainted-string.payload);
            my $response = $.llm_client.completion-string(self.chat-buffer.messages);
            self.chat-buffer.add-assistant-message($response);
            return $response;
        }
        CATCH {
            my $error = $_;
            self.LOGGER.error("Exception caught in cognitive cycle index {self.index}: $error");
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
