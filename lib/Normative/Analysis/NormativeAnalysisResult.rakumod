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

class Normative::Analysis::NormativeAnalysisResult {
    # a class that collects extracted norm props

    # run time "constant"
    method MAX_EXTRACTED_PROPS {
        once Util::Config.get_config('norm_prop_extractor', 'max_extracted_norms');
    }

    has $.LOGGER = Util::Logger.new(namespace => "<Normative::NormativeAnalysisResult>");

    has Str $.input_statement;
    has Normative::Proposition @.implied_propositions;
    has Normative::Proposition @.conflicting_propositions;
    has Str $.explanation;


    method new_from_data(%norm_hash --> Normative::Analysis::NormativeAnalysisResult) {
        Normative::Analysis::NormativeAnalysisResult.new.LOGGER.debug("new_from_data starting...");

        # get the input statement
        my Str $input_statement = %norm_hash<input_statement>;

        # get the implied propositions
        my @implied_props_collect;

        # need to loop through the array of implied propositions as the array context messes kv.map
        loop (my $j = 0; $j < Normative::Analysis::NormativeAnalysisResult.MAX_EXTRACTED_PROPS; $j++) {
            try {
                my $test_np = %norm_hash<implied_propositions>{'NormativeProposition'}[$j];
                my Normative::Proposition $new_np = Normative::Proposition.new_from_data($test_np);
                say ">>>>>>: { $new_np.gist }";
                @implied_props_collect.push($new_np);
                say @implied_props_collect;
                LEAVE {
                    # ignore all exceptions
                }
            }
        }

        # create the object using the collected values
        self.bless(
                :$input_statement,
                :implied_propositions(@implied_props_collect),
        );
    }

    method gist {
        return "NormativeAnalysisResult:\n" ~
                "  input_statement: { $!input_statement }\n" ~
                "  implied_propositions: { self.gist_implied_propositions }\n";
    }

    method gist_implied_propositions() {
        "Items: [\n" ~ @!implied_propositions.gist ~ "]\n"
    }

    method to_markdown {
        my $markdown = "# Normative Analysis Result\n\n";
        $markdown ~= "## Input Statement\n\n";
        $markdown ~= "{ $!input_statement }\n\n";
        $markdown ~= "## Implied Propositions\n\n";
        for @!implied_propositions -> $prop {
            $markdown ~= $prop.to_markdown ~ "\n";
        }
        return $markdown;
    }
}
