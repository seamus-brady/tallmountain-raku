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
use Normative::Agent;
use Cycle::Stage::ReactiveScan;
use Cycle::Stage::EarlyExit;
use Cycle::Payload::TaintedString;
use Cycle::Stage::ReactiveReturn;
use Scanner::VulnerableUser;
use Scanner::PromptLeakage;
use Scanner::PromptHijack;
use Scanner::InappropriateContent;
use Scanner::NormativeRisk;
use Normative::Risk::RiskAnalyser;



class Cycle::Stage::Reactive {
    # reactive stage in the cognitive cycle - used for quick detection of threats and scanning
    # based on Aaron Sloman's CogAff architecture

    has $.LOGGER = Util::Logger.new(namespace => "<Cycle::Stage::Reactive>");
    has Normative::Agent $.normative-agent;

    method run(Cycle::Payload::TaintedString $tainted --> Cycle::Stage::ReactiveReturn)  {
        # runs some scans on the prompt and returns the results

        self.LOGGER.debug("starting reactive stage of cognitive cycle...");

        # get prompt from payload
        my Str $prompt = $tainted.payload;

        # run scans
        my @scans = self.handle-scans($prompt);

        # check for leakage or hijack attempts
        my $scan_results = Cycle::Stage::ReactiveScan.new-from-results(@scans);
        if $scan_results.has-leakage-or-hijack-attempt {
            return self.handle-early-exit-for-threat;
        }

        # check the normative scan
        my Normative::Risk::RiskAnalyser $analysis = $scan_results.normative-scan;
        my $recommendation = $analysis.recommend;
        if $recommendation eq Normative::Risk::RiskAnalyser::ACCEPT_AND_EXECUTE {
            # all good, accept and execute
            return $scan_results;
        } else {
           return self.handle-early-exit-for-normative-risk($prompt, $analysis);
        }
    }

    method handle-scans(Str $prompt --> Array) {
        # handle the running of the scans
        my $start-time = now;
        my @scan_promises = start { Scanner::PromptLeakage.new.scan($prompt) },
                            start { Scanner::PromptHijack.new.scan($prompt) },
                            start { Scanner::InappropriateContent.new.scan($prompt) },
                            start { Scanner::VulnerableUser.new.scan($prompt) },
                            start { Scanner::NormativeRisk.new.scan($prompt, $.normative-agent) };
        my @results = await @scan_promises;
        my $end-time = now;
        my $elapsed-time = $end-time - $start-time;
        self.LOGGER.debug("scans took $elapsed-time seconds");
        return @results;
    }

    method handle-early-exit-for-normative-risk(
            Str $prompt,
            Normative::Risk::RiskAnalyser $analysis --> Cycle::Stage::EarlyExit) {
        self.LOGGER.debug("Prompt contains a normative risk!");
        # get the explanation from the analysis
        my Str $ai-message = $analysis.explain;
        return Cycle::Stage::EarlyExit.new(
                ai-message => $ai-message,
                user-message => $prompt,
                exit-details => "Prompt contains a normative risk: $ai-message"
        );
    }

    method handle-early-exit-for-threat(--> Cycle::Stage::EarlyExit) {
        self.LOGGER.debug("Prompt contains a leakage or hijack attempt!");
        my Str $response = Util::Config.get_config('reactive_stage', 'threat_detected_error');
        return Cycle::Stage::EarlyExit.new(
                ai-message => $response,
                user-message => "<REDACTED USER MESSAGE - PROMPT ATTACK SUSPECTED>",
                exit-details => "Prompt contains a leakage or hijack attempt. Prompt will not be processed."
        );
    }
}
