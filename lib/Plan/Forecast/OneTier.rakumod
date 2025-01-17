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
use Plan::Forecast::Base;
use Plan::Exception;

class Plan::Forecast::OneTier is Plan::Forecast::Base {
    # Simple one level of features of a forecasted future.

    has $.LOGGER = Util::Logger.new(namespace => "<Plan::Forecast::OneTier>");
    has Int $.scaling-unit is rw;

    # Constructor
    submethod BUILD(@features = ()) {
        self.features = @features;
        # importance (3) x magnitude (3)
        self.scaling-unit = 9;
        self.validate;
    }

    # Validate features for OneTierForecast
    method validate() {
        if @.features.elems != 0 {
            for @.features -> $feature {
                if $feature.feature-set.defined || $feature.grouped-feature-set.defined {
                    my Str $message = "Error - invalid feature for OneTier forecast: $_";
                    self.LOGGER.error($message);
                    Plan::Exception.new(message => $message).throw;
                }
            }
        }
    }
}
