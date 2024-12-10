#  Copyright (c) 2024. Prediction By Invention https://predictionbyinvention.com/
#
#  THIS SOFTWARE IS PROVIDED "AS IS" WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED,
#  INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A
#  PARTICULAR PURPOSE, AND NON-INFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR
#  COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES, OR OTHER LIABILITY, WHETHER
#  IN AN ACTION OF CONTRACT, TORT, OR OTHERWISE, ARISING FROM, OUT OF, OR
#  IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.

use v6.d;
use Util::FilePath;
use Normative::Agent;
use Normative::Role::Endeavour;
use LLM::Facade;
use LLM::Messages;
use Normative::UserTask;

class Normative::TaskAnalysis {
    # a class that analyses a UserTask against the systems norms using the normative calculus


    has $.LOGGER = Util::Logger.new(namespace => "<Normative::UserTask>");

    has Str $.analysis-schema = q:to/END/;
    <?xml version="1.0" encoding="UTF-8"?>
    <xs:schema xmlns:xs="http://www.w3.org/2001/XMLSchema" elementFormDefault="qualified">

        <xs:element name="NormativeAnalysis">
            <xs:complexType>
                <xs:sequence>
                    <xs:element name="Conflict" type="xs:boolean" />
                    <xs:element name="Analysis" type="xs:string" />
                </xs:sequence>
            </xs:complexType>
        </xs:element>

    </xs:schema>
    END

    has Str $.analysis-example = q:to/END/;
    <?xml version="1.0" encoding="UTF-8"?>
    <NormativeAnalysis>
        <Conflict>true</Conflict>
        <Analysis>The identified policy creates a conflict between data privacy and operational efficiency.</Analysis>
    </NormativeAnalysis>
    END

    method analyse(
            Normative::Role::Endeavour $user-task,
            Normative::Role::Endeavour $system-endeavour,
            Str $extra-instructions = "",
            --> Hash) {
        # a method that analyses a UserTask against the systems norms using the normative calculus

        my $nc = Util::FilePath.new.get-nc-prompt;
        my $client = LLM::Facade.new();
        my $messages = LLM::Messages.new;

        my $prompt = qq:to/END/;
        === INSTRUCTIONS ===
        - Your task is to understand the Normative Calculus and to apply it as below to see if an AI Assistant's norms
          have any actual conflicts with the norms of a user task it has been requested to undertake.
        - You will receive an internal endeavour from the AI assistant and the user task endeavour.
        - Treat the AI Assistant's endeavour as the more comprehensive endeavour under the Normative Calculus.
        - In your analysis, only analyze norms explicitly presented in the user task and the AI Assistant's endeavour.
          Avoid extrapolating or inferring unstated norms. Ignore potential conflicts that rely on assumed or external
          norms not mentioned in the provided text.
        - If there is no explicit conflict, the analysis should state that there is no conflict.

        $extra-instructions

        === BEGIN AI ASSISTANT ENDEAVOUR ===
        {$system-endeavour.to-markdown}
        === END AI ASSISTANT ENDEAVOUR ===

        === BEGIN USER TASK ENDEAVOUR ===
        {$user-task.to-markdown}
        === END USER TASK ENDEAVOUR ===

        === BEGIN NORMATIVE CALCULUS ===
        $nc
        === END NORMATIVE CALCULUS ===
        END

        $messages.build-messages($prompt.trim, LLM::Messages.USER);
        my %response = $client.completion-structured-output(
                $messages.get-messages,
                $.analysis-schema,
                $.analysis-example);
        return %response;
    }
}
