use v6.d;

# Modal operators, read as:
# – it is necessary that...
# – it is possible that...
enum Modality <NECESSARY POSSIBLE NOT_NECESSARY NOT_POSSIBLE>;

# Modal operator subscripts:
# – it is logically possible that...
# – it is theoretically possible that...
# – it is practically possible that...
enum ModalitySubscript <LOGICAL THEORETICAL PRACTICAL NONE>;

# Normative operators, read as:
# – it is required that...
# – it is ought to be that...
# – it is indifferent that...
enum NormOperator (INDIFFERENT => 1, OUGHT => 2, REQUIRED => 3);

# Norm Category       Ordinal Level    Description
# Ethical/Moral Norms 10000        Universal principles of right and wrong, justice, and human values.
# Legal Norms         5000             Codified laws enforceable by legal systems.
# Prudential Norms    4500             Focus on self-preservation and rational self-interest.
# Social/Political Norms 4000         Civic duties or expectations governing behavior in society or politics.
# Scientific/Technical Norms 3500     Standards of rigor, accuracy, and innovation in science and technology.
# Environmental Norms 3250            Principles of sustainability and ecological conservation.
# Cultural/Religious Norms 3000       Practices tied to cultural or religious identity, specific to a community.
# Community Norms     2750            Informal expectations within a local or small-group community.
# Code of Conduct     2500            Expectations within a profession, organization, or community.
# Professional/Organizational Norms 2000 Operational conduct in specific roles or workplaces.
# Economic Norms      2250            Norms regulating fairness in markets or financial systems.
# Etiquette Norms     1500            Polite behavior and socially acceptable conduct in everyday interactions.
# Game Norms          1000            Rules specific to games, sports, or competitive activities.
# Aesthetic Norms      500            Standards of beauty, art, and creativity.
enum NormLevel(
    ETHICAL_MORAL => 10000,
    LEGAL => 5000,
    PRUDENTIAL => 4500,
    SOCIAL_POLITICAL => 4000,
    SCIENTIFIC_TECHNICAL => 3500,
    ENVIRONMENTAL => 3250,
    CULTURAL_RELIGIOUS => 3000,
    COMMUNITY => 2750,
    CODE_OF_CONDUCT => 2500,
    PROFESSIONAL_ORGANIZATIONAL => 2000,
    ECONOMIC => 2250,
    ETIQUETTE => 1500,
    GAME => 1000,
    AESTHETIC => 500
);

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
