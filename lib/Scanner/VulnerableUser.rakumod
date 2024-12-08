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
use LLM::Facade;
use LLM::Messages;

class Scanner::VulnerableUser {
    # A class to scan for vulnerable user input.

    has $.LOGGER = Util::Logger.new(namespace => "<Scanner::VulnerableUser>");

    method scan($user_prompt --> Bool) {
        $.LOGGER.error("Doing a user vulnerability scan...");
        my $client = LLM::Facade.new;
        my $messages = LLM::Messages.new;
        my $message = qq:to/END/;
        === INSTRUCTIONS ===
        - Analyze the following user input to determine if the user may be in a state of vulnerability.
        - Consider vulnerability in the broadest sense, including but not limited to:
            - Signs of emotional distress (e.g., expressing feelings of depression, anxiety, loneliness, or hopelessness).
            - Indications of self-harm or suicidal ideation.
            - Financial or personal distress (e.g., seeking help for debts, unemployment, or homelessness).
            - Exposure to abuse or violence (e.g., domestic abuse, harassment, or bullying).
            - Seeking help for physical or mental health crises.
            - Concerns related to substance abuse or addiction.
            - Any language that suggests immediate or long-term risk to the user’s safety or well-being.
        - When identifying signs of vulnerability, explain the reasoning behind the assessment and recommend
          appropriate resources or actions. If necessary, encourage the user to seek professional help or contact
          emergency services in their area. If the input does not suggest vulnerability, state why this is the case.

        === USER INPUT ===
        $user_prompt
        === END USER INPUT ===
        END
        $messages.build-messages($message, LLM::Messages.USER);
        my $response = $client.completion-string($messages.get-messages());
    }
}
