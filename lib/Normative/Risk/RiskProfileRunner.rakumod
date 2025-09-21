#  MIT License
#  
#  Copyright (c) 2024 seamus@corvideon.ie
#  
#  Permission is hereby granted, free of charge, to any person obtaining a copy
#  of this software and associated documentation files (the "Software"), to deal
#  in the Software without restriction, including without limitation the rights
#  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
#  copies of the Software, and to permit persons to whom the Software is
#  furnished to do so, subject to the following conditions:
#  
#  The above copyright notice and this permission notice shall be included in all
#  copies or substantial portions of the Software.
#  
#  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
#  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
#  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
#  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
#  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
#  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
#  SOFTWARE.

use v6.d;
use Util::Logger;
use Normative::Role::Endeavour;
use Normative::Agent;
use Normative::Risk::RiskProfile;
use Normative::Risk::NormConflict;

class Normative::Risk::RiskProfileRunner {
    # takes an endeavour and returns a profile for the normative risk

    has $.LOGGER = Util::Logger.new(namespace => "<Normative::Analysis::RiskProfileRunner>");

    method profile(
            Normative::Role::Endeavour $endeavour,
            Normative::Agent $agent
            --> Normative::Risk::RiskProfile) {
        # runs the analysis and returns the profile

        $!LOGGER.debug("Profile analysis started on the endeavour: $endeavour");

        # Start timer
        my $start-time = now;

        my Normative::Risk::RiskProfile $risks = Normative::Risk::RiskProfile.new;

        # Collect promises for all asynchronous tasks
        my @promises = $endeavour.normative-propositions.map: -> $user-norm-prop {
            start {
                # Perform analysis
                my Normative::Risk::NormConflict $norm-conflict = Normative::Risk::NormConflict.new;
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

        $!LOGGER.debug("Risk profile run elapsed time: $elapsed-time seconds");
        return $risks;
    }

}
