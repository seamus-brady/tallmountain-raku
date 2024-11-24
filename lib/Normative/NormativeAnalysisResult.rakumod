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

    method new-from-hash(%hash) {
        my @implied-norms = self.parse-propositions(%hash<implied_propositions>);
        my @conflict-norms = self.parse-propositions(%hash<conflicting_propositions>);
        self.bless(
                input_statement          => %hash<input_statement>,
                explanation              => %hash<explanation>,
                implied_propositions     => @implied-norms,
                conflicting_propositions => @conflict-norms
        );
    }

    method parse-propositions($propositions-hash) {
        my @propositions;
        my $prop-hash = $propositions-hash<Normative::Proposition>;
        if $prop-hash ~~ Array {
            for $prop-hash -> $prop {
                @propositions.push: Normative::Proposition.new(|%($prop));
            }
        } else {
            @propositions.push: Normative::Proposition.new(|%($prop-hash));
        }
        return @propositions;
    }
}
