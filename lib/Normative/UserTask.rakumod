#  Copyright (c) 2024. Prediction By Invention https://predictionbyinvention.com/
#
#  THIS SOFTWARE IS PROVIDED "AS IS" WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED,
#  INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A
#  PARTICULAR PURPOSE, AND NON-INFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR
#  COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES, OR OTHER LIABILITY, WHETHER
#  IN AN ACTION OF CONTRACT, TORT, OR OTHERWISE, ARISING FROM, OUT OF, OR
#  IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.

use v6.d;
use LLM::Facade;
use LLM::Messages;
use Util::Config;
use Normative::Role::Endeavour;
use Normative::ImpliedNormExtractor;
use Normative::NormativeAnalysisResult;


class Normative::UserTask does Normative::Role::Endeavour {
    # a task that the system is doing on behalf of a user
    # also calls the LLM model to get a goal and description for the user task

    has $.LOGGER = Util::Logger.new(namespace => "<Normative::UserTask>");

    has Str $.task-description-schema = q:to/END/;
    <?xml version="1.0" encoding="UTF-8"?>
    <xs:schema xmlns:xs="http://www.w3.org/2001/XMLSchema" elementFormDefault="qualified">
        <!-- Define the root element -->
        <xs:element name="Task" type="TaskType"/>

        <!-- Define the complex type for Task -->
        <xs:complexType name="TaskType">
            <xs:sequence>
                <xs:element name="name" type="xs:string"/>
                <xs:element name="goal" type="xs:string"/>
                <xs:element name="description" type="xs:string"/>
            </xs:sequence>
        </xs:complexType>
    </xs:schema>
    END

    has Str $.task-description-example = q:to/END/;
    <?xml version="1.0" encoding="UTF-8"?>
    <Task xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xsi:noNamespaceSchemaLocation="schema.xsd">
        <name>Define deliverables</name>
        <goal>The user is requesting that the AI assistant define the deliverables.</goal>
        <description>Finalize all deliverables before the deadline</description>
    </Task>
    END

    method get-from-statement(Str $statement --> Normative::UserTask) {

        self.LOGGER.info("getting user task from user statement");

        # get a user task from a user statement

        my $norm_extractor = Normative::ImpliedNormExtractor.new;

        # start two promises to extract norms and get goal description
        my $norm-extractor-promise = start { $norm_extractor.extract-norm-props($statement) };
        my $goal-description-promise = start { Normative::UserTask.new.get-goal-description($statement) };

        # Wait for both results
        my ($extracted_norms, $goals-description) = await $norm-extractor-promise, $goal-description-promise;

        # get the extracted norms
        my $analysis_result = Normative::NormativeAnalysisResult.new-from-data($extracted_norms.Hash);

        self.bless(
            statement => $statement,
            name => $goals-description<name>,
            goal => $goals-description<goal>,
            description => $goals-description<description>,
            normative-propositions => $analysis_result.implied_propositions,
        );
    }


    method get-goal-description(Str $statement -->  Hash){
        # does some initial analysis on the user statement to set a goal and description for the endeavour

        $!LOGGER.info("getting goal and description for user task from LLM model");

        my $client = LLM::Facade.new;
        my $messages = LLM::Messages.new;
        my $prompt = qq:to/END/;

        === INSTRUCTIONS ===
        - Your job is to analyse the user's statement below and formulate a goal and description for the AI assistant task
          to handle this user query.
        - The name should be a short, descriptive name for the task.
        - The goal should be a clear statement of what the user is trying to the AI assistant to do.
        - The description should be a more detailed explanation of the task and the context in which it will be performed.
        === START INPUT STATEMENT ===
        $statement
        === END INPUT STATEMENT ===
        END
        $messages.build-messages($prompt.trim, LLM::Messages.USER);
        my %response = $client.completion-structured-output(
                $messages.get-messages,
                $.task-description-schema,
                $.task-description-example);
        return %response;
    }
}
