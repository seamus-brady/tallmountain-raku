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
use Normative::Proposition;

class Normative::NormativeAnalysisResult {
    # a class that collects extracted norm props

    has $.LOGGER = Util::Logger.new(namespace => "<Normative::NormativeAnalysisResult>");

    has Str $.input_statement;
    has Normative::Proposition @.implied_propositions;
    has Normative::Proposition @.conflicting_propositions;
    has Str $.explanation;

    method new-from-data(%norm-hash --> Normative::NormativeAnalysisResult) {
        Normative::NormativeAnalysisResult.new.LOGGER.debug("new-from-data starting...");

        # get the input statement
        my Str $input_statement = %norm-hash<input_statement>;

        # get the analysis
        my Str $explanation = %norm-hash<explanation>;

        # get the conflicting propositions
        my $conflict_norms = %norm-hash<conflicting_propositions>{'NormativeProposition'};
        my @conflict_props_collect;
        # need to loop through the array of conflicting propositions as the array context messes kv.map
        loop (my $i = 0; $i < $conflict_norms.elems; $i++) {
            try {
                @conflict_props_collect.push(
                        Normative::Proposition.new-from-data($conflict_norms[$i])
                 );
                if $! {
                    my Str $message = "Error: $!";
                    Normative::Proposition.new.LOGGER.error($message);
                }
            }
        }

        # get the conflicting propositions
        my $implied_norms = %norm-hash<implied_propositions>{'NormativeProposition'};
        my @implied_props_collect;
        # need to loop through the array of implied propositions as the array context messes kv.map
        loop (my $j = 0; $j < $implied_norms.elems; $j++) {
            try {
                say $implied_norms[$i];
                say Normative::Proposition.new-from-data($implied_norms[$i]);
                @implied_props_collect.push(
                        Normative::Proposition.new-from-data($implied_norms[$i])
                );
            }
        }

        say "implied_props_collect: {@implied_props_collect}";
        # create the object using the collected values
        self.bless(
            :$input_statement,
            :implied_propositions(@implied_props_collect),
            :conflicting_propositions(@conflict_props_collect),
            :$explanation
        );
    }

    method gist {
        return "NormativeAnalysisResult:\n" ~
                "  input_statement: {$!input_statement}\n" ~
                "  explanation: {$!explanation}\n" ~
                "  implied_propositions: {self.gist_implied_propositions}\n" ~
                "  conflicting_propositions: {self.gist_conflicting_propositions}";
    }

    method gist_implied_propositions() {
        "Items: [" ~ @!implied_propositions.join(', ') ~ "]"
    }

    method gist_conflicting_propositions() {
        "Items: [" ~ @!conflicting_propositions.join(', ') ~ "]"
    }
}
