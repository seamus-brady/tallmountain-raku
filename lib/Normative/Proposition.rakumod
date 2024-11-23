use v6.d;
use UUID::V4;

class Normative::Proposition {
    # A normative proposition

    has Str $.uuid = uuid-v4();
    has Str $.proposition-value is required;
    # TODO add endeavour
    has Normative::NormOperator $.operator is required;
    has Normative::NormLevel $.level is required;
    has Normative::Modality $.modality is required;
    has Normative::ModalitySubscript $.modal-subscript is required;
}
