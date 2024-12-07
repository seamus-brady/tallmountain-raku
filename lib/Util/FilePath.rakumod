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

# exception class for file path exceptions
class Util::FilePath::Exception is Exception {
    has Str $.message;
}

class Util::FilePath {

    has $.LOGGER = Util::Logger.new(namespace => "<Util::FilePath>");

    my constant $CONFIG_DIR = '/config';
    my constant $NC_PROMPT = '/simplified_nc.prompt';


    method app-root(-->Str){
        # get the root dir of the app
        return $?FILE.IO.parent(3).absolute;
    }

    method config-path(-->Str){
        return self.app-root ~ $CONFIG_DIR;
    }

    method get-nc-prompt(-->Str){
        # get the prompt for the normative calculus
        try {
            my Str $nc = slurp Util::FilePath.new.config-path ~ $NC_PROMPT;
            return $nc;
            CATCH {
                my Str $message = "Error loading configuration prompt for Normative Calculus: $_";
                Util::FilePath.new.LOGGER.error($message);
                Util::FilePath::Exception.new(message => $message).throw;
            }
        }
    }
}
