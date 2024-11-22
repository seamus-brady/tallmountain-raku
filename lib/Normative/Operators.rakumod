use v6.d;

# Modal operators, read as:
# – it is necessary that...
# – it is possible that...
# Modal operator subscripts:
# – it is logically possible that...
# – it is theoretically possible that...
# – it is practically possible that...
# In this system, this has been simplified to possible or not possible.

enum ModalOperator <POSSIBLE NOT_POSSIBLE>;

# Normative operators, read as:
# – it is required that...
# – it is ought to be that...
# – it is indifferent that...

enum NormOperator <INDIFFERENT OUGHT REQUIRED>;


class NormSubscript {
    #    This class represents numerical subscripts (e.g. R1, O2, I3)
    #    indicate that the norm is drawn from
    #    restricted, submoral considerations (etiquette, role obligations, etc.) The
    #    subscripts indicate the ordinal status of that type of norm relative to other
    #    submoral considerations. Priorities among norms of the same type or rank
    #    will be indicated with ordinal operators e.g. R2 > R2.
    #    Ethical/moral norms are always at the highest subscript.
    #
    #    Normative operators without numerical subscripts are understood to refer to
    #    moral (ethical) norms.
    #    Unsubscripted norms are implemented as the max value of int for convenience,
    #    rather than as a separate type. Here these have sys.maxsize instead.
    #    Ethical/moral norms are always at the highest subscript.
    #    This class holds that value.

    enum Type <DESIRE_FULFILMENT HYPOTHETICAL GAME ETIQUETTE ROLE_OBLIGATION CODE_OF_CONDUCT SYSTEM_INTEGRITY ETHICAL>;

    # Map enum values to numerical subscripts
    constant %VALUES = (
        DESIRE_FULFILMENT  => 3000,
        HYPOTHETICAL       => 4000,
        GAME               => 5000,
        ETIQUETTE          => 6000,
        ROLE_OBLIGATION    => 7000,
        CODE_OF_CONDUCT    => 8000,
        SYSTEM_INTEGRITY   => 9000,
        ETHICAL            => Int.max
    );

    # Retrieve the numerical value of a given type
    method value-of(Str $name) {
        my Type $type = Type::{$name} // die "Unknown NormSubscript type: $name";
        return %VALUES{$type};
    }
}


class OrdinalOperators {
    # Ordinal operators, read as:
    # – '... is subordinate to ..': <
    # – '... is superordinate to ..': >
    # – '... is coordinate to ..': <>
    # – '... is subordinate or coordinate to ..': ≤
    # – '... is superordinate or coordinate to ..': ≥
    # Ethical values are valued by R > O > I, and all others by subscript.


    # String constants
    constant SUBORDINATE = "subordinate";
    constant SUPERORDINATE = "superordinate";
    constant COORDINATE = "coordinate";
    constant SUBORDINATE_OR_COORDINATE = "subordinate_or_coordinate";
    constant SUPERORDINATE_OR_COORDINATE = "superordinate_or_coordinate";

    # General operation method
    method do-operation($npA, $npB, Str $operation) {
        if $npA.is-ethical && $npB.is-ethical {
            return OrdinalOperators.do-ethical-operation($npA, $npB, $operation);
        }
        given $operation {
            when SUBORDINATE               { $npA.get-level-n < $npB.get-level-n }
            when SUPERORDINATE             { $npA.get-level-n > $npB.get-level-n }
            when COORDINATE                { $npA.get-level-n == $npB.get-level-n }
            when SUBORDINATE_OR_COORDINATE { $npA.get-level-n <= $npB.get-level-n }
            when SUPERORDINATE_OR_COORDINATE { $npA.get-level-n >= $npB.get-level-n }
            default                        { False }
        }
    }

    # Ethical operation method
    method do-ethical-operation($npA, $npB, Str $operation) {
        given $operation {
            when SUBORDINATE               { $npA.get-norm-operator-ordinal < $npB.get-norm-operator-ordinal }
            when SUPERORDINATE             { $npA.get-norm-operator-ordinal > $npB.get-norm-operator-ordinal }
            when COORDINATE                { $npA.get-norm-operator-ordinal == $npB.get-norm-operator-ordinal }
            when SUBORDINATE_OR_COORDINATE { $npA.get-norm-operator-ordinal <= $npB.get-norm-operator-ordinal }
            when SUPERORDINATE_OR_COORDINATE { $npA.get-norm-operator-ordinal >= $npB.get-norm-operator-ordinal }
            default                        { False }
        }
    }

    # Convenience methods
    method subordinate($npA, $npB) {
        OrdinalOperators.do-operation($npA, $npB, SUBORDINATE);
    }

    method superordinate($npA, $npB) {
        OrdinalOperators.do-operation($npA, $npB, SUPERORDINATE);
    }

    method coordinate($npA, $npB) {
        OrdinalOperators.do-operation($npA, $npB, COORDINATE);
    }

    method subordinate-or-coordinate($npA, $npB) {
        OrdinalOperators.do-operation($npA, $npB, SUBORDINATE_OR_COORDINATE);
    }

    method superordinate-or-coordinate($npA, $npB) {
        OrdinalOperators.do-operation($npA, $npB, SUPERORDINATE_OR_COORDINATE);
    }
}
