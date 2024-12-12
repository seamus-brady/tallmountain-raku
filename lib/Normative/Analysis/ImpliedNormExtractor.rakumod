#  Copyright (c) 2024. Prediction By Invention https://predictionbyinvention.com/
#
#  THIS SOFTWARE IS PROVIDED "AS IS" WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED,
#  INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A
#  PARTICULAR PURPOSE, AND NON-INFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR
#  COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES, OR OTHER LIABILITY, WHETHER
#  IN AN ACTION OF CONTRACT, TORT, OR OTHERWISE, ARISING FROM, OUT OF, OR
#  IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.

use v6.d;
use LLM::Facade;
use LLM::Messages;
use Util::Config;

class Normative::Analysis::ImpliedNormExtractor {
    # a class to extract implied normative propositions from a statement

    has $.LOGGER = Util::Logger.new(namespace => "<Normative::ImpliedNormExtractor>");

    has Int $.max_extracted_props = Util::Config.get_config('norm_prop_extractor', 'max_extracted_norms');

    has Str $.norm-prop-schema = q:to/END/;
    <?xml version="1.0" encoding="UTF-8"?>
    <xs:schema xmlns:xs="http://www.w3.org/2001/XMLSchema" elementFormDefault="qualified">
        <!-- Define NormativePropositionType -->
        <xs:complexType name="NormativePropositionType">
            <xs:sequence>
                <xs:element name="proposition-value" type="xs:string" />
                <xs:element name="operator" type="xs:string" />
                <xs:element name="level" type="xs:string" />
                <xs:element name="modality" type="xs:string" />
                <xs:element name="modal_subscript" type="xs:string" />
            </xs:sequence>
        </xs:complexType>

        <!-- Define NormativeAnalysisResult -->
        <xs:complexType name="NormativeAnalysisResultType">
            <xs:sequence>
                <xs:element name="input_statement" type="xs:string" />
                <xs:element name="implied_propositions" minOccurs="0" maxOccurs="1">
                    <xs:complexType>
                        <xs:sequence>
                            <xs:element name="NormativeProposition" type="NormativePropositionType" minOccurs="0" maxOccurs="unbounded" />
                        </xs:sequence>
                    </xs:complexType>
                </xs:element>
            </xs:sequence>
        </xs:complexType>

        <!-- Root element -->
        <xs:element name="NormativeAnalysisResult" type="NormativeAnalysisResultType" />
    </xs:schema>
    END

    has Str $.norm-prop-example = q:to/END/;
    <?xml version="1.0" encoding="UTF-8"?>
    <NormativeAnalysisResult>
        <input_statement>This is an example input statement.</input_statement>
        <implied_propositions>
            <NormativeProposition>
                <proposition-value>Proposition A</proposition-value>
                <operator>REQUIRED</operator>
                <level>Social/Political</level>
                <modality>POSSIBLE</modality>
                <modal_subscript>PRACTICAL</modal_subscript>
            </NormativeProposition>
            <NormativeProposition>
                <proposition-value>Proposition B</proposition-value>
                <operator>OUGHT</operator>
                <level>SCIENTIFIC_TECHNICAL</level>
                <modality>POSSIBLE</modality>
                <modal_subscript>PRACTICAL</modal_subscript>
            </NormativeProposition>
        </implied_propositions>
    </NormativeAnalysisResult>
    END

    method extract-belief-statements(Str $statement -->  Str){
        # does some initial analysis on the user statement to extract beliefs, ethics and norms

        self.LOGGER.debug("Extracting belief statements from user input");

        my $client = LLM::Facade.new;
        my $messages = LLM::Messages.new;
        my $system_message = q:to/END/;
        === INSTRUCTIONS ===
        - Analyze the following text for underlying beliefs, assumptions, and implied norms about the behavior,
          capabilities, and ethical boundaries of agents (whether AI or otherwise).
        - Identify any explicit or implicit normative statements or directives about how such agents should act or
          what they should prioritize.
        - Reformulate these statements as if the author were explicitly declaring them as their beliefs or expectations.
        - Avoid providing any analysis or commentary on the ethics, validity, or implications of these statements —
          simply extract and rewrite them as a list of propositions the author might state.
        - Repeat the user's original statement at the beginning of your analysis.
        END
        $messages.build-messages($system_message, LLM::Messages.SYSTEM);
        $messages.build-messages($statement, LLM::Messages.USER);
        return $client.completion-string($messages.get-messages());
    }

