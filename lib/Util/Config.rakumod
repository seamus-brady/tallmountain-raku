#  Copyright (c) 2024. Prediction By Invention https://predictionbyinvention.com/
#
#  THIS SOFTWARE IS PROVIDED "AS IS" WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED,
#  INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A
#  PARTICULAR PURPOSE, AND NON-INFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR
#  COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES, OR OTHER LIABILITY, WHETHER
#  IN AN ACTION OF CONTRACT, TORT, OR OTHERWISE, ARISING FROM, OUT OF, OR
#  IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.

use v6.d;
use Config::Clever;
use Util::Logger;
use Util::FilePath;

class Util::ConfigException is Exception {
    has Str $.message;
}


class Util::Config {
    my Str:D constant $CONFIG_FILE = 'default';

    has $.LOGGER = Util::Logger.new(namespace => "<Util::Config>");

    method get_config(Str:D $section, Str:D $key --> Any) {
        my Hash:D %config = Config::Clever.load(
                :environment($CONFIG_FILE),
                :config-dir(Util::FilePath.new.config-path));
        # attempt to return the configuration value
        my $config-entry = %config{$section}{$key};
        if !$config-entry.defined {
            my $msg = "Configuration entry not found for section: $section, key: $key";
            Util::Config.new.error($msg);
            Util::ConfigException.new(message => $msg).throw;
        } else {
            Util::Config.new.LOGGER.debug("Loaded config entry: $section/$key - '$config-entry'");
            return $config-entry;
        }
    }
}




