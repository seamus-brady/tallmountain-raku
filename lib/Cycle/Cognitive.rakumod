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
    has Normative::Agent $.np-agent;

    submethod TWEAK() {
        # initialise the normative agent
        $!np-agent = Normative::Agent.new;
        $!np-agent.init;
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
        self.increment-index();

        # Start timer
        my $start-time = now;

        self.LOGGER.debug("Starting new cognitive cycle index for " ~ self.gist);

        # run the reactive stage
        my Cycle::Stage::ReactiveReturn $reactive-return = Cycle::Stage::Reactive.new().run($tainted-string);

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

        # run the normative risk check
        my $user_task = Normative::UserTask.new.get-from-statement($ok-string.payload.trim);
        my Normative::Analysis::RiskProfileRunner $norm-risk-profiler = Normative::Analysis::RiskProfileRunner.new;
        my Normative::Analysis::RiskProfile $risk-profile = $norm-risk-profiler.profile($user_task, $.np-agent);
        my $analysis = Normative::Analysis::RiskAnalyser.new(risk-profile => $risk-profile);
        my $recommendation = $analysis.recommend;
        if $recommendation eq Normative::Analysis::RiskAnalyser::ACCEPT_AND_EXECUTE {
            # all good, accept and execute

            # End timer
            my $end-time = now;
            my $elapsed-time = $end-time - $start-time;

            $!LOGGER.debug("Risk profile run elapsed time: $elapsed-time seconds");
            my $response = $.llm_client.completion-string(self.chat-buffer.messages);
            return $response ~ " (Elapsed {$elapsed-time.round} seconds)";
        } else {
            # rejected or modification requested

            # End timer
            my $end-time = now;
            my $elapsed-time = $end-time - $start-time;

            $!LOGGER.debug("Risk profile run elapsed time: $elapsed-time.round seconds");

            my $response = $analysis.explain;
            self.chat-buffer.add-assistant-message($ok-string.payload);
            return $response ~ " (Elapsed {$elapsed-time.round} seconds)";
        }
    }

    method handle-reactive-early-exit($reactive-return --> Str){
        self.LOGGER.debug("Exiting early as prompt attack suspected!" ~ $reactive-return.gist);
        my Str $response = Util::Config.get_config('reactive_stage', 'threat_detected_error');
        self.chat-buffer.add-user-message("<REDACTED USER MESSAGE - PROMPT ATTACK SUSPECTED>");
        self.chat-buffer.add-assistant-message($response);
        return $response;
    }

    method gist() {
        return "Cycle UUID: $.uuid, Current Index: $.index";
    }

}
