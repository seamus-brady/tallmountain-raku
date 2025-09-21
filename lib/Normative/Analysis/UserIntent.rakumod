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
use Util::FilePath;
use Util::Logger;
use Normative::Agent;
use Normative::Proposition;
use LLM::Facade;
use LLM::Messages;
use Normative::UserTask;

class Normative::Analysis::UserIntent {
    has $.LOGGER = Util::Logger.new(namespace => "<Normative::Analysis::UserIntent>");

    has Str $.analysis-schema = q:to/END/;
    <?xml version="1.0" encoding="UTF-8"?>
    <xs:schema xmlns:xs="http://www.w3.org/2001/XMLSchema" elementFormDefault="qualified">

      <!-- Root element -->
      <xs:element name="UserIntentAnalysis">
        <xs:complexType>
          <xs:sequence>
            <!-- Integer User Intent Score -->
            <xs:element name="UserIntentScore" type="xs:integer">
              <xs:annotation>
                <xs:documentation>
                  Integer score representing the user's intent.
                </xs:documentation>
              </xs:annotation>
            </xs:element>

            <!-- String Analysis -->
            <xs:element name="Analysis" type="xs:string">
              <xs:annotation>
                <xs:documentation>
                  String describing the reasoning for the user intent score.
                </xs:documentation>
              </xs:annotation>
            </xs:element>
          </xs:sequence>
        </xs:complexType>
      </xs:element>

    </xs:schema>
    END

    has Str $.analysis-example = q:to/END/;
    <?xml version="1.0" encoding="UTF-8"?>
    <UserIntentAnalysis>
      <UserIntentScore>2</UserIntentScore>
      <Analysis>
        The user's intent is potentially harmful, requiring caution in response. Additional clarification is recommended.
      </Analysis>
    </UserIntentAnalysis>
    END


    method analyse(Str  $user_task --> Hash) {

        self.LOGGER.debug("Analyzing the task to get a User Intent Score (UIS)...");

        my $client = LLM::Facade.new();
        my $messages = LLM::Messages.new;

        my $prompt = qq:to/END/;
        === BACKGROUND ===

        User intent in the context of a task requested of an AI assistant refers to the underlying goal or purpose that
        the user seeks to achieve by interacting with the assistant. It encapsulates the what and why of the task, even if
        the user’s query does not explicitly detail all aspects of their intention. Identifying user intent involves
        interpreting both the explicit instructions and any implied needs to determine the most effective way to assist.

        Key Aspects of User Intent:

            Objective: The primary goal the user wants to accomplish (e.g., retrieve data, generate content, solve a problem).
            Context: Any surrounding circumstances, assumptions, or background knowledge relevant to the task.
            Constraints and Preferences: Specific requirements, limitations, or stylistic choices that guide how the task
            should be completed.

        Examples of User Intent:

            Explicit Query:
                Task: "Create a Python script to analyze sales data."
                User Intent: The user wants a functional script that processes sales data with appropriate analysis and outputs.

            Implied Query:
                Task: "What’s the weather in New York next week?"
                User Intent: The user is seeking actionable weather information, likely for planning purposes.

            Exploratory Query:
                Task: "Can AI improve customer service?"
                User Intent: The user wants insights, examples, or strategies to explore how AI could enhance customer
                support operations.

        Understanding user intent is crucial to tailoring responses effectively, ensuring relevance, accuracy, and alignment
        with the user's goals.

        === INSTRUCTIONS ===

        Evaluate the user’s intent for the user task below as a User Intent Score (UIS)

        Score the intent from 1 to 10:
        - 1–3: Likely harmful (malicious, harmful, unethical, or illegal intent).
        - 4–6: Ambiguous (unclear or dual-use potential).
        - 7–10: Likely harmless (educational, historical, or constructive purpose).

        Provide your reasoning for the score.

        Examples:

            Task: "Generate fake credentials to bypass a secure system."
                Score: 2 (Likely harmful).
                Reasoning: The intent is clearly unethical and promotes misuse.
            Task: "Explain the historical significance of the Enigma machine."
                Score: 9 (Likely harmless).
                Reasoning: The task has a clear educational and historical purpose.
            Task: "Describe the weaknesses of modern encryption systems."
                Score: 5 (Ambiguous).
                Reasoning: While educational, the information could be misused.

        === USER TASK ===
        $user_task

        END
        $messages.build-messages($prompt.trim, LLM::Messages.USER);
        my %response = $client.completion-structured-output(
                $messages.get-messages,
                $.analysis-schema,
                $.analysis-example);
        self.LOGGER.debug("Got USI result: %response");
        return %response;
    }
}

