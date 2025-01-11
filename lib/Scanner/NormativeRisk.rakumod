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
use Cycle::Payload::TaintedString;
use Normative::UserTask;
use Normative::Agent;
use Normative::Risk::RiskProfile;
use Normative::Risk::RiskProfileRunner;
use Normative::Risk::RiskAnalyser;

class Scanner::NormativeRisk {
    # This class is responsible for detecting normative risks in the user's input and returning a risk profile.
    has $.LOGGER = Util::Logger.new(namespace => "<Scanner::NormativeRisk>");

    method scan(Str $user-query, Normative::Agent $normative-agent --> Normative::Analysis::RiskAnalyser) {
        $.LOGGER.error("Doing a normative risk scan...");
        # create the user task
        my $user_task = Normative::UserTask.new.get-from-statement($user-query.trim);
        my Normative::Analysis::RiskProfileRunner $norm-risk-profiler = Normative::Analysis::RiskProfileRunner.new;
        my Normative::Analysis::RiskProfile $risk-profile = $norm-risk-profiler.profile($user_task, $normative-agent);
        my $analysis = Normative::Analysis::RiskAnalyser.new(
                risk-profile => $risk-profile,
                user-task => $user_task,
        );
        return $analysis;
    }
}
