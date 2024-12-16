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
      <xs:element name="NormativeConflictAnalysis">
        <xs:complexType>
          <xs:sequence>
            <xs:element name="UserNormPropValue" type="xs:string" />
            <xs:element name="Likelihood" type="xs:integer" />
            <xs:element name="ImpactScore" type="xs:integer" />
            <xs:element name="NormAlignmentScore" type="xs:integer" />
            <xs:element name="ContextMultiplier" type="xs:decimal" />
            <xs:element name="RiskScore" type="xs:decimal" />
            <xs:element name="RiskLevel">
              <xs:simpleType>
                <xs:restriction base="xs:string">
                  <xs:enumeration value="Low" />
                  <xs:enumeration value="Moderate" />
                  <xs:enumeration value="High" />
                  <xs:enumeration value="Critical" />
                </xs:restriction>
              </xs:simpleType>
            </xs:element>
            <xs:element name="Analysis" type="xs:string" />
          </xs:sequence>
        </xs:complexType>
      </xs:element>
    </xs:schema>
    END

    has Str $.analysis-example = q:to/END/;
    <?xml version="1.0" encoding="UTF-8"?>
    <NormativeConflictAnalysis>
      <UserNormPropValue>Seek sensitive financial advice disclosure without restrictions</UserNormPropValue>
      <Likelihood>3</Likelihood>
      <ImpactScore>4</ImpactScore>
      <NormAlignmentScore>2</NormAlignmentScore>
      <ContextMultiplier>1.5</ContextMultiplier>
      <RiskScore>15.0</RiskScore>
      <RiskLevel>Moderate</RiskLevel>
      <Analysis>The user’s norm proposition conflicts with the assistant’s privacy-preservation norms, posing a moderate risk.</Analysis>
    </NormativeConflictAnalysis>
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
          given to the AI Assistant by a user. Please provide an analysis of what you find.
        - You can use the Normative Calculus to provide an analysis of the user's normative proposition by using
          the AI Assistant's endeavours as an Exogenous Assessment.
        - You must provide a risk score using the scoring metric provided.
        - Also provide an analysis of your findings in a markdown table.

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
        $np-score
        === SCORING METRIC ===

        END

        $messages.build-messages($prompt.trim, LLM::Messages.USER);
        my %response = $client.completion-structured-output(
                $messages.get-messages,
                $.analysis-schema,
                $.analysis-example);
        self.LOGGER.debug("Got conflict results: {%response}");
        return %response;
    }
}
