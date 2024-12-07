use v6.d;
use UUID::V4;
use Normative::Proposition;
use Normative::Comprehensiveness;

role Normative::Role::Endeavour {
    #  An endeavour of an agent. Manages a set of NormProps.

    has Str $.name;
    has Str $.goal;
    has Str $.description;
    has Str $.uuid = uuid-v4();
    has Normative::Comprehensiveness $.comprehensiveness = Normative::Comprehensiveness::DEFAULT;
    has Normative::Proposition @.normative-propositions;

    method gist {
        return qq:to/END_GIST/;
        ----
        Endeavour name: {$!name}
        description: {$!description}
        goal: {$!goal}
        comprehensiveness: {$!comprehensiveness}
        normative_propositions: {@!normative-propositions.gist}
        ----
        END_GIST
    }



    method to-markdown {
        my $endeavour_heading = "# Endeavour: {$!name // "Unnamed Endeavour"}\n";
        my $endeavour_table = qq:to/END_ENDEAVOUR_TABLE/;
        | **Property**         | **Value**                         |
        |-----------------------|-----------------------------------|
        | Name                 | {$!name}   |
        | Goal                 | {$!goal}   |
        | Description          | {$!description} |
        | UUID                 | {$!uuid}                         |
        | Comprehensiveness    | {$!comprehensiveness}            |
        END_ENDEAVOUR_TABLE

        my $propositions_heading = "## Normative Propositions for Endeavour: {$!name // "Unnamed Endeavour"}\n";
        my $propositions_table = "| **Proposition** | **Operator** | **Level** | **Modality** | **Modal Subscript** | **Description** |\n";
        $propositions_table ~= "|------------------|--------------|-----------|--------------|--------------------|-----------------|\n";

        for @!normative-propositions -> $np {
            $propositions_table ~= "| {$np.proposition-value // ''} "
                    ~ "| {$np.operator // ''} "
                    ~ "| {$np.level // ''} "
                    ~ "| {$np.modality // ''} "
                    ~ "| {$np.modal-subscript // ''} "
                    ~ "| {$np.description // ''} |\n";
        }

        return $endeavour_heading ~ "\n" ~ $endeavour_table ~ "\n\n" ~ $propositions_heading ~ "\n" ~ $propositions_table;
}

}
