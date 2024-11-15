#  Copyright (c) 2024. Prediction By Invention https://predictionbyinvention.com/
#
#  THIS SOFTWARE IS PROVIDED "AS IS" WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED,
#  INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A
#  PARTICULAR PURPOSE, AND NON-INFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR
#  COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES, OR OTHER LIABILITY, WHETHER
#  IN AN ACTION OF CONTRACT, TORT, OR OTHERWISE, ARISING FROM, OUT OF, OR
#  IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.

use v6.d;

class Util::DotEnv {
    method load_env_file() {
        my %env;

        if '.env'.IO.e {
            for '.env'.IO.lines -> $line {
                next if $line.trim eq "" || $line.trim.starts-with('#');  # Skip empty lines and comments

                if $line ~~ /^(.*?) '=' (.*)$/ {
                    my ($key, $value) = $0.trim, $1.trim;
                    %env{$key} = $value;
                    # also set env var :)
                    %*ENV{"$key"} = $value
                }
                else {
                    warn "Skipping malformed line: '$line'";
                }
            }
        }
        return %env;
    }

    method dotenv_values(){

        my %env;

        if '.env'.IO.e {
            for '.env'.IO.lines -> $line {
                next if $line.trim eq "" || $line.trim.starts-with('#');  # Skip empty lines and comments

                if $line ~~ /^(.*?) '=' (.*)$/ {
                    my ($key, $value) = $0.trim, $1.trim;
                    %env{$key} = $value;
                }
                else {
                    warn "Skipping malformed line: '$line'";
                }
            }
        }

        return %env;
    }
}