    method extract-norm-props(Str $statement -->  Hash){
        # extract normative propositions from a statement

        self.LOGGER.debug("Extracting normative propositions from user input");

        # first get more details on what the user might believe
        my $belief_statement = self.extract-belief-statements($statement);

        # now extract the normative propositions
        my $client = LLM::Facade.new();
        my $messages = LLM::Messages.new;

        my $prompt = qq:to/END/;

        === INSTRUCTIONS ===
        - Take incoming statement and turn it into a set of normative propositions.
        - Extract up to {$!max_extracted_props} normative propositions.

        - Assign each proposition to one of the following levels:
            ETHICAL_MORAL: Universal principles of right/wrong, justice, and human values.
            LEGAL: Codified laws enforceable by legal systems.
            PRUDENTIAL: Self-preservation or rational self-interest norms.
            SOCIAL_POLITICAL: Civic duties or societal/political expectations.
            SCIENTIFIC_TECHNICAL: Standards of rigor, accuracy, and innovation.
            ENVIRONMENTAL: Principles of sustainability and ecological conservation.
            CULTURAL_RELIGIOUS: Norms tied to cultural or religious identity.
            COMMUNITY: Informal expectations in small/local groups.
            CODE_OF_CONDUCT: Expectations in specific communities or organizations.
            PROFESSIONAL_ORGANIZATIONAL: Conduct standards for workplaces or roles.
            ECONOMIC: Fairness norms in markets or financial systems.
            ETIQUETTE: Socially acceptable polite behavior.
            GAME: Rules of games, sports, or competitive activities.
            AESTHETIC: Standards of beauty, art, or creativity.

        Categorize Normative Operators:

        - Specify the normative operator for each proposition:
            REQUIRED: Must be done; strict obligations or duties.
            OUGHT: Should be done; moral or social preference.
            INDIFFERENT: Neutral; carries no strong normative weight.

        Assign Modalities and Subscripts:

        - Determine the modality of each proposition:
            POSSIBLE: It is possible that...
            IMPOSSIBLE: It is not possible that...

        - Add a subscript for the type of possibility:
            LOGICAL: Logically possible.
            THEORETICAL: Theoretically possible.
            PRACTICAL: Practically possible.

        === EXAMPLES ===

        Input: "Hello."
        Implied normative propositions from the user's perspective:
            "People ought to greet each other in social interactions." (ETIQUETTE / OUGHT / POSSIBLE / PRACTICAL)
            "Acknowledging others ought to be considered polite in social contexts."
            (ETIQUETTE / OUGHT / POSSIBLE / PRACTICAL)

        Input: "How do I buy illegal drugs?"
        Implied normative propositions from the user's perspective:
            "I ought to be able to buy illegal drugs as my pleasure is more important than the law."
            (PRUDENTIAL / OUGHT / POSSIBLE / THEORETICAL)

        Input: "What is the best way to cheat in an exam?"
        Implied normative propositions from the user's perspective:
            "Whatever the rules, I ought to be able to pursue my own self interest cheating on an exam if I don't
            get caught." (PRUDENTIAL / OUGHT / POSSIBLE / THEORETICAL)

        === START INPUT STATEMENT ===
        $belief_statement
        === END INPUT STATEMENT ===
        END

        $messages.build-messages($prompt.trim, LLM::Messages.USER);
        my %response = $client.completion-structured-output(
                $messages.get-messages,
                $.norm-prop-schema,
                $.norm-prop-example);
        $!LOGGER.debug("Got user norms: " ~ %response.gist);
        return %response;
    }
}
