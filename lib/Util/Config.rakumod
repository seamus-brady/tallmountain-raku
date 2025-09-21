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
use Config::Clever;
use Util::Logger;
use Util::FilePath;

class Util::ConfigException is Exception {
    has Str $.message;
}


class Util::Config {
    my Str:D constant $CONFIG_FILE = 'default';

    has $.LOGGER = Util::Logger.new(namespace => "<Util::Config>");

    method get_config(Str:D $section, Str:D $key --> Any) {
        my Hash:D %config = Config::Clever.load(
                :environment($CONFIG_FILE),
                :config-dir(Util::FilePath.new.config-path));
        # attempt to return the configuration value
        my $config-entry = %config{$section}{$key};
        if !$config-entry.defined {
            my $msg = "Configuration entry not found for section: $section, key: $key";
            Util::Config.new.error($msg);
            Util::ConfigException.new(message => $msg).throw;
        } else {
            Util::Config.new.LOGGER.debug("Loaded config entry: $section/$key - '$config-entry'");
            return $config-entry;
        }
    }
}




