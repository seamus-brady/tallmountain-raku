use v6.d;

class AdaptiveRequestMode {
    # Constants for each mode
    class Mode {
        constant PRECISION_MODE          = "Precision Mode";
        constant CONTROLLED_CREATIVE_MODE = "Controlled Creative Mode";
        constant DYNAMIC_FOCUSED_MODE     = "Dynamic Focused Mode";
        constant EXPLORATORY_MODE         = "Exploratory Mode";
        constant BALANCED_MODE            = "Balanced Mode";
    }

    # Default values
    constant DEFAULT-TEMPERATURE = 0.5;
    constant DEFAULT-TOP-P = 0.5;
    constant DEFAULT-MAX-TOKENS = 4096;
    constant DEFAULT-PRESENCE-PENALTY = 0.0;
    constant DEFAULT-FREQUENCY-PENALTY = 0.0;

    # Attributes with defaults
    has Str $.mode is rw = Mode::BALANCED_MODE;
    has Rat $.temperature is rw = DEFAULT-TEMPERATURE;
    has Rat $.top-p is rw = DEFAULT-TOP-P;
    has Int $.max-tokens is rw = DEFAULT-MAX-TOKENS;

    # Constructors for each mode
    method precision-mode() {
        self.new(:mode(Mode::PRECISION_MODE)).init-mode;
    }

    method controlled-creative-mode() {
        self.new(:mode(Mode::CONTROLLED_CREATIVE_MODE)).init-mode;
    }

    method dynamic-focused-mode() {
        self.new(:mode(Mode::DYNAMIC_FOCUSED_MODE)).init-mode;
    }

    method exploratory-mode() {
        self.new(:mode(Mode::EXPLORATORY_MODE)).init-mode;
    }

    method balanced-mode() {
        self.new(:mode(Mode::BALANCED_MODE)).init-mode;
    }

    # Initialize mode settings based on selected mode
    method init-mode() {
        given $.mode {
            when Mode::PRECISION_MODE {
                self.temperature = 0.2;
                self.top-p = 0.1;
                self.max-tokens = DEFAULT-MAX-TOKENS;
            }
            when Mode::CONTROLLED_CREATIVE_MODE {
                self.temperature = 0.2;
                self.top-p = 0.9;
                self.max-tokens = DEFAULT-MAX-TOKENS;
            }
            when Mode::DYNAMIC_FOCUSED_MODE {
                self.temperature = 0.9;
                self.top-p = 0.2;
                self.max-tokens = DEFAULT-MAX-TOKENS;
            }
            when Mode::EXPLORATORY_MODE {
                self.temperature = 0.9;
                self.top-p = 0.9;
                self.max-tokens = DEFAULT-MAX-TOKENS;
            }
            when Mode::BALANCED_MODE {
                self.temperature = 0.5;
                self.top-p = 0.5;
                self.max-tokens = DEFAULT-MAX-TOKENS;
            }
        }
        self;
    }
}
