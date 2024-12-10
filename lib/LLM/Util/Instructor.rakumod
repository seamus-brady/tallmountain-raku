#  Copyright (c) 2024. Prediction By Invention https://predictionbyinvention.com/
#
#  THIS SOFTWARE IS PROVIDED "AS IS" WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED,
#  INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A
#  PARTICULAR PURPOSE, AND NON-INFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR
#  COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES, OR OTHER LIABILITY, WHETHER
#  IN AN ACTION OF CONTRACT, TORT, OR OTHERWISE, ARISING FROM, OUT OF, OR
#  IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.

use v6.d;

use LibXML;
use LibXML::Document;
use LibXML::Enums;
use LibXML::Schema;
use Util::Logger;

class LLM::Util::Instructor {

    # based on the same idea as the Python Instructor library, this class provides utility functions to get
    # structured data from an LLM using an XML schema

    has $.LOGGER = Util::Logger.new(namespace => "<LLM::Util::Instructor>");

    method is-valid-xml(Str $xml_string is copy, Str $xml-schema is copy --> Bool) {
        self.LOGGER.debug("Checking if the xml is valid");
        try {
            my $xmlschema = LibXML::Schema.new(string => $xml-schema);
            my $xml-doc = LibXML.new.parse: :string($xml_string);
            return $xmlschema.is-valid($xml-doc);
            CATCH {
                # also catch any invalid xml
                default {
                    say $xml_string;
                    my $error = $_;
                    self.LOGGER.error("Exception caught: $error");
                    return Bool::False;
                }
            }
        }
    }


    method remove-code-block-markers(Str $llm_response_text is copy --> Str) {
        # remove the code block markers from the text -  "```xml" and "```"
        my $cleaned_text = $llm_response_text.lines.grep({ !/^^ \s* '```' [xml]? \s* $/ }).join("\n");
        return $cleaned_text;
    }

    method strip-xml-declaration(Str $xml_string is copy --> Str) {
        # removes the xml declaration from the xml string
        my $cleaned_xml_string = $xml_string.subst(/ ^^ \s* '<?xml' .*? '?>' \s* /, '', :g);
        return $cleaned_xml_string;
    }


    method hash-from-xml(Str $xml_string is copy --> Hash) {
        # convert an xml string into a Raku hash
        return from-xml($xml_string);
    }

    ################################################################################
    # the code below is taken from https://github.com/jonathanstowe/XML-Fast
    # and are copyright to the author of that module
    # the original module does not install correctly hence this intervention
    # these methods provide a way to turn an xml doc into a Raku hash
    ################################################################################

    multi sub from-xml(Str $xml_string) is export {
        my $doc = LibXML::Document.parse($xml_string);
        my $root = $doc.root;
        from-xml($root);
    }

    multi sub from-xml(
            LibXML::Element $node where -> $n { ($n.firstChild !~~ LibXML::Text && $n.firstChild !~~ LibXML::CDATA)
                    || $n.firstChild.isBlank || $n.attributes.elems }) is export {
        my %new_hash;
        my $attrs = $node.attributes;
        for $attrs.kv -> $attr-name, $attr-value {
            %new_hash{$attr-name} = $attr-value.value;
        }
        my @nodes = $node.children(:!blank);
        for @nodes -> $child {
            my $hash = from-xml($child);
            %new_hash.push: { $child.localname => $hash };
        }
        return %new_hash;
    }

    multi sub from-xml(LibXML::Element $node where -> $n {$n.firstChild.nodeType == XML_TEXT_NODE &&
            !$n.firstChild.isBlank && !$n.attributes.elems}) is export {
        from-xml($node.firstChild);
    }

    multi sub from-xml(LibXML::Element $node where -> $n {$n.firstChild ~~ LibXML::CDATA }) is export {
        from-xml($node.firstChild);
    }

    multi sub from-xml(LibXML::Text $node ) is export {
        my $value = $node.nodeValue;
        Numeric($value) || $value;
    }

    multi sub from-xml(LibXML::CDATA $node) is export {
        $node.nodeValue;
    }

    ################################################################################
}
