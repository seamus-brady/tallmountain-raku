#  Copyright (c) 2024. Prediction By Invention https://predictionbyinvention.com/
#
#  THIS SOFTWARE IS PROVIDED "AS IS" WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED,
#  INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A
#  PARTICULAR PURPOSE, AND NON-INFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR
#  COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES, OR OTHER LIABILITY, WHETHER
#  IN AN ACTION OF CONTRACT, TORT, OR OTHERWISE, ARISING FROM, OUT OF, OR
#  IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.

use v6.d;
use LLM::Facade;
use LLM::Messages;
use Normative::Analysis::RiskEntry;

class Normative::Analysis::RiskProfile {
    # a class to hold a list of RiskEntry objects

    # Declare an attribute to hold a list of RiskEntry objects
    has @.data;

    # Method to add a new entry to the data list
    method add_entry(%entry) {
        @!data.push(Normative::Analysis::RiskEntry.new(|%entry));
    }

    # Method to remove an entry at a specific index
    method remove-entry(Int $index) {
        # Check if the index is valid
        die "Invalid index" unless $index >= 0 && $index < @!data.elems;
        # Remove the entry at the specified index
        @!data.splice($index, 1);
    }

    # Method to retrieve an entry by its index
    method get_entry(Int $index) {
        # Check if the index is valid
        die "Invalid index" unless $index >= 0 && $index < @!data.elems;
        # Return the entry at the specified index
        @!data[$index];
    }

    method get_all_risk_scores() {
        # gets an array of all risk scores for each norm prop
        return @!data.map(*.RiskScore);
    }

    method get_all_risk_levels() {
        # gets an array of all risk levels for each norm prop
        return @!data.map(*.RiskLevel);
    }

    # Method to list all entries in the data
    method list_entries {
        # Return the complete list of data entries
        return @!data;
    }

    method to_markdown(--> Str) {
        my $output = "| Index | Analysis               | ContextMultiplier | ImpactScore | Likelihood | NormAlignmentScore | RiskLevel  | RiskScore | UserNormPropValue                          |\n";
        $output ~= "|-------|------------------------|-------------------|-------------|------------|--------------------|------------|-----------|-------------------------------------------|\n";
        for @!data.kv -> $index, $entry {
            $output ~= "| $index  | {$entry.Analysis}             | {$entry.ContextMultiplier}            | {$entry.ImpactScore}       | {$entry.Likelihood}       | {$entry.NormAlignmentScore}             | {$entry.RiskLevel}       | {$entry.RiskScore}       | {$entry.UserNormPropValue}                           |\n";
        }
        return $output;
    }
}
