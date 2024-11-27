use v6.d;
use LLM::Facade;
use LLM::Messages;
use Util::Config;

class Normative::ImpliedNormExtractor {
    # a class to extract implied normative propositions from a statement

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
                <xs:element name="explanation" type="xs:string" />
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
        <explanation>This analysis explains the relationship between the input and the propositions.</explanation>
    </NormativeAnalysisResult>
    END

    method extract-norm-props(Str $statement -->  Hash){
        # extract normative propositions from a statement

        my $client = LLM::Facade.new();
        my $messages = LLM::Messages.new;

        my $prompt = qq:to/END/;

        === INSTRUCTIONS ===

        Identify any implied normative propositions based on the user's values or assumptions.
        Focus on uncovering their underlying intent or perspective.
        The extracted propositions should reflect the user's implied beliefs about what should or should not be done,
        based on the context of the statement. They may not reflect societal standards or legal requirements and the
        two should not be mixed up.
        If none can be inferred, explain why, and leave this section empty.
        Extract up to {$!max_extracted_props} normative propositions. If none can be derived, state why.

        Classify Normative Propositions:

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

        Input: "Doctors must maintain patient confidentiality."
        Implied normative propositions from the user's perspective:
            "Doctors are required to protect patient privacy."
            (PROFESSIONAL_ORGANIZATIONAL / REQUIRED / POSSIBLE / PRACTICAL)
            "Patient confidentiality is required as a key ethical duty in healthcare."
            (ETHICAL_MORAL / REQUIRED / POSSIBLE / PRACTICAL)

        Input: "It’s bad manners to interrupt someone while they're speaking."
        Implied normative propositions from the user's perspective:
            "One ought not interrupt someone while they’re speaking." (ETIQUETTE / OUGHT / POSSIBLE / THEORETICAL)
            "Polite conversation ought to allow others to finish speaking." (ETIQUETTE / OUGHT / POSSIBLE / THEORETICAL)

        Input: "You have to follow the offside rule in soccer."
        Implied normative propositions from the user's perspective:
            "Players are required to follow the offside rule." (GAME / REQUIRED / POSSIBLE / PRACTICAL)
            "Following the rules is required to maintain fair play." (GAME / REQUIRED / POSSIBLE / PRACTICAL)

        Input: "Buddhists should practice ahimsa (non-violence)."
        Implied normative propositions from the user's perspective:
            "Buddhists ought to practice non-violence (ahimsa)." (CULTURAL_RELIGIOUS / OUGHT / POSSIBLE / THEORETICAL)
            "Ahimsa ought to be valued as an important cultural and religious practice in Buddhism."
            (CULTURAL_RELIGIOUS / OUGHT / POSSIBLE / THEORETICAL)

        Input: "Hello."
        Implied normative propositions from the user's perspective:
            "People ought to greet each other in social interactions." (ETIQUETTE / OUGHT / POSSIBLE / PRACTICAL)
            "Acknowledging others ought to be considered polite in social contexts." (ETIQUETTE / OUGHT / POSSIBLE / PRACTICAL)

        Input: "How do I buy illegal drugs?"
        Implied normative propositions from the user's perspective:
            "I ought to be able to buy illegal drugs as my pleasure is more important than the law."
            (PRUDENTIAL / OUGHT / POSSIBLE / THEORETICAL)

        Input: "What is the best way to cheat in an exam?"
        Implied normative propositions from the user's perspective:
            "Whatever the rules, I ought to be able to pursue my own self interest cheating on an exam if I don't
            get caught." (PRUDENTIAL / OUGHT / POSSIBLE / THEORETICAL)

        === START INPUT STATEMENT ===
        $statement
        === END INPUT STATEMENT ===
        END

        $messages.build-messages($prompt.trim, LLM::Messages.USER);
        my %response = $client.completion-structured-output(
                $messages.get-messages,
                $.norm-prop-schema,
                $.norm-prop-example);
        return %response;
    }
}
