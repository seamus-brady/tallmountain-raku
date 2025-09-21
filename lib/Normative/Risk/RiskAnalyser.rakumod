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
use Util::Logger;
use Normative::UserTask;
use Normative::Risk::RiskProfile;
use LLM::Messages;
use LLM::Facade;

class Normative::Risk::RiskAnalyser {
    # This class is responsible for analysing the risk profile and providing a recommendation

    has $.LOGGER = Util::Logger.new(namespace => "<Normative::Risk::RiskAnalyser>");

    our constant ACCEPT_AND_EXECUTE = "Accept and Execute";
    our constant SUGGEST_MODIFICATION = "Suggest Modification";
    our constant REJECT = "Reject";

    has Normative::Risk::RiskProfile $.risk-profile;
    # store the user task so we can pass it to the next stage
    has Normative::UserTask $.user-task;
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
                return Normative::Risk::RiskAnalyser::REJECT;
            }
            when %.counts{'High'} > $config.get_config('normative_analysis', 'number_high_risks_allowed') {
                self.LOGGER.debug("High found - rejecting");
                return Normative::Risk::RiskAnalyser::REJECT;
            }
            when %.counts{'Moderate'} >= $config.get_config('normative_analysis', 'number_moderate_risks_allowed') {
                self.LOGGER.debug("Suggesting modification");
                return Normative::Risk::RiskAnalyser::SUGGEST_MODIFICATION
            }
            default {
                self.LOGGER.debug("Accepting and executing");
                return Normative::Risk::RiskAnalyser::ACCEPT_AND_EXECUTE;
            }
        }
    }


    method explain(--> Str) {
        # summarises and explains the risk results

        self.LOGGER.debug("Explaining the risk results...");
        my $client = LLM::Facade.new();
        my $messages = LLM::Messages.new;
        my Str $recommendation = self.recommend;
        given $recommendation {
            when Normative::Risk::RiskAnalyser::REJECT {
                self.LOGGER.debug("Rejecting the prompt...");
                # no explanation for rejected tasks
                my Str $response = Util::Config.get_config('reactive_stage', 'threat_detected_error');
                return $response;
            }
            when Normative::Risk::RiskAnalyser::SUGGEST_MODIFICATION {
                self.LOGGER.debug("Explaining modification request...");
                my Str $prompt = qq:to/END/;
                === INSTRUCTIONS ===
                - Please summarise the risk results below in simple English and explain why the AI Assistant has
                  suggested changing the task. Make some suggestions on how to modify the task.
                - You should make the explanation in the first person. Use 'my' rather than 'the' when talking about the
                  analysis. Rather than say 'the user', say 'you' or 'your' as appropriate.
                - Apologise and say you think the request should be modified and then explain.
                - You can mention the scores if appropriate, but leave out the actual numbers.
                - Be concise, you don't need to enumerate all the risks but be specific about what the user wanted you to do
                  and what you are meant to do as an AI Assistant.  But be conversational.
                - Don't use the word 'norm' as it is quite technical.
                - Don't use the work 'risk' rather just explain the situation.
                === START RISK RESULTS ===
                {$.risk-profile.to-markdown}
                === END RISK RESULTS ===
                END
                $messages.build-messages($prompt.trim, LLM::Messages.USER);
                my $response = $client.completion-string($messages.get-messages);
                return $response;
            }
            default {
                self.LOGGER.debug("Task is acceptable to process");
                return "The user task is acceptable to process."
            }
        }

    }

}
