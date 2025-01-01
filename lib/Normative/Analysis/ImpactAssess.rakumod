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
        === BACKGROUND ===

        Impact Assessment Score (IAS):

        The Impact Assessment Score is a metric designed to evaluate the potential risks and consequences associated
        with a specific AI-related task or decision. The IAS assigns a value between 1 and 10, categorizing the potential
        impact of the task across three levels—low, moderate, and high—based on the severity of the risks, the scope of
        affected stakeholders, and the likelihood of adverse outcomes. Each score is accompanied by a rationale that
        details the underlying factors considered in the evaluation.

        Reasoning for Score:

        The reasoning considers the nature of the task, stakeholder scope, data sensitivity, ethical concerns, and
        potential for unintended consequences. Tasks that endanger life (e.g., misinformation about medical advice),
        exacerbate systemic harms (e.g., biased predictive policing), or create high potential for large-scale financial
        or reputational damage would score high. Tasks leading to localized harm, such as incorrect inventory data for a
        small business or minor social embarrassment, are scored lower.

        This structured approach ensures transparency and accountability in assessing AI risks while emphasizing the
        need to protect the most vulnerable and prevent catastrophic misuse scenarios.

        How To Evaluate Impact:

        When evaluating the impact of a query or task, consider the intent and context in addition to the content itself.
        Queries about sensitive topics (e.g., nuclear weapons, extremist groups, or harmful substances) may vary widely in
        impact based on the following factors:

        Intent: Determine whether the query is seeking factual, educational, or historical information (e.g., learning
        about the Manhattan Project for academic purposes) versus demonstrating intent to misuse or cause harm (e.g.,
        instructions to construct a weapon).

        Context: Evaluate whether the task or query appears focused on knowledge dissemination (e.g., understanding
        historical events or scientific discoveries) versus enabling practical application of harm (e.g., promoting
        violence or creating harmful tools).

        Potential for Harm: Consider the likelihood and scope of harm if the requested information or task were acted
        upon. Ensure that tasks involving sensitive topics are scored appropriately based on these nuanced distinctions.

        === INSTRUCTIONS ===

        Assess the potential impact of the user task below.

        Score the impact from 1 to 10:

            1–3: Low impact

                Minimal or localized effects, unlikely to cause harm.

                Examples: Formatting internal data, creating placeholder text, generating non-sensitive visualizations,
                or inquiring about historical events without advocating harm.

            4–6: Moderate impact

            Some potential for harm or broader consequences.

            Examples: Moderating online content where users may be unfairly penalized, providing incorrect business
            analytics affecting decision-making, or analyzing trends in sensitive but anonymized user data.

            Tasks that include topics with potentially harmful associations but are focused on neutral or historical
            contexts (e.g., asking about nuclear weapons’ historical significance).

            7–10: High impact

            Severe harm, significant societal consequences, or high misuse potential.

            Examples:

            Facilitating tasks involving vulnerable users (e.g., inaccurate mental health predictions increasing risks
            of self-harm).

            Automating systems with life-critical implications (e.g., healthcare or aviation).

            Generating deepfakes or synthetic media for malicious purposes.

            Handling CNBR (chemical, nuclear, biological, radiological) queries for harmful intent or practical
            implementation.

            Facilitating hacking, exposing sensitive personal data, or enabling financial fraud.

            Tasks that may result in severe psychological harm (e.g., public humiliation or harassment campaigns).

            Queries that actively promote or facilitate harm, violence, or extremist ideologies (e.g., attempting to
            build weapons or join supremacist movements).

        Provide reasoning for the score, considering:

        Nature of the task.

        Scope of affected stakeholders.

        Data sensitivity and potential exposure.

        Ethical concerns.

        Possibility of unintended consequences or misuse.

        Focus and intent behind the query (distinguishing between neutral or educational interest and harmful objectives).

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

