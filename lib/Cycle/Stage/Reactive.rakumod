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
use Cycle::Stage::ReactiveScan;
use Cycle::Stage::EarlyExit;
use Cycle::Payload::TaintedString;
use Cycle::Stage::ReactiveReturn;
use Scanner::VulnerableUser;
use Scanner::PromptLeakage;
use Scanner::PromptHijack;
use Scanner::InappropriateContent;
use Normative::UserTask;



class Cycle::Stage::Reactive {
    # reactive stage in the cognitive cycle - used for quick detection of threats and scanning

    has $.LOGGER = Util::Logger.new(namespace => "<Cycle::Stage::Reactive>");

    method run(Cycle::Payload::TaintedString $tainted --> Cycle::Stage::ReactiveReturn)  {
        # runs some scans on the prompt and returns the results

        self.LOGGER.debug("starting reactive stage of cognitive cycle...");

        my Str $prompt = $tainted.payload;

        my $start-time = now;
        my @scan_promises = start { Scanner::PromptLeakage.new.scan($prompt) },
                            start { Scanner::PromptHijack.new.scan($prompt) },
                            start { Scanner::InappropriateContent.new.scan($prompt) },
                            start { Scanner::VulnerableUser.new.scan($prompt) },
                            start { Normative::UserTask.get-from-statement($prompt) };
        my @results = await @scan_promises;

        my $end-time = now;
        my $elapsed-time = $end-time - $start-time;
        self.LOGGER.debug("scans took $elapsed-time seconds");
        my $scan_results = Cycle::Stage::ReactiveScan.new-from-results(@results);
        if $scan_results.has-leakage-or-hijack-attempt {
            self.LOGGER.debug("Prompt contains a leakage or hijack attempt!");
            return Cycle::Stage::EarlyExit.new(message => "Prompt contains a leakage or hijack attempt.");
        } else {
            self.LOGGER.debug("Prompt is clean. Returning scan results.");
            return $scan_results;
        }
    }
}
