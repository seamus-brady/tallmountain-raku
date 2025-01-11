#  Copyright (c) 2024. Prediction By Invention https://predictionbyinvention.com/
#
#  THIS SOFTWARE IS PROVIDED "AS IS" WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED,
#  INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A
#  PARTICULAR PURPOSE, AND NON-INFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR
#  COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES, OR OTHER LIABILITY, WHETHER
#  IN AN ACTION OF CONTRACT, TORT, OR OTHERWISE, ARISING FROM, OUT OF, OR
#  IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.

use v6.d;
use Normative::Risk::RiskAnalyser;

class Cycle::Stage::ReactiveScan {
    # holds the results of a reactive scan
    has Bool $.prompt-leakage;
    has Bool $.prompt-hijack;
    has Str $.inappropriate-content;
    has Hash $.vulnerable-user;
    has Normative::Analysis::RiskAnalyser $.normative-scan;

    method new-from-results(@results) {
        self.bless(
                :prompt-leakage(@results[0]),
                :prompt-hijack(@results[1]),
                :inappropriate-content(@results[2]),
                :vulnerable-user(@results[3]),
                :normative-scan(@results[4])
        );
    }

    method has-leakage-or-hijack-attempt(--> Bool) {
        # prompt based attached found - the scans fail with a Bool::False
        return !$.prompt-leakage || !$.prompt-hijack;
    }
}
