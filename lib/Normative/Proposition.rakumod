use v6.d;
use UUID::V4;

class Normative::Proposition {
    has Str $.uuid = uuid-v4();
    has Str $.proposition-value;

    has Normative::NormOperator $.norm-operator;
    has Int $.norm-subscript;
    has Normative::ModalOperator $.modal-operator;
}
