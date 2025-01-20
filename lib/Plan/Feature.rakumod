#  Copyright (c) 2024. Prediction By Invention https://predictionbyinvention.com/
#
#  THIS SOFTWARE IS PROVIDED "AS IS" WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED,
#  INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A
#  PARTICULAR PURPOSE, AND NON-INFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR
#  COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES, OR OTHER LIABILITY, WHETHER
#  IN AN ACTION OF CONTRACT, TORT, OR OTHERWISE, ARISING FROM, OUT OF, OR
#  IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.

use v6.d;
use Plan::FeatureSet;
use Plan::GroupedFeatureSet;

class Plan::Feature {
    # importance between 1 and 3 - 3 is most important
    has Int $.base-importance where 1..3;
    has Str $.name;
    has Int $.magnitude = 0;              # magnitude: defaults to 0
    has Str $.description = "";           # Optional description
    has Plan::FeatureSet $.feature-set is rw;   # Optional FeatureSet
    has Plan::GroupedFeatureSet $.grouped-feature-set is rw;  # Optional GroupedFeatureSet

    method importance() {
        # One level forecast feature
        if !$.feature-set.defined && !$.grouped-feature-set.defined {
            return $.base-importance;
        }

        # Two level forecast feature
        if $.feature-set.defined && !$.grouped-feature-set.defined {
            return $.base-importance * $.feature-set.importance;
        }

        # Three level forecast feature
        if $.feature-set.defined && $.grouped-feature-set.defined {
            return $.base-importance
                    * $.feature-set.importance
                    * $.grouped-feature-set.importance;
        }

        die "Invalid feature!";
    }

    method calculated-discrepancy() {
        # Calculated discrepancy based on importance and magnitude
        return self.importance * $.magnitude;
    }
}

