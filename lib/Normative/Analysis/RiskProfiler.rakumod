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
use Normative::Role::Endeavour;
use Normative::Agent;

class Normative::Analysis::RiskProfiler {
    # takes an endeavour and returns a profile for the normative risk

    has $.LOGGER = Util::Logger.new(namespace => "<Normative::Analysis::RiskProfiler>");

    has @.risk-levels;
    has %.counts = ('Low' => 0, 'Moderate' => 0, 'High' => 0, 'Critical' => 0);


    method profile(Normative::Role::Endeavour $endeavour, Normative::Agent $agent) {
        # runs the analysis and returns the profile

        # Start timer
        my $start-time = now;

        my Normative::Analysis::RiskResults $risks = Normative::Analysis::RiskResults.new;

        # Collect promises for all asynchronous tasks
        my @promises = $endeavour.normative-propositions.map: -> $user-norm-prop {
            start {
                # Perform analysis
                my Normative::Analysis::NormConflict $norm-conflict = Normative::Analysis::NormConflict.new;
                my %response = $norm-conflict.analyse($user-norm-prop, $agent);

                # Add response to risks and output the result
                $risks.add-entry(%response);
            }
        };

        # Wait for all tasks to complete
        await @promises;

        # End timer
        my $end-time = now;
        my $elapsed-time = $end-time - $start-time;

        say "Elapsed time: $elapsed-time seconds";

        say $risks.to-markdown;

        @.risk-levels = $risks.get-all-risk-levels;
        self.classify-risks;
        return self.analyze;
    }

    method classify-risks {
        # Classify the risks into levels
        for @.risk-levels -> $level {
            %.counts{$level}++ if %.counts{$level}:exists;
        }
        return %.counts;
    }

    method is-safe {
        my %counts = self.classify-risks();
        say %counts;
        if %counts{'High'} > 0 || %counts{'Critical'} > 0 {
            return Bool::False;
        }
        if %counts{'Moderate'} >= 2 {
            return Bool::False;
        }
        return Bool::True;
    }

    method risk-profile {
        my %counts = self.classify-risks();
        return "Risk Profile: " ~ %counts.keys.sort.map({ "$_: %counts{$_}" }).join(", ");
    }

    method analyze {
        say self.risk-profile();
        say "Task Status: " ~ (self.is-safe() ?? "Safe" !! "Unsafe");
    }
}
