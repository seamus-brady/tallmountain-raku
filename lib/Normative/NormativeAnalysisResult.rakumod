use v6.d;

class  Normative::NormativePropositionResult {
    has Str $.level;
    has Str $.modal_subscript;
    has Str $.modality;
    has Str $.operator;
    has Str $.proposition-value;
}

class  Normative::NormativeAnalysisResult {
    has Str $.input_statement;
    has  Normative::NormativePropositionResult @.implied_propositions;
    has  Normative::NormativePropositionResult @.conflicting_propositions;
    has Str $.explanation;

    method new-from-hash(%hash) {
        self.bless(
                input_statement          => %hash<input_statement>,
                explanation              => %hash<explanation>,
                implied_propositions     => self.parse-propositions(%hash<implied_propositions>),
                conflicting_propositions => self.parse-propositions(%hash<conflicting_propositions>),
                );
    }

    method parse-propositions($propositions-hash) {
        my @propositions;
        my $prop-hash = $propositions-hash<Normative::NormativePropositionResult>;
        # Check if it's a single proposition or an array
        if $prop-hash ~~ Array {
            for $prop-hash -> $prop {
                @propositions.push: Normative::NormativePropositionResult.new(|$prop);
            }
        } else {
            @propositions.push: Normative::NormativePropositionResult.new(|$prop-hash);
        }
        return @propositions;
    }
}
