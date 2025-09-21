#  MIT License
#  
#  Copyright (c) 2024 seamus@corvideon.ie
#  
#  Permission is hereby granted, free of charge, to any person obtaining a copy
#  of this software and associated documentation files (the "Software"), to deal
#  in the Software without restriction, including without limitation the rights
#  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
#  copies of the Software, and to permit persons to whom the Software is
#  furnished to do so, subject to the following conditions:
#  
#  The above copyright notice and this permission notice shall be included in all
#  copies or substantial portions of the Software.
#  
#  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
#  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
#  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
#  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
#  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
#  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
#  SOFTWARE.

use v6.d;
use Logger;

class Util::Logger {

    has Str $!namespace;
    has Logger $!logger;

    submethod BUILD(Str:D :$namespace) {
        $!namespace = $namespace;
        $!logger = self!init_logger();
    }

    method trace(Str:D $message) {
        $!logger.trace("[$!namespace] - $message");
    }

    method debug(Str:D $message) {
        $!logger.debug("[$!namespace] - $message");
    }

    method info(Str:D $message) {
        $!logger.info("[$!namespace] - $message");
    }

    method warn(Str:D $message) {
        $!logger.warn("[$!namespace] - $message");
    }

    method error(Str:D $message) {
        $!logger.error("[$!namespace] - $message");
    }

    method !init_logger() {
        return Logger.new(
                level => Logger::DEBUG,
                output => $*OUT,
                dt-formatter => -> $dt { sprintf "%sT%s", .dd-mm-yyyy, .hh-mm-ss given $dt });
    }
}
