#  Copyright (c) 2024. Prediction By Invention https://predictionbyinvention.com/
#
#  THIS SOFTWARE IS PROVIDED "AS IS" WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED,
#  INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A
#  PARTICULAR PURPOSE, AND NON-INFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR
#  COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES, OR OTHER LIABILITY, WHETHER
#  IN AN ACTION OF CONTRACT, TORT, OR OTHERWISE, ARISING FROM, OUT OF, OR
#  IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.

use v6.d;
use Normative::Proposition;

class Normative::NormativeAnalysisResult {
    has Str $.input_statement;
    has Normative::Proposition @.implied_propositions;
    has Normative::Proposition @.conflicting_propositions;
    has Str $.explanation;

    method new-from-hash(%norm-hash) {
        my @conflicting = %norm-hash<conflicting_propositions>.map: {
            Normative::Proposition.from-hash($_)
        };

        my @implied = %norm-hash<implied_propositions>.map: {
            Normative::Proposition.from-hash($_)
        };
        self.bless(
                input_statement          => %norm-hash<input_statement>,
                explanation              => %norm-hash<explanation>,
                implied_propositions     => @implied,
                conflicting_propositions => @conflicting
        );
    }
}
