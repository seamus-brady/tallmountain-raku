#  Copyright (c) 2024. Prediction By Invention https://predictionbyinvention.com/
#
#  THIS SOFTWARE IS PROVIDED "AS IS" WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED,
#  INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A
#  PARTICULAR PURPOSE, AND NON-INFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR
#  COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES, OR OTHER LIABILITY, WHETHER
#  IN AN ACTION OF CONTRACT, TORT, OR OTHERWISE, ARISING FROM, OUT OF, OR
#  IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.

use v6.d;
use Util::Config;
use Util::Logger;
use Normative::Analysis::RiskProfile;
use LLM::Messages;
use LLM::Facade;

class Normative::Analysis::RiskAnalyser {
    # This class is responsible for analysing the risk profile and providing a recommendation

    has $.LOGGER = Util::Logger.new(namespace => "<Normative::Analysis::RiskAnalyser>");

    our constant ACCEPT_AND_EXECUTE = "Accept and Execute";
    our constant SUGGEST_MODIFICATION = "Suggest Modification";
    our constant REJECT = "Reject";

    has Normative::Analysis::RiskProfile $.risk-profile;
    has %.counts = ('Low' => 0, 'Moderate' => 0, 'High' => 0, 'Critical' => 0);


    submethod TWEAK {
        # simply count the risk levels for each normative conflict result
        for $!risk-profile.get-all-risk-levels -> $level {
            %!counts{$level}++ if %!counts{$level}:exists;
        }
    }

    method recommend() {
        # runs an analysis on the risk profile and returns a recommendation

        self.LOGGER.debug("Getting a recommendation based on the risk profile...");

        # config loader
        my $config = Util::Config.new;

        # give a recommendation based on the counts
        given %.counts {
            when %.counts{'Critical'} > $config.get_config('normative_analysis', 'number_critical_risks_allowed') {
                self.LOGGER.debug("Critical found - rejecting");
                return Normative::Analysis::RiskAnalyser::REJECT;
            }
            when %.counts{'High'} > $config.get_config('normative_analysis', 'number_high_risks_allowed') {
                self.LOGGER.debug("High found - rejecting");
                return Normative::Analysis::RiskAnalyser::REJECT;
            }
            when %.counts{'Moderate'} >= $config.get_config('normative_analysis', 'number_moderate_risks_allowed') {
                say "Too many Moderates found";
                self.LOGGER.debug("Too many Moderates found - suggesting modification");
                return Normative::Analysis::RiskAnalyser::SUGGEST_MODIFICATION
            }
            default {
                self.LOGGER.debug("No Critical or High risks found, nor too many Moderate - accepting and executing");
                return Normative::Analysis::RiskAnalyser::ACCEPT_AND_EXECUTE;
            }
        }
    }


    method explain(--> Str) {
        # summarises and explains the risk results

        self.LOGGER.debug("Explaining the risk results...");
        my $client = LLM::Facade.new();
        my $messages = LLM::Messages.new;
        my Str $prompt;
        given self.recommend() {
            when Normative::Analysis::RiskAnalyser::REJECT {
                self.LOGGER.debug("Explaining rejection...");
                 $prompt = qq:to/END/;
                === INSTRUCTIONS ===
                - Please explain why the AI Assistant has rejected the request below.
                - You should make the explanation in the first person. Use 'my' rather than 'the' when talking about the
                  analysis.
                - Apologise and say you had to reject the request and then explain.
                - You can mention the scores if appropriate, but leave out the actual numbers.
                - Be concise, you don't need to enumerate all the risks.
                - Don't use the word 'norm' as it is quite technical.
                - Don't use the work 'risk' rather just explain the situation.

                === START RISK RESULTS ===
                {$.risk-profile.to-markdown}
                === END RISK RESULTS ===
                END
            }
            when Normative::Analysis::RiskAnalyser::SUGGEST_MODIFICATION {
                self.LOGGER.debug("Explaining modification request...");
                $prompt = qq:to/END/;
                === INSTRUCTIONS ===
                - Please summarise the risk results below in simple English and explain why the AI Assistant has
                  suggested changing the task. Make some suggestions on how to modify the task.
                - You should make the explanation in the first person. Use 'my' rather than 'the' when talking about the
                  analysis.
                - Apologise and say you think the request should be modified and then explain.
                - You can mention the scores if appropriate, but leave out the actual numbers.
                - Be concise, you don't need to enumerate all the risks but be specific about what the user wanted you to do
                  and what you are meant to do as an AI Assistant.
                - Don't use the word 'norm' as it is quite technical.
                - Don't use the work 'risk' rather just explain the situation.
                === START RISK RESULTS ===
                {$.risk-profile.to-markdown}
                === END RISK RESULTS ===
                END
            }
        }
        $messages.build-messages($prompt.trim, LLM::Messages.USER);
        my $response = $client.completion-string($messages.get-messages);
        return $response;
    }

}
