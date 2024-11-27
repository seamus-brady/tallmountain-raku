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
use Normative::Proposition;

class Normative::NormativeAnalysisResult {
    # a class that collects extracted norm props

    method MAX_EXTRACTED_PROPS {
        once Util::Config.get_config('norm_prop_extractor', 'max_extracted_norms');
    }

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
        my @conflict_props_collect;
        # need to loop through the array of conflicting propositions as the array context messes kv.map
        loop (my $i = 0; $i < Normative::NormativeAnalysisResult.MAX_EXTRACTED_PROPS; $i++) {
            try {
                my $test_np = %norm-hash<conflicting_propositions>{'NormativeProposition'}[$i];
                @conflict_props_collect.push(
                        Normative::Proposition.new-from-data($test_np)
                );
                LEAVE {
                    my Str $message = "Error extracting conflicting norm props. Logging only.";
                    Normative::Proposition.new.LOGGER.error($message);
                }
            }
        }

        # get the implied propositions
        my @implied_props_collect;
        # need to loop through the array of implied propositions as the array context messes kv.map
        loop (my $j = 0; $j < Normative::NormativeAnalysisResult.MAX_EXTRACTED_PROPS; $j++) {
            try {
                my $test_np = %norm-hash<implied_propositions>{'NormativeProposition'}[$j];
                @implied_props_collect.push(
                        Normative::Proposition.new-from-data($test_np)
                );
                LEAVE {
                    my Str $message = "Error extracting implied norm props. Logging only.";
                    Normative::Proposition.new.LOGGER.error($message);
                }
            }
        }

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
        "Items: [\n" ~ @!implied_propositions.gist ~ "]\n"
    }

    method gist_conflicting_propositions() {
        "Items: [\n" ~ @!conflicting_propositions.gist ~ "]\n"
    }
}
