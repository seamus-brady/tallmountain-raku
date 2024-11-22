use v6.d;
use UUID::V4;

role Normative::Role::Endeavour {
    #  An endeavour of an agent. Manages a set of NormProps.

    has Str $.name;
    has Str $.uuid = uuid-v4();
}
