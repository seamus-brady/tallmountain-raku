#  Copyright (c) 2024. Prediction By Invention https://predictionbyinvention.com/
#
#  THIS SOFTWARE IS PROVIDED "AS IS" WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED,
#  INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A
#  PARTICULAR PURPOSE, AND NON-INFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR
#  COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES, OR OTHER LIABILITY, WHETHER
#  IN AN ACTION OF CONTRACT, TORT, OR OTHERWISE, ARISING FROM, OUT OF, OR
#  IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.

use v6.d;

class Plan::Forecast::Base {
    # Base class for forecasts

    # Features as a set and an optional scaling unit
    has Set $.features is rw = Set.new;
    has Int $.scaling_unit is rw;

    # Abstract method for scaling unit
    method scaling-unit() {
        die "This method must be implemented by subclasses";
    }

    # Calculate the discrepancy for this forecast
    method discrepancy() {
        my $total_discrepancies = [+] $.features.map(*.calculated-discrepancy);
        return $total_discrepancies / self.scaling_unit;
    }

    # Deep copy of the object
    method option() {
        return self.clone;
    }

    # Get a feature by name
    method get_feature(Str $name) {
        for $.features -> $feature {
            return $feature if $feature.name eq $name;
        }
        die "No feature with name '$name' found";
    }

    # Update a feature's magnitude
    method update(Str $name, Int $magnitude) {
        my $feature = self.get_feature($name);

        # Remove the old feature
        $.features -= $feature;

        # Add the updated feature
        $.features += Feature.new(
                base_importance => $feature.base_importance,
                name            => $feature.name,
                magnitude       => $magnitude,
                description     => $feature.description,
                feature_set     => $feature.feature_set,
                grouped_feature-set => $feature.grouped_feature_set
        );
    }
}
