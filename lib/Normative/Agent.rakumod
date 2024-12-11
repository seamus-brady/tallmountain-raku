#  Copyright (c) 2024. Prediction By Invention https://predictionbyinvention.com/
#
#  THIS SOFTWARE IS PROVIDED "AS IS" WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED,
#  INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A
#  PARTICULAR PURPOSE, AND NON-INFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR
#  COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES, OR OTHER LIABILITY, WHETHER
#  IN AN ACTION OF CONTRACT, TORT, OR OTHERWISE, ARISING FROM, OUT OF, OR
#  IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.

use v6.d;
use JSON::Fast;
use Util::FilePath;
use Util::Logger;
use Util::Config;
use Normative::Proposition;
use Normative::Role::Endeavour;
use Normative::HighestEndeavour;

# exception class for normative agent exceptions
class Normative::Agent::Exception is Exception {
    has Str $.message;
}

class Normative::Agent {
    # The normative subsystem of an agent. Contains all the endeavours of an agent.

    has $.LOGGER = Util::Logger.new(namespace => "<Normative::Agent>");

    # the highest endeavour of the agent is the ethical endeavour
    has Normative::Role::Endeavour $.highest-endeavour;

    # more mundane endeavours
    has @.system-endeavours;

    method add-highest-endeavour(Normative::Role::Endeavour $highest-endeavour) {
        $!highest-endeavour = $highest-endeavour;
    }


    method add-system-endeavour(Normative::Role::Endeavour $endeavour) {
        @!system-endeavours.push($endeavour);
    }

    method init() {
         self.LOGGER.debug("initializing normative agent...");
         self.load-highest-endeavour;
         self.load-system-endeavours;
    }

    method map-endeavours(%parsed-data --> Array){
        my @loaded_endeavours = %parsed-data<endeavours>.map({
            Normative::Role::Endeavour.create(
                    uuid => .<uuid>,
                    name => .<name>,
                    description => .<description>,
                    goal => .<goal>,
                    comprehensiveness => Normative::Comprehensiveness.{<comprehensiveness>}
                            // Normative::Comprehensiveness::DEFAULT,
                    normative-propositions => .<normative_propositions>.map({
                        Normative::Proposition.new(
                                uuid => .<uuid>,
                                proposition-value => .<proposition_value>,
                                goal => .<goal>,
                                description => .<description>,
                                operator => Normative::Proposition::Operator::{.<operator>},
                                level => Normative::Proposition::Level::{.<level>},
                                modality => Normative::Proposition::Modality::{.<modality>},
                                modal-subscript => Normative::Proposition::ModalitySubscript::{.<modality-subscript>}
                                )
                    })
                    )
        });
        return @loaded_endeavours;
    }

    method load-highest-endeavour(){
        self.LOGGER.debug("loading highest endeavour...");
        my %parsed-data = self.load-highest-endeavour-config;
        my @loaded_endeavours = self.map-endeavours(%parsed-data);
        self.add-highest-endeavour(@loaded_endeavours[0]);
    }

    method load-system-endeavours(){
        self.LOGGER.debug("loading system endeavours...");
        my %parsed-data =  self.load-system-endeavours-config;
        my @loaded_endeavours =self.map-endeavours(%parsed-data);
        @loaded_endeavours.map({self.add-system-endeavour($_)});
    }

    method load-highest-endeavour-config(--> Hash) {
        self.LOGGER.debug("loading configuration for highest endeavour...");
        try {
            my $config-dir = Util::FilePath.new.config-path;
            my $json-file = "$config-dir/highest-endeavour.json";
            my $json = slurp $json-file;
            return from-json($json);
            CATCH {
                my Str $message = "Error loading configuration for highest endeavour: $_";
                self.LOGGER.error($message);
                Normative::Agent::Exception.new(message => $message).throw;
            }
        }
    }

    method load-system-endeavours-config(--> Hash) {
        self.LOGGER.debug("loading configuration for system endeavours...");
        try {
            my $config-dir = Util::FilePath.new.config-path;
            my $json-file = "$config-dir/system-endeavours.json";
            my $json = slurp $json-file;
            return from-json($json);
            CATCH {
                my Str $message = "Error loading configuration for system endeavours: $_";
                self.LOGGER.error($message);
                Normative::Agent::Exception.new(message => $message).throw;
            }
        }
    }

    method highest-endeavour-to-markdown() {
        my $endeavour = $!highest-endeavour;
        return "## Highest Endeavour\n\n" ~
                "### Name\n" ~ $endeavour.name ~ "\n\n" ~
                "### Description\n" ~ $endeavour.description ~ "\n\n" ~
                "### Goal\n" ~ $endeavour.goal ~ "\n\n" ~
                "### Normative Propositions\n" ~
                $endeavour.normative-propositions.map({
                    $_.to-markdown ~ "\n"
                }).join;
    }

    method system-endeavours-to-markdown() {
        return "## System Endeavours\n\n" ~
                @!system-endeavours.map({
                         "### Name\n" ~ $_.name ~ "\n\n" ~
                         "### Description\n" ~ $_.description ~ "\n\n" ~
                         "### Goal\n" ~ $_.goal ~ "\n\n" ~
                         "### Normative Propositions\n" ~
                         $_.normative-propositions.map({
                         $_.to-markdown ~ "\n"
                         }).join ~ "\n"
                }).join("\n");
    }

    method get-system-endeavour-by-uuid(Str $uuid) {
        for @!system-endeavours -> $endeavour {
            if $endeavour.uuid eq $uuid {
                return $endeavour;
            }
        }
        return Nil;
    }

    method get-code-of-conduct-endeavour(--> Normative::Role::Endeavour) {
        my $config = Util::Config.new;
        my $code_of_conduct_uuid =  $config.get_config('system_endeavours', 'code_of_conduct_uuid');
        return self.get-system-endeavour-by-uuid($code_of_conduct_uuid);
    }

    method get-system-integrity-endeavour(--> Normative::Role::Endeavour) {
        my $config = Util::Config.new;
        my $code_of_conduct_uuid =  $config.get_config('system_endeavours', 'system_integrity_uuid');
        return self.get-system-endeavour-by-uuid($code_of_conduct_uuid);
    }
}

