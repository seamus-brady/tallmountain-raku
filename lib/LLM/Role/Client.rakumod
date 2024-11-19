#  Copyright (c) 2024. Prediction By Invention https://predictionbyinvention.com/
#
#  THIS SOFTWARE IS PROVIDED "AS IS" WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED,
#  INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A
#  PARTICULAR PURPOSE, AND NON-INFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR
#  COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES, OR OTHER LIABILITY, WHETHER
#  IN AN ACTION OF CONTRACT, TORT, OR OTHERWISE, ARISING FROM, OUT OF, OR
#  IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.

use v6.d;
use LLM::AdaptiveRequestMode;

role LLM::Role::Client {
    method completion-string(
            @messages,
            LLM::AdaptiveRequestMode $mode = LLM::AdaptiveRequestMode.balanced-mode
            --> Str) {
        die X::AdHoc.new(:payload("This method is not implemented."));
    }

    method completion-structured-output(
            @messages is copy,
            Str $xml-schema is copy,
            Str $xml-example is copy,
            LLM::AdaptiveRequestMode $mode = LLM::AdaptiveRequestMode.balanced-mode
            --> Hash) {
        die X::AdHoc.new(:payload("This method is not implemented."));
    }
}
