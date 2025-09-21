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
use Util::Config;
use LLM::Role::Client;
use LLM::Client::OpenAI;
use LLM::AdaptiveRequestMode;

class LLM::Facade {
    # calls the default LLM provider

    has Str $.default_client = Util::Config.get_config('llm', 'default_llm_provider');
    has LLM::Role::Client $.client;

    has $.LOGGER = Util::Logger.new(namespace => "<LLM::Facade>");

    submethod TWEAK() {
        given $!default_client {
            when "open_ai" {
                $!LOGGER.info("Using OpenAI as the default provider");
                $!client = LLM::Client::OpenAI.new();
            }
            default {
                # OpenAI is the default provider :)
                $!LOGGER.info("Using OpenAI as the default provider");
                $!client = LLM::Client::OpenAI.new();
            }
        }
    }

    method completion-string(
            @messages,
            LLM::AdaptiveRequestMode $mode = LLM::AdaptiveRequestMode.balanced-mode
            --> Str) {
            return $.client.completion-string(@messages, $mode);
    }

    method completion-structured-output(
            @messages is copy,
            Str $xml-schema is copy,
            Str $xml-example is copy,
            LLM::AdaptiveRequestMode $mode = LLM::AdaptiveRequestMode.balanced-mode
            --> Hash) {
            return $.client.completion-structured-output(@messages, $xml-schema, $xml-example, $mode);
    }
}