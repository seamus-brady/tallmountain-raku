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

class Normative::Analysis::ImpactAssess {
    has $.LOGGER = Util::Logger.new(namespace => "<Normative::Analysis::ImpactAssess>");

    has Str $.analysis-schema = q:to/END/;
    <xs:schema xmlns:xs="http://www.w3.org/2001/XMLSchema" elementFormDefault="qualified">
      <xs:element name="ImpactAssessment">
        <xs:complexType>
          <xs:sequence>
            <xs:element name="ImpactAssessmentScore" type="xs:int"/>
            <xs:element name="Analysis" type="xs:string"/>
          </xs:sequence>
        </xs:complexType>
      </xs:element>
    </xs:schema>
    END

    has Str $.analysis-example = q:to/END/;
    <ImpactAssessment>
      <ImpactAssessmentScore>8</ImpactAssessmentScore>
      <Analysis>The task involves high sensitivity as it pertains to vulnerable individuals. Inaccurate predictions
     could lead to severe harm, including self-harm or neglect, and thus carries a high societal impact.</Analysis>
    </ImpactAssessment>
    END


    method analyse(Str  $user_task --> Hash) {

        self.LOGGER.debug("Analyzing the task to get a Impact Assessment Score (IAS)...");

        my $client = LLM::Facade.new();
        my $messages = LLM::Messages.new;

        my $prompt = qq:to/END/;
        === INSTRUCTIONS ===

        Impact Assessment Score (IAS)

        You are an expert classifier tasked with assigning an Impact Assessment Score (IAS) to user queries.
        The IAS is a numeric value between 1 and 10:

        1 = Minimal impact

        10 = Maximum impact

        During a risk assessment, impact is typically measured by evaluating the potential consequences of a risk event
        on an individual, organization or system. This measurement often involves both qualitative and quantitative
        approaches, depending on the context and the resources available.

        The process generally includes the following steps:

        1. Identify Impact Domains

            Financial Impact: Direct costs, lost revenue, or increased operational costs.
            Reputational Impact: Damage to brand, customer trust, or public perception.
            Operational Impact: Disruption to processes, reduced efficiency, or system downtime.
            Regulatory/Legal Impact: Fines, legal consequences, or non-compliance penalties.
            Safety Impact: Risks to human life, health, or the environment.

        2. Establish Metrics

            Qualitative Metrics: Use of descriptive scales (e.g., "low," "medium," "high") to assess non-numeric impacts
            like reputational harm.
            Quantitative Metrics: Numeric estimates (e.g., dollar amounts, downtime in hours) for measurable impacts.

        3. Scenario Analysis

            Best-Case, Worst-Case, and Most Likely Scenarios: Evaluate the range of outcomes to capture variability in
            potential impact.
            Historical Data: Use past incidents to estimate possible impacts.

        4. Assign Impact Scores

            Develop a scoring model (e.g., 1-5 or 1-10) where higher scores represent greater severity.
            Include thresholds for each domain to standardize the assessment.

        5. Evaluate and Prioritize

            Combine impact scores with likelihood to prioritize risks using methods like a risk matrix.
            Consider interdependencies or cascading effects that may amplify impacts.

        For example, a cyberattack might be assessed as having:

            Financial Impact: Large recovery costs and/or lost revenue.
            Reputational Impact: "Medium" damage to customer trust.
            Operational Impact: Two days of downtime.

        The cumulative evaluation informs decision-making for risk mitigation and resource allocation.

        === USER TASK ===
        $user_task

        END
        $messages.build-messages($prompt.trim, LLM::Messages.USER);
        my %response = $client.completion-structured-output(
                $messages.get-messages,
                $.analysis-schema,
                $.analysis-example);
        self.LOGGER.debug("Got IAS result: %response");
        return %response;
    }
}

