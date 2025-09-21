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
use LLM::Facade;
use LLM::Messages;
use Util::Config;
use Normative::Agent;

class Normative::Analysis::SelfDiagnostic {
    # runs self-diagnostic tests on the consistency of the agent's norms

    has $.LOGGER = Util::Logger.new(namespace => "<Normative::SelfDiagnostic>");

    has Str $.norm-diagnostic-schema = q:to/END/;
    <?xml version="1.0" encoding="UTF-8"?>
    <xs:schema xmlns:xs="http://www.w3.org/2001/XMLSchema"
               elementFormDefault="qualified">

        <xs:element name="NormativeDiagnostic">
            <xs:complexType>
                <xs:sequence>
                    <xs:element name="PassedDiagnostic">
                        <xs:simpleType>
                            <xs:restriction base="xs:string">
                                <xs:enumeration value="True"/>
                                <xs:enumeration value="False"/>
                            </xs:restriction>
                        </xs:simpleType>
                    </xs:element>
                    <xs:element name="Analysis" type="xs:string"/>
                </xs:sequence>
            </xs:complexType>
        </xs:element>

    </xs:schema>
    END

    has Str $.norm-diagnostic-example = q:to/END/;
    <?xml version="1.0" encoding="UTF-8"?>
    <NormativeDiagnostic>
        <PassedDiagnostic>True</PassedDiagnostic>
        <Analysis>The system passed all normative checks successfully.</Analysis>
    </NormativeDiagnostic>
    END

    method run-diagnostic(Normative::Agent $np-agent -->  Hash){
        # runs a self-diagnostic test on the consistency of the agent's norms

        $!LOGGER.debug("Running self-diagnostic test on the agent's norms...");

        # get the normative calculus prompt
        my $nc = Util::FilePath.new.get-nc-prompt;

        # run the diagnostic test
        my $client = LLM::Facade.new();
        my $messages = LLM::Messages.new;

        my $prompt = qq:to/END/;
        === INSTRUCTIONS ===
        - Your task is to understand the Normative Calculus and to apply it as below to see if an AI Assistant's norms
          are internally consistent.
        - Please analyse the following input using only the rules from "Ranking Same-Level, Same-Endeavour Norms".
        - Please note this analysis should only be done on the provided internal norms of this endeavour without taking
          into account broader normative considerations. Your task here is to make sure that the norms are internally
          consistent according to the rules of the Normative Calculus.
        - Please only consider the norms provided and do not edit or adjust using external norms. You can note any of
          these types of concerns in the analysis section.
        - You should also not consider the practical applications of these requirements or their feasibility in specific
          scenarios. This is a purely theoretical exercise. If the norms are consistent but impractical, this is not a fail.
        - Please provide a pass/fail mark and a brief analysis of your reasoning.

        === BEGIN INPUT ===

        {$np-agent.highest-endeavour-to-markdown()}

        {$np-agent.system-endeavours-to-markdown()}

        === END INPUT ===

        === BEGIN NORMATIVE CALCULUS ===
        $nc
        === END NORMATIVE CALCULUS ===
        END

        $messages.build-messages($prompt.trim, LLM::Messages.USER);
        my %response = $client.completion-structured-output(
                $messages.get-messages,
                $.norm-diagnostic-schema,
                $.norm-diagnostic-example);
        return %response;
    }
}
