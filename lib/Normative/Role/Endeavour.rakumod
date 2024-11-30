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
        Endeavour name: {$!name // "No name provided"}
        description: {$!description // "No description provided"}
        goal: {$!goal // "No goal provided"}
        comprehensiveness: {$!comprehensiveness}
        normative_propositions: {@!normative-propositions.gist}
        ----
        END_GIST
    }
}
