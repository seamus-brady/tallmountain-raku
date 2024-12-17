#  Copyright (c) 2024. Prediction By Invention https://predictionbyinvention.com/
#
#  THIS SOFTWARE IS PROVIDED "AS IS" WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED,
#  INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A
#  PARTICULAR PURPOSE, AND NON-INFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR
#  COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES, OR OTHER LIABILITY, WHETHER
#  IN AN ACTION OF CONTRACT, TORT, OR OTHERWISE, ARISING FROM, OUT OF, OR
#  IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.

use v6.d;
use Util::Logger;
use LLM::Facade;
use LLM::Messages;

class Scanner::VulnerableUser {
    # A class to scan for vulnerable user input.

    has $.LOGGER = Util::Logger.new(namespace => "<Scanner::VulnerableUser>");
    has $.enabled = Util::Config.new.get_config('reactive_scanner_toggles', 'VulnerableUser');

    has Str $.vuln_user_schema = q:to/END/;
    <xs:schema xmlns:xs="http://www.w3.org/2001/XMLSchema">
        <xs:element name="VulnerabilityAssessment">
            <xs:complexType>
                <xs:sequence>
                    <xs:element name="VulnerabilityDetected">
                        <xs:simpleType>
                            <xs:restriction base="xs:string">
                                <xs:enumeration value="Yes" />
                                <xs:enumeration value="No" />
                            </xs:restriction>
                        </xs:simpleType>
                    </xs:element>
                    <xs:element name="ReasonForAssessment" type="xs:string" />
                    <xs:element name="RecommendedAction" type="xs:string" />
                </xs:sequence>
            </xs:complexType>
        </xs:element>
    </xs:schema>
    END

    has Str $.vuln_user_example = q:to/END/;
    <VulnerabilityAssessment>
        <VulnerabilityDetected>Yes</VulnerabilityDetected>
        <ReasonForAssessment>
            The user expressed feelings of hopelessness and mentioned self-harm. These are strong indicators of
            emotional distress and potential risk to safety.
        </ReasonForAssessment>
        <RecommendedAction>
            Please contact a crisis hotline immediately for support. Consider reaching out to a trusted family member
            or mental health professional.
        </RecommendedAction>
    </VulnerabilityAssessment>
    END

    method scan($user_prompt --> Hash) {
        if $.enabled eq "OFF" {
            $.LOGGER.info("Vulnerable user scanner is disabled.");
            # just pass back OK
            return %(
                VulnerabilityDetected => 'No',
                ReasonForAssessment => "NA",
                RecommendedAction =>"NA"
            );
        }

        $.LOGGER.error("Doing a user vulnerability scan...");
        my $client = LLM::Facade.new;
        my $messages = LLM::Messages.new;
        my $message = qq:to/END/;
        === INSTRUCTIONS ===
        - Analyze the following user input to determine if the user may be in a state of vulnerability.
        - Consider vulnerability in the broadest sense, including but not limited to:
            - Signs of emotional distress (e.g., expressing feelings of depression, anxiety, loneliness, or hopelessness).
            - Indications of self-harm or suicidal ideation.
            - Financial or personal distress (e.g., seeking help for debts, unemployment, or homelessness).
            - Exposure to abuse or violence (e.g., domestic abuse, harassment, or bullying).
            - Seeking help for physical or mental health crises.
            - Concerns related to substance abuse or addiction.
            - Any language that suggests immediate or long-term risk to the user’s safety or well-being.
        - When identifying signs of vulnerability, explain the reasoning behind the assessment and recommend
          appropriate resources or actions. If necessary, encourage the user to seek professional help or contact
          emergency services in their area. If the input does not suggest vulnerability, state why this is the case.

        === USER INPUT ===
        $user_prompt
        === END USER INPUT ===
        END

        $messages.build_messages($message.trim, LLM::Messages.USER);
        my %response = $client.completion_structured_output(
                $messages.get_messages,
                $.vuln_user_schema,
                $.vuln_user_example);
        return %response;
    }
}
