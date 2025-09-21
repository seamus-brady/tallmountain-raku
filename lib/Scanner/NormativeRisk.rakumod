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
use Cycle::Payload::TaintedString;
use Normative::UserTask;
use Normative::Agent;
use Normative::Risk::RiskProfile;
use Normative::Risk::RiskProfileRunner;
use Normative::Risk::RiskAnalyser;

class Scanner::NormativeRisk {
    # This class is responsible for detecting normative risks in the user's input and returning a risk profile.
    has $.LOGGER = Util::Logger.new(namespace => "<Scanner::NormativeRisk>");

    method scan(Str $user-query, Normative::Agent $normative-agent --> Normative::Risk::RiskAnalyser) {
        $.LOGGER.error("Doing a normative risk scan...");
        # create the user task
        my $user_task = Normative::UserTask.new.get-from-statement($user-query.trim);
        my Normative::Risk::RiskProfileRunner $norm-risk-profiler = Normative::Risk::RiskProfileRunner.new;
        my Normative::Risk::RiskProfile $risk-profile = $norm-risk-profiler.profile($user_task, $normative-agent);
        my $analysis = Normative::Risk::RiskAnalyser.new(
                risk-profile => $risk-profile,
                user-task => $user_task,
        );
        return $analysis;
    }
}
