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
    has Normative::Role::Endeavour $.highest_endeavour;

    # more mundane endeavours
    has @.system_endeavours;

    method add_highest_endeavour(Normative::Role::Endeavour $highest-endeavour) {
        $!highest_endeavour = $highest-endeavour;
    }


    method add_system_endeavour(Normative::Role::Endeavour $endeavour) {
        @!system_endeavours.push($endeavour);
    }

    method init() {
         self.LOGGER.debug("initializing normative agent...");
         self.load_highest_endeavour;
         self.load_system_endeavours;
    }

    method map_endeavours(%parsed-data --> Array){
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
                                proposition_value => .<proposition_value>,
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

    method load_highest_endeavour(){
        self.LOGGER.debug("loading highest endeavour...");
        my %parsed-data = self.load_highest_endeavour_config;
        my @loaded_endeavours = self.map_endeavours(%parsed-data);
        self.add_highest_endeavour(@loaded_endeavours[0]);
    }

    method load_system_endeavours(){
        self.LOGGER.debug("loading system endeavours...");
        my %parsed-data =  self.load_system_endeavours_config;
        my @loaded_endeavours =self.map_endeavours(%parsed-data);
        @loaded_endeavours.map({self.add_system_endeavour($_)});
    }

    method load_highest_endeavour_config(--> Hash) {
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

    method load_system_endeavours_config(--> Hash) {
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

    method highest_endeavour_to_markdown() {
        my $endeavour = $!highest_endeavour;
        return "## Highest Endeavour\n\n" ~
                "### Name\n" ~ $endeavour.name ~ "\n\n" ~
                "### Description\n" ~ $endeavour.description ~ "\n\n" ~
                "### Normative Propositions\n" ~
                $endeavour.normative_propositions.map({
                    $_.to_markdown ~ "\n"
                }).join;
    }

    method system_endeavours_to_markdown() {
        return "## System Endeavours\n\n" ~
                @!system_endeavours.map({
                         "### Name\n" ~ $_.name ~ "\n\n" ~
                         "### Description\n" ~ $_.description ~ "\n\n" ~
                         "### Normative Propositions\n" ~
                         $_.normative_propositions.map({
                         $_.to_markdown ~ "\n"
                         }).join ~ "\n"
                }).join("\n");
    }

    method get_system_endeavour_by_uuid(Str $uuid) {
        for @!system_endeavours -> $endeavour {
            if $endeavour.uuid eq $uuid {
                return $endeavour;
            }
        }
        return Nil;
    }

    method get_code_of_conduct_endeavour(--> Normative::Role::Endeavour) {
        my $config = Util::Config.new;
        my $code_of_conduct_uuid =  $config.get_config('system_endeavours', 'code_of_conduct_uuid');
        return self.get_system_endeavour_by_uuid($code_of_conduct_uuid);
    }

    method get_system_integrity_endeavour(--> Normative::Role::Endeavour) {
        my $config = Util::Config.new;
        my $code_of_conduct_uuid =  $config.get_config('system_endeavours', 'system_integrity_uuid');
        return self.get_system_endeavour_by_uuid($code_of_conduct_uuid);
    }
}

