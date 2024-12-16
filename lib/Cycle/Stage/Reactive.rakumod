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
use Normative::Agent;
use Cycle::Stage::ReactiveScan;
use Cycle::Stage::EarlyExit;
use Cycle::Payload::TaintedString;
use Cycle::Stage::ReactiveReturn;
use Scanner::VulnerableUser;
use Scanner::PromptLeakage;
use Scanner::PromptHijack;
use Scanner::InappropriateContent;
use Scanner::NormativeRisk;



class Cycle::Stage::Reactive {
    # reactive stage in the cognitive cycle - used for quick detection of threats and scanning
    # based on Aaron Sloman's CogAff architecture

    has $.LOGGER = Util::Logger.new(namespace => "<Cycle::Stage::Reactive>");
    has Normative::Agent $.normative-agent;

    method run(Cycle::Payload::TaintedString $tainted --> Cycle::Stage::ReactiveReturn)  {
        # runs some scans on the prompt and returns the results

        self.LOGGER.debug("starting reactive stage of cognitive cycle...");

        # get prompt from payload
        my Str $prompt = $tainted.payload;

        # run scans
        my @scans = self.handle-scans($prompt);

        # check for leakage or hijack attempts
        my $scan_results = Cycle::Stage::ReactiveScan.new-from-results(@scans);
        if $scan_results.has-leakage-or-hijack-attempt {
            return self.handle-early-exit-for-threat;
        }
        return $scan_results;
    }

    method handle-scans(Str $prompt --> Array) {
        # handle the running of the scans
        my $start-time = now;
        my @scan_promises = start { Scanner::PromptLeakage.new.scan($prompt) },
                            start { Scanner::PromptHijack.new.scan($prompt) },
                            start { Scanner::InappropriateContent.new.scan($prompt) },
                            start { Scanner::VulnerableUser.new.scan($prompt) },
                            start { Scanner::NormativeRisk.new.scan($prompt, $.normative-agent) };
        my @results = await @scan_promises;
        my $end-time = now;
        my $elapsed-time = $end-time - $start-time;
        self.LOGGER.debug("scans took $elapsed-time seconds");
        return @results;
    }

    method handle-early-exit-for-threat() {
        self.LOGGER.debug("Prompt contains a leakage or hijack attempt!");
        my Str $response = Util::Config.get_config('reactive_stage', 'threat_detected_error');
        return Cycle::Stage::EarlyExit.new(
                ai-message => $response,
                user-message => "<REDACTED USER MESSAGE - PROMPT ATTACK SUSPECTED>",
                exit-details => "Prompt contains a leakage or hijack attempt. Prompt will not be processed."
        );
    }
}
