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
use Plan::Forecast::Base;
use Plan::Exception;

class Plan::Forecast::TwoTier is Plan::Forecast::Base {
    # Two level of features with Feature->FeatureSet of a forecasted future.

    has $.LOGGER = Util::Logger.new(namespace => "<Plan::Forecast::TwoTier>");

    # Constructor
    submethod BUILD(@features = ()) {
        self.features = @features;
        # importance (3) x magnitude (3) x feature_set importance (3)
        self.scaling-unit = 27;
        self.validate;
    }

    # Validate features for TwoTierForecast
    method validate() {
        if @.features.elems != 0 {
            for @.features -> $feature {
                if !$feature.feature-set.defined || $feature.grouped-feature-set.defined {
                    my Str $message = "Error - invalid feature for TwoTier forecast: $_";
                    self.LOGGER.error($message);
                    Plan::Exception.new(message => $message).throw;
                }
            }
        }
    }
}
