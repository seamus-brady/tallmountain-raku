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
use Normative::Analysis::ImpliedNormExtractor;
use Normative::Analysis::NormativeAnalysisResult;


class Normative::UserTask does Normative::Role::Endeavour {
    # a task that the system is doing on behalf of a user
    # also calls the LLM model to get a goal and description for the user task

    has $.LOGGER = Util::Logger.new(namespace => "<Normative::UserTask>");

    has Str $.task_description_schema = q:to/END/;
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

    has Str $.task_description_example = q:to/END/;
    <?xml version="1.0" encoding="UTF-8"?>
    <Task xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xsi:noNamespaceSchemaLocation="schema.xsd">
        <name>Define deliverables</name>
        <goal>The user is requesting that the AI assistant define the deliverables.</goal>
        <description>Finalize all deliverables before the deadline</description>
    </Task>
    END

    method get_from_statement(Str $statement --> Normative::UserTask) {

        self.LOGGER.debug("getting user task from user statement");

        # get a user task from a user statement

        my $norm_extractor = Normative::Analysis::ImpliedNormExtractor.new;

        # start two promises to extract norms and get goal description
        my $norm_extractor_promise = start { $norm_extractor.extract_norm_props($statement) };
        my $goal-description_promise = start { Normative::UserTask.new.get_goal_description($statement) };

        # Wait for both results
        my ($extracted_norms, $goals_description) = await $norm_extractor_promise, $goal-description_promise;

        # get the extracted norms
        my $analysis_result = Normative::Analysis::NormativeAnalysisResult.new_from_data($extracted_norms.Hash);

        return self.create(
            statement => $statement,
            name => $goals_description<name>,
            goal => $goals_description<goal>,
            description => $goals_description<description>,
            normative-propositions => $analysis_result.implied_propositions,
        );
    }


    method get_goal_description(Str $statement -->  Hash){
        # does some initial analysis on the user statement to set a goal and description for the endeavour

        $!LOGGER.debug("getting goal and description for user task from LLM model");

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
        $messages.build_messages($prompt.trim, LLM::Messages.USER);
        my %response = $client.completion_structured_output(
                $messages.get_messages,
                $.task_description_schema,
                $.task_description_example);
        return %response;
    }
}
