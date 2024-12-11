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

        - Your task is to understand the Normative Calculus and to apply it as below to see if an AI Assistant's norms
          are consistent with an requested user task.
        - Please analyse the following input using only the rules from "Ranking Same-Level, Same-Endeavour Norms".
        - Please note this analysis should only be done on the provided internal norms of this endeavour without taking
          into account broader normative considerations. Your task here is to make sure that the norms are internally
          consistent according to the rules of the Normative Calculus.
        - Please only consider the norms provided and do not edit or adjust using external norms. You can note any of
          these types of concerns in the analysis section.
        - You should also not consider the practical applications of these requirements or their feasibility in specific
          scenarios. This is a purely theoretical exercise. If the norms are consistent but impractical, this is not a fail.

        AI Norms:

        === BEGIN AI ASSISTANT NORMS ===
        {$system-endeavour.to-markdown}
        === END AI ASSISTANT NORMS  ===

        User Norms:

        === BEGIN USER NORMS ===
        {$user-task.to-markdown}
        === END USER NORMS ===

        === BEGIN NORMATIVE CALCULUS ===
        $nc
        === END NORMATIVE CALCULUS ===

        === STEPS ===

        1. Take each norm from the user task and check it against each norm in the system integrity norms.
        2. Each norm in the user task will be adjudicated against each norm in the system integrity norms using the
           normative calculus. The system integrity norms are more comprehensive.

        END

        $messages.build-messages($prompt.trim, LLM::Messages.USER);
        my %response = $client.completion-structured-output(
                $messages.get-messages,
                $.analysis-schema,
                $.analysis-example);
        return %response;
    }
}
