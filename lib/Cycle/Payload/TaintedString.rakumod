use v6.d;

class Cycle::TaintedString {
    # A class that wraps incoming untrusted string based communications.
    has Str $.payload;
}
