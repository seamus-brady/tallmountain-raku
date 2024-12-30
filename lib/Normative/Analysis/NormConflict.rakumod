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
use Util::Logger;
use Normative::Agent;
use Normative::Proposition;
use LLM::Facade;
use LLM::Messages;
use Normative::UserTask;


class Normative::Analysis::NormConflict {
    # a class to find if an incoming norm conflicts with the system norms

    has $.LOGGER = Util::Logger.new(namespace => "<Normative::Analysis::NormConflict>");

    has Str $.analysis-schema = q:to/END/;
    <?xml version="1.0" encoding="UTF-8"?>
    <xs:schema xmlns:xs="http://www.w3.org/2001/XMLSchema" elementFormDefault="qualified">
      <xs:element name="NormativeConflictAnalyses">
        <xs:complexType>
          <xs:sequence>
            <xs:element name="OverallAnalysis" type="xs:string" />
            <xs:element name="NormativeConflictAnalysis" maxOccurs="unbounded">
              <xs:complexType>
                <xs:sequence>
                  <xs:element name="UserNormPropUUID" type="xs:string" />
                  <xs:element name="UserNormPropValue" type="xs:string" />
                  <xs:element name="AINormConflictedWith" type="xs:string"/>
                  <xs:element name="AINormUUIDConflictedWith" type="xs:string"/>
                  <xs:element name="NormAlignmentScore" type="xs:integer" />
                  <xs:element name="Analysis" type="xs:string" />
                </xs:sequence>
              </xs:complexType>
            </xs:element>
          </xs:sequence>
        </xs:complexType>
      </xs:element>
    </xs:schema>
    END

    has Str $.analysis-example = q:to/END/;
    <?xml version="1.0" encoding="UTF-8"?>
    <NormativeConflictAnalyses xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance">
        <OverallAnalysis>The analysis shows significant conflicts between AI norms and user norms.</OverallAnalysis>
        <NormativeConflictAnalysis>
            <UserNormPropUUID>uuid-1234-abcd</UserNormPropUUID>
            <UserNormPropValue>I should share all data with everyone.</UserNormPropValue>
            <AINormConflictedWith>The AI system should prioritise user privacy.</AINormConflictedWith>
            <AINormUUIDConflictedWith>uuid-5678-efgh</AINormUUIDConflictedWith>
            <NormAlignmentScore>45</NormAlignmentScore>
            <Analysis>This conflict arises due to differing prioritization of privacy values.</Analysis>
        </NormativeConflictAnalysis>
        <NormativeConflictAnalysis>
            <UserNormPropUUID>uuid-9101-ijkl</UserNormPropUUID>
            <UserNormPropValue>User values transparency in decision-making.</UserNormPropValue>
            <AINormConflictedWith>AI uses opaque algorithmic models.</AINormConflictedWith>
            <AINormUUIDConflictedWith>uuid-1213-mnop</AINormUUIDConflictedWith>
            <NormAlignmentScore>30</NormAlignmentScore>
            <Analysis>The lack of explainability in the AI model conflicts with user expectations.</Analysis>
        </NormativeConflictAnalysis>
    </NormativeConflictAnalyses>
    END

    method analyse(
            Normative::Proposition $user-norm-prop,
            Normative::Agent $agent
            --> Hash) {
        # a method that analyses a UserTask against the systems norms using the normative calculus

        self.LOGGER.debug("Analyzing the User Norm Proposition against the AI Assistant's Norms...");

        # get the prompts for the technical parts of the analysis
        my $nc = Util::FilePath.new.get-nc-prompt;
        my $np-score = Util::FilePath.new.get-norm-prop-score-prompt;

        my $client = LLM::Facade.new();
        my $messages = LLM::Messages.new;

        my $prompt = qq:to/END/;
        === INSTRUCTIONS ===
        - Your task is to see if there is a conflict between the norms of the AI Assistant and the norms that have been
          given to the AI Assistant by a user. These normative propositions have been extracted from a task that the
          AI Assistant has been given and it is your task to see if the AI assistant can complete the task without
          violating it's own normative propositions.
        - You can use the Normative Calculus to provide an analysis of the user's normative proposition by using
          the AI Assistant's endeavours as an Exogenous Assessment. If there is a conflict between the user's normative
          proposition and the AI Assistant's normative proposition, you must list the user's normative proposition
          against each of the AI Assistant's normative propositions that it conflicts with, with an analysis.
        - You must list each AI Assistant's normative proposition with a conflict in a new entry.
        - You must provide a risk score using the scoring metric provided.
        - Also provide an overall analysis of your findings.

        === STEPS ===

        - Review 4.3.2 Exogenous Assessment in the attached Normative Calculus document.
        - Examine the user's normative proposition.
        - Examine the AI Assistant's normative propositions.
        - Using the Normative Calculus, provide an rigourous analysis of the user's normative proposition by using
          the AI Assistant's endeavours as an Exogenous Assessment.
        - Return your results as markdown.

        === BEGIN AI ASSISTANT'S ENDEAVOURS ===
        {$agent.highest-endeavour-to-markdown}
        --------------------------------------
        {$agent.system-endeavours-to-markdown}
        === END AI ASSISTANT'S ENDEAVOURS  ===

        === BEGIN USER NORM PROP ===
        {$user-norm-prop.to-markdown}
        === END USER NORM PROP ===

        === BEGIN NORMATIVE CALCULUS ===
        $nc
        === END NORMATIVE CALCULUS ===

        === SCORING METRIC ===
        - Score each user normative proposition against any of the AI normative proposition that it conflicts with
          with an alignment score between 0 and 10.
        - 0 means no alignment and 10 means full alignment.
        - You do not have to include the non-problematic user normative propositions.
        === SCORING METRIC ===

        END
        say $prompt.trim;
        $messages.build-messages($prompt.trim, LLM::Messages.USER);
        my %response = $client.completion-structured-output(
                $messages.get-messages,
                $.analysis-schema,
                $.analysis-example);
        self.LOGGER.debug("Got conflict results: %response");
        return %response;
    }
}
