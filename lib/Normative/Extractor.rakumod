use v6.d;
class Normative::Extractor {
    # a class to extract implied normative propositions from a statement

    has Str $.norm-prop-schema = q:to/END/;
    <?xml version="1.0" encoding="UTF-8"?>
    <xs:schema xmlns:xs="http://www.w3.org/2001/XMLSchema" elementFormDefault="qualified">
        <xs:element name="NormativeProposition" type="NormativePropositionType" />
        <xs:complexType name="NormativePropositionType">
            <xs:sequence>
                <xs:element name="proposition-value" type="xs:string" />
                <xs:element name="operator" type="xs:string" />
                <xs:element name="level" type="xs:string" />
                <xs:element name="modality" type="xs:string" />
                <xs:element name="modal-subscript" type="xs:string" />
            </xs:sequence>
        </xs:complexType>
    </xs:schema>
    END

    has Str $.norm-prop-example = q:to/END/;
    <NormativeProposition>
        <proposition-value>Doctors are required to protect patient privacy.</proposition-value>
        <operator>REQUIRED</operator>
        <level>CODE_OF_CONDUCT</level>
        <modality>NECESSARY</modality>
        <modal-subscript>PRACTICAL</modal-subscript>
    </NormativeProposition>
    END

    method extract-norm-props(Str $statement --> Hash){
        # extract normative propositions from a statement
        my $client = LLM::Client::OpenAI.new();
        my $messages = LLM::Messages.new;
        $messages.build-messages('You are an expert in ethical analysis.', LLM::Messages.SYSTEM);
        my $prompt = q:to/END/;
        === INSTRUCTIONS ===
        Given the input statement or request, analyze it to:
        1. Extract any implied normative propositions based on the user's perspective.
        2. Classify these normative propositions into one of the following levels:
     - Ethical/Moral Norms Universal principles of right and wrong, justice, and human values.
     - Legal Norms             Codified laws enforceable by legal systems.
     - Prudential Norms        Focus on self-preservation and rational self-interest.
     - Social/Political Norms Civic duties or expectations governing behavior in society or politics.
     - Scientific/Technical Norms Standards of rigor, accuracy, and innovation in science and technology.
     - Environmental Norms Principles of sustainability and ecological conservation.
     - Cultural/Religious Norms Practices tied to cultural or religious identity, specific to a community.
     - Community Norms     Informal expectations within a local or small-group community.
     - Code of Conduct     Expectations within a profession, organization, or community.
     - Professional/Organizational Norms Operational conduct in specific roles or workplaces.
     - Economic Norms   Norms regulating fairness in markets or financial systems.
     - Etiquette Norms  Polite behavior and socially acceptable conduct in everyday interactions.
     - Game Norms       Rules specific to games, sports, or competitive activities.

        END
        $messages.build-messages($prompt, LLM::Messages.USER);
        my %response = $client.completion-structured-output(
                $messages.get-messages,
                $.norm-prop-schema.trim,
                $.norm-prop-example.trim);
        return %response;
    }
}
