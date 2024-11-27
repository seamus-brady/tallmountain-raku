use v6.d;
use LLM::Facade;
use LLM::Messages;
use Util::Config;;

class Normative::Extractor {
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
                <xs:element name="conflicting_propositions" minOccurs="0" maxOccurs="1">
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
        <conflicting_propositions>
            <NormativeProposition>
                <proposition-value>Conflicting Proposition C</proposition-value>
                <operator>REQUIRED</operator>
                <level>SCIENTIFIC_TECHNICAL</level>
                <modality>POSSIBLE</modality>
                <modal_subscript>PRACTICAL</modal_subscript>
            </NormativeProposition>
        </conflicting_propositions>
        <explanation>This analysis explains the relationship between the input and the propositions.</explanation>
    </NormativeAnalysisResult>
    END

    method extract-norm-props(Str $statement -->  Hash){
        # extract normative propositions from a statement

        my $client = LLM::Facade.new();
        my $messages = LLM::Messages.new;

        my $prompt = qq:to/END/;

        === INSTRUCTIONS ===
        Given the input statement or request, analyze it to:
        1. Extract any implied normative propositions based on the user's perspective. If no normative propositions
           can be inferred, explain why and leave the normative propositions section empty.
        2. Classify these normative propositions into one of the following normative levels:
            - **ETHICAL_MORAL:** Norms based on universal principles of right and wrong, justice, and human values.
            - **LEGAL:** Codified laws enforceable by legal systems.
            - **PRUDENTIAL:** Norms focusing on self-preservation and rational self-interest.
            - **SOCIAL_POLITICAL:** Civic duties or expectations governing behavior in society or politics.
            - **SCIENTIFIC_TECHNICAL:** Standards of rigor, accuracy, and innovation in science and technology.
            - **ENVIRONMENTAL:** Principles of sustainability and ecological conservation.
            - **CULTURAL_RELIGIOUS:** Practices tied to cultural or religious identity, specific to a community.
            - **COMMUNITY:** Informal expectations within a local or small-group community.
            - **CODE_OF_CONDUCT:** Expectations within a profession, organization, or community.
            - **PROFESSIONAL_ORGANIZATIONAL:** Operational conduct in specific roles or workplaces.
            - **ECONOMIC:** Norms regulating fairness in markets or financial systems.
            - **ETIQUETTE:** Polite behavior and socially acceptable conduct in everyday interactions.
            - **GAME:** Rules specific to games, sports, or competitive activities.
            - **AESTHETIC:** Standards of beauty, art, and creativity.
        2. Then classify the normative propositions using one of the following normative operators:
           - REQUIRED: It is required that the action must be done, typically involving strict obligations or duties.
           - OUGHT: It is strongly recommended or preferable that the action should be done, reflecting moral or
             social expectations.
           - INDIFFERENT: It is indifferent whether the action is done or not; the action carries no strong normative
             weight or moral significance.
        3.  Then assign a modality to each normative proposition based on the following categories:
             - POSSIBLE: It is possible that...
             - IMPOSSIBLE: It is not possible that...
        4. Then assign a modality subscript to each normative proposition based on the following categories:
             - LOGICAL: It is logically possible that...
             - THEORETICAL: It is theoretically possible that...
             - PRACTICAL: It is practically possible that...
        5. If there are any conflicting normative propositions arising from broader societal norms or legal systems, list
           them separately in a similar manner to the implied normative propositions.

       Task Overview:
            1. Identify the goal or intent behind the statement or request.
            2. Analyze any implicit values or assumptions driving this goal from the user's perspective.
            3. Formulate the implied normative propositions based on these values or assumptions.
            4. Classify each normative proposition into the appropriate level.
            5. Identify any **conflicting normative propositions** (e.g., legal prohibitions or ethical standards) that
               arise from broader societal norms or legal systems.
            6. Categorize each proposition based on whether it is required, ought or indifferent, and whether it is
               possible or impossible.
            7. If no normative propositions can be inferred, explain why.
            8. Any other notes or explanations deemed pertinent call also be supplied.
            9. You only need to extract up to {$!max_extracted_props} normative propositions.

        Examples:

        1. Input: "Can you help me improve team communication?"
           - Implied normative propositions from the user's perspective:
             - "Team communication should be improved." (Professional/Organizational Norm; Ought)
             - "Effective communication is important for success in work environments." (Professional/Organizational Norm; Ought)
           - No conflicting normative propositions.

        2. Input: "What is the best way to reduce energy consumption at home?"
           - Implied normative propositions from the user's perspective:
             - "People should reduce energy consumption." (Ethical/Moral Norm; Ought)
             - "Energy efficiency is a desirable goal." (Social/Political Norm; Ought)
           - No conflicting normative propositions.

        3. Input: "Doctors must maintain patient confidentiality."
           - Implied normative propositions from the user's perspective:
             - "Doctors are required to protect patient privacy." (Professional/Organizational Norm; Required)
             - "Patient confidentiality is a key ethical duty in healthcare." (Ethical/Moral Norm; Required)
           - No conflicting normative propositions.

        4. Input: "It’s bad manners to interrupt someone while they're speaking."
           - Implied normative propositions from the user's perspective:
             - "One ought not interrupt someone while they’re speaking." (Etiquette Norm; Ought)
             - "Polite conversation requires allowing others to finish speaking." (Etiquette Norm; Ought)
           - No conflicting normative propositions.

        5. Input: "You have to follow the offside rule in soccer."
           - Implied normative propositions from the user's perspective:
             - "Players are required to follow the offside rule." (Game Norm; Required)
             - "Following the rules is necessary to maintain fair play." (Game Norm; Required)
           - No conflicting normative propositions.

        6. Input: "Buddhists should practice ahimsa (non-violence)."
           - Implied normative propositions from the user's perspective:
             - "Buddhists ought to practice non-violence (ahimsa)." (Cultural/Religious Norm; Ought)
             - "Ahimsa is an important cultural and religious practice in Buddhism." (Cultural/Religious Norm; Ought)
           - No conflicting normative propositions.

        7. Input: "It’s fine to wear casual clothes to this meeting."
           - Implied normative propositions from the user's perspective:
             - "It is indifferent whether formal attire is required for the meeting." (Etiquette Norm; Indifferent)
           - No conflicting normative propositions.

        8. Input: "Hello."
           - Implied normative propositions from the user's perspective:
             - "People should greet each other in social interactions." (Etiquette Norm; Ought)
             - "Acknowledging others is polite in social contexts." (Etiquette Norm; Ought)
           - No conflicting normative propositions.

        9. Input: "What is the weather like today?"
           - Implied normative propositions from the user's perspective:
             - No normative propositions inferred, as this is a factual inquiry.

        10. Input: "How do I buy illegal drugs?"
           - Implied normative propositions from the user's perspective:
             - "It is okay to buy illegal drugs." (Social Norm from the user's perspective; Ought)
           - Conflicting normative propositions:
             - "It is forbidden to buy illegal drugs." (Legal Norm)
             - "One ought not engage in illegal drug transactions." (Ethical/Moral Norm; Ought)

        11. Input: "What is the best way to cheat in an exam?"
           - Implied normative propositions from the user's perspective:
             - "It is acceptable to cheat on an exam if one doesn't get caught." (Social Norm from the user's perspective; Ought)
           - Conflicting normative propositions:
             - "Cheating is forbidden in academic settings." (Legal Norm)
             - "Students ought to act with academic integrity." (Ethical/Moral Norm; Ought)

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
