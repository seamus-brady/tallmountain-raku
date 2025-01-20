#  Copyright (c) 2024. Prediction By Invention https://predictionbyinvention.com/
#
#  THIS SOFTWARE IS PROVIDED "AS IS" WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED,
#  INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A
#  PARTICULAR PURPOSE, AND NON-INFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR
#  COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES, OR OTHER LIABILITY, WHETHER
#  IN AN ACTION OF CONTRACT, TORT, OR OTHERWISE, ARISING FROM, OUT OF, OR
#  IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.

use v6.d;
use Plan::Feature;

class Plan::Forecast::Base {
    # Base class for forecasts

    # Features as a set and an optional scaling unit
    has @.features is rw;
    has Int $.scaling-unit is rw;

    # Calculate the discrepancy for this forecast
    method discrepancy() {
        my $total-discrepancies = 0;
        for @.features -> $feature {
            say $feature;
            $total-discrepancies += $feature.calculated-discrepancy;
        }
        return $total-discrepancies / self.scaling-unit;
    }

    # Deep copy of the object
    method option() {
        my @copied-features = @.features.map({ $_.clone });
        return self.clone(features => @copied-features);
    }

    # Get a feature by name
    method get-feature(Str $name) {
        for @.features -> $feature {
            return $feature if $feature.name eq $name;
        }
    }

    method add-feature(Plan::Feature $feature) {
        if self.get-feature($feature.name) {
            die "Feature with name '$feature.name' already exists";
        }
        @.features.push($feature);
    }

    # Update a feature's magnitude
    method update(Str :$name!, Int :$magnitude!) {
        my $feature = self.get-feature($name);

        # Remove the old feature
        @.features .= grep(* !=== $feature);

        # Add the updated feature
        self.add-feature( Plan::Feature.new(
                base-importance => $feature.base-importance,
                name            => $feature.name,
                magnitude       => $magnitude,
                description     => $feature.description,
                feature-set     => $feature.feature-set,
                grouped-feature-set => $feature.grouped-feature-set
            )
        );

    }
}
