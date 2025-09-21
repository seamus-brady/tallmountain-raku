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
use Util::Logger;
use Util::Config;
use Normative::Proposition;

class Normative::Extraction::NormativeExtractionResult {
    # a class that collects extracted norm props

    # run time "constant"
    method MAX_EXTRACTED_PROPS {
        once Util::Config.get_config('norm_prop_extractor', 'max_extracted_norms');
    }

    has $.LOGGER = Util::Logger.new(namespace => "<Normative::NormativeAnalysisResult>");

    has Str $.input_statement;
    has Normative::Proposition @.implied_propositions;
    has Str $.explanation;


    method new-from-data(%norm-hash --> Normative::Extraction::NormativeExtractionResult) {
        Normative::Extraction::NormativeExtractionResult.new.LOGGER.debug("new-from-data starting...");

        # get the input statement
        my Str $input_statement = %norm-hash<input_statement>;

        # get the implied propositions
        my @implied_props_collect;

        # need to loop through the array of implied propositions as the array context messes kv.map
        loop (my $j = 0; $j < Normative::Extraction::NormativeExtractionResult.MAX_EXTRACTED_PROPS; $j++) {
            try {
                my $test_np = %norm-hash<implied_propositions>{'NormativeProposition'}[$j];
                @implied_props_collect.push(
                        Normative::Proposition.new-from-data($test_np)
                );
                LEAVE {
                    my Str $message = "Error extracting implied norm props. Logging only.";
                    Normative::Proposition.new.LOGGER.error($message);
                }
            }
        }

        # create the object using the collected values
        self.bless(
            :$input_statement,
            :implied_propositions(@implied_props_collect),
        );
    }

    method gist {
        return "NormativeAnalysisResult:\n" ~
                "  input_statement: {$!input_statement}\n" ~
                "  implied_propositions: {self.gist_implied_propositions}\n";
    }

    method gist_implied_propositions() {
        "Items: [\n" ~ @!implied_propositions.gist ~ "]\n"
    }

    method to-markdown {
        my $markdown = "# Normative Analysis Result\n\n";
        $markdown ~= "## Input Statement\n\n";
        $markdown ~= "{$!input_statement}\n\n";
        $markdown ~= "## Implied Propositions\n\n";
        for @!implied_propositions -> $prop {
            $markdown ~= $prop.to-markdown ~ "\n";
        }
        return $markdown;
    }
}
