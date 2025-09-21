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
use LLM::Facade;
use LLM::Messages;
use Normative::Risk::RiskEntry;

class Normative::Risk::RiskProfile {
    # a class to hold a list of RiskEntry objects

    # Declare an attribute to hold a list of RiskEntry objects
    has @.data;

    # Method to add a new entry to the data list
    method add-entry(%entry) {
        @!data.push(Normative::Risk::RiskEntry.new(|%entry));
    }

    # Method to remove an entry at a specific index
    method remove-entry(Int $index) {
        # Check if the index is valid
        die "Invalid index" unless $index >= 0 && $index < @!data.elems;
        # Remove the entry at the specified index
        @!data.splice($index, 1);
    }

    # Method to retrieve an entry by its index
    method get-entry(Int $index) {
        # Check if the index is valid
        die "Invalid index" unless $index >= 0 && $index < @!data.elems;
        # Return the entry at the specified index
        @!data[$index];
    }

    method get-all-risk-scores() {
        # gets an array of all risk scores for each norm prop
        return @!data.map(*.RiskScore);
    }

    method get-all-risk-levels() {
        # gets an array of all risk levels for each norm prop
        return @!data.map(*.RiskLevel);
    }

    # Method to list all entries in the data
    method list-entries {
        # Return the complete list of data entries
        return @!data;
    }

    method to-markdown(--> Str) {
        my $output = "| Index | Analysis               | ContextMultiplier | ImpactScore | Likelihood | NormAlignmentScore | RiskLevel  | RiskScore | UserNormPropValue                          |\n";
        $output ~= "|-------|------------------------|-------------------|-------------|------------|--------------------|------------|-----------|-------------------------------------------|\n";
        for @!data.kv -> $index, $entry {
            $output ~= "| $index  | {$entry.Analysis}             | {$entry.ContextMultiplier}            | {$entry.ImpactScore}       | {$entry.Likelihood}       | {$entry.NormAlignmentScore}             | {$entry.RiskLevel}       | {$entry.RiskScore}       | {$entry.UserNormPropValue}                           |\n";
        }
        return $output;
    }
}
