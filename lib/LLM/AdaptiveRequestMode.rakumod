#  Copyright (c) 2024. Prediction By Invention https://predictionbyinvention.com/
#
#  THIS SOFTWARE IS PROVIDED "AS IS" WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED,
#  INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A
#  PARTICULAR PURPOSE, AND NON-INFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR
#  COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES, OR OTHER LIABILITY, WHETHER
#  IN AN ACTION OF CONTRACT, TORT, OR OTHERWISE, ARISING FROM, OUT OF, OR
#  IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.

use v6.d;

class LLM::AdaptiveRequestMode {
    # Constants for each mode
    class Mode {
        constant PRECISION_MODE          = "Precision Mode";
        constant CONTROLLED_CREATIVE_MODE = "Controlled Creative Mode";
        constant DYNAMIC_FOCUSED_MODE     = "Dynamic Focused Mode";
        constant EXPLORATORY_MODE         = "Exploratory Mode";
        constant BALANCED_MODE            = "Balanced Mode";
    }

    # Default values
    constant DEFAULT_TEMPERATURE = 0.5;
    constant DEFAULT_TOP_P = 0.5;
    constant DEFAULT_MAX_TOKENS = 4096;
    constant DEFAULT_PRESENCE_PENALTY = 0.0;
    constant DEFAULT_FREQUENCY_PENALTY = 0.0;

    # Attributes with defaults
    has Str $.mode is rw = Mode::BALANCED_MODE;
    has Rat $.temperature is rw = DEFAULT_TEMPERATURE;
    has Rat $.top_p is rw = DEFAULT_TOP_P;
    has Int $.max_tokens is rw = DEFAULT_MAX_TOKENS;

    # Constructors for each mode
    method precision_mode() {
        self.new(:mode(Mode::PRECISION_MODE)).init_mode;
    }

    method controlled_creative_mode() {
        self.new(:mode(Mode::CONTROLLED_CREATIVE_MODE)).init_mode;
    }

    method dynamic_focused_mode() {
        self.new(:mode(Mode::DYNAMIC_FOCUSED_MODE)).init_mode;
    }

    method exploratory_mode() {
        self.new(:mode(Mode::EXPLORATORY_MODE)).init_mode;
    }

    method balanced_mode() {
        self.new(:mode(Mode::BALANCED_MODE)).init_mode;
    }

    # Initialize mode settings based on selected mode
    method init_mode() {
        given $.mode {
            when Mode::PRECISION_MODE {
                self.temperature = 0.2;
                self.top_p = 0.1;
                self.max_tokens = DEFAULT_MAX_TOKENS;
            }
            when Mode::CONTROLLED_CREATIVE_MODE {
                self.temperature = 0.2;
                self.top_p = 0.9;
                self.max_tokens = DEFAULT_MAX_TOKENS;
            }
            when Mode::DYNAMIC_FOCUSED_MODE {
                self.temperature = 0.9;
                self.top_p = 0.2;
                self.max_tokens = DEFAULT_MAX_TOKENS;
            }
            when Mode::EXPLORATORY_MODE {
                self.temperature = 0.9;
                self.top_p = 0.9;
                self.max_tokens = DEFAULT_MAX_TOKENS;
            }
            when Mode::BALANCED_MODE {
                self.temperature = 0.5;
                self.top_p = 0.5;
                self.max_tokens = DEFAULT_MAX_TOKENS;
            }
        }
        self;
    }
}
