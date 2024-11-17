use v6.d;

class StringBuffer {
    has Str $!buffer;

    method add(Str $text) {
        $!buffer = '' unless $!buffer.defined;
        $!buffer ~= $text;
    }

    method get() {
        return $!buffer // '';
    }

    method clear() {
        $!buffer = '';
    }
}

