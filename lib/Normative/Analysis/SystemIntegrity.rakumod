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

class Normative::Analysis::SystemIntegrity {
    # a class that analyses a UserTask against the system integrity norms using the normative calculus


    has $.LOGGER = Util::Logger.new(namespace => "<Normative::UserTask>");

    has Str $.analysis-schema = q:to/END/;
    <?xml version="1.0" encoding="UTF-8"?>
    <xs:schema xmlns:xs="http://www.w3.org/2001/XMLSchema" elementFormDefault="qualified">

        <xs:element name="NormativeAnalysis">
            <xs:complexType>
                <xs:sequence>
                    <xs:element name="Conflict" type="xs:boolean" />
                    <xs:element name="Analysis" type="xs:string" />
                    <xs:element name="UserMessage" type="xs:string" />
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
        <UserMessage>I am afraid I cannot complete that request due to conflict with data privacy.</UserMessage>
    </NormativeAnalysis>
    END

    method analyse(
            Normative::Role::Endeavour $user-task,
            Normative::Role::Endeavour $system-endeavour,
            --> Hash) {
        # a method that analyses a UserTask against the systems norms using the normative calculus

        my $nc = Util::FilePath.new.get-nc-prompt;
        my $client = LLM::Facade.new();
        my $messages = LLM::Messages.new;

        my $prompt = qq:to/END/;
        === INSTRUCTIONS ===
        - Analyze only the following input norms. Do not infer or add any new norms:

        AI Norms:

        === BEGIN AI ASSISTANT NORMS ===
        {$system-endeavour.to-markdown}
        === END AI ASSISTANT NORMS  ===

        User Norms:

        === BEGIN USER NORMS ===
        {$user-task.to-markdown}
        === END USER NORMS ===

        - Important: You are not permitted to infer, add, or modify norms beyond those explicitly listed.
        - Your task is to understand the Normative Calculus and to apply it if an AI Assistant's norms
          are in conflict with the norms of a user task it has been requested to undertake.
        - Please provide detailed step-by-step analysis of your reasoning.
        - If there is no explicit conflict, the analysis should state that there is no conflict.
        - Please also provide a message that the AI Assistant should provide to the user if there is a conflict. This
          should be first person and should be polite and informative, but concise.

        === BEGIN NORMATIVE CALCULUS ===
        $nc
        === END NORMATIVE CALCULUS ===

        === STEPS ===

        1. Take each norm from the user task and check it against each norm in the system integrity norms.
        2. Each norm in the user task will be adjudicated against each norm in the system integrity norms using the
           normative calculus. The system integrity norms are more comprehensive.
        3. The actual comparison is narrow and focused only on the content of the norm being compared. This is not a
           general comparison of the two sets of norms, this is a technical task to see if an incoming request fails
           to meet the system integrity norms.
        4. Ethical norms are EXCLUDED in this analysis. This is a technical analysis only so any ethical or moral norms
           are not considered.

        END

        $messages.build-messages($prompt.trim, LLM::Messages.USER);
        my %response = $client.completion-structured-output(
                $messages.get-messages,
                $.analysis-schema,
                $.analysis-example);
        return %response;
    }
}
