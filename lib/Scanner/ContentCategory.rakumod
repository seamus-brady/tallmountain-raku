#!/usr/bin/env raku

#  Copyright (c) 2024. Prediction By Invention https://predictionbyinvention.com/
#
#  THIS SOFTWARE IS PROVIDED "AS IS" WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED,
#  INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A
#  PARTICULAR PURPOSE, AND NON-INFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR
#  COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES, OR OTHER LIABILITY, WHETHER
#  IN AN ACTION OF CONTRACT, TORT, OR OTHERWISE, ARISING FROM, OUT OF, OR
#  IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.

use v6.d;

class Scanner::ContentCategory {
    # Define constant names and descriptions for inappropriate content categories

    our constant NOT_MODERATED = "Not Moderated";

    constant ILLEGAL_NAME = "Illegal";
    constant ILLEGAL_DESCRIPTION = "Illegal activity.";

    constant CHILD_ABUSE_NAME = "Child Abuse";
    constant CHILD_ABUSE_DESCRIPTION = "Child sexual abuse material or any content that exploits or harms children.";

    constant ANIMAL_ABUSE_NAME = "Animal Abuse";
    constant ANIMAL_ABUSE_DESCRIPTION = "Any content that exploits or harms animals.";

    constant HATE_VIOLENCE_HARASSMENT_NAME = "Hate Violence Harassment";
    constant HATE_VIOLENCE_HARASSMENT_DESCRIPTION =
    "Generation of hateful, harassing, or violent content: content that "
            ~ "expresses, incites, or promotes hate based on identity, content that intends to harass, threaten, "
            ~ "or bully an individual, content that promotes or glorifies violence or celebrates the suffering "
            ~ "or humiliation of others.";

    constant MALWARE_NAME = "Malware";
    constant MALWARE_DESCRIPTION =
    "Generation of malware: content that attempts to generate code that is designed to "
            ~ "disrupt, damage, or gain unauthorized access to a computer system.";

    constant CYBERSECURITY_THREATS_NAME = "Cybersecurity Threats";
    constant CYBERSECURITY_THREATS_DESCRIPTION =
    "Generation of information related to hacking, unauthorized network access, data breaches, "
            ~ "or content that facilitates cyberattacks or network exploitation.";

    constant PHYSICAL_HARM_NAME = "Physical Harm";
    constant PHYSICAL_HARM_DESCRIPTION =
    "Activity that has high risk of physical harm, including: weapons development, "
            ~ "military and warfare, management or operation of critical infrastructure in energy, transportation, "
            ~ "and water, content that promotes, encourages, or depicts acts of self-harm, such as suicide, "
            ~ "cutting, and eating disorders.";

    constant CRBN_NAME = "CRBN Weapons";
    constant CRBN_DESCRIPTION =
    "Creation or dissemination of information or content related to the development, deployment, "
            ~ "or use of chemical, biological, radiological, or nuclear weapons.";

    constant ECONOMIC_HARM_NAME = "Economic Harm";
    constant ECONOMIC_HARM_DESCRIPTION =
    "Activity that has high risk of economic harm, including: multi-level marketing, "
            ~ "gambling, payday lending, automated determinations of eligibility for credit, employment, "
            ~ "educational institutions, or public assistance services.";

    constant FRAUD_NAME = "Fraud";
    constant FRAUD_DESCRIPTION =
    "Fraudulent or deceptive activity, including: scams, coordinated inauthentic behavior, "
            ~ "plagiarism, academic dishonesty, astroturfing, such as fake grassroots support or fake review "
            ~ "generation, disinformation, spam, pseudo-pharmaceuticals.";

    constant ADULT_NAME = "Adult";
    constant ADULT_DESCRIPTION =
    "Adult content, adult industries, and dating apps, including: content meant to arouse "
            ~ "sexual excitement, such as the description of sexual activity, or that promotes sexual services "
            ~ "(excluding sex education and wellness), erotic chat, pornography.";

    constant POLITICAL_NAME = "Political";
    constant POLITICAL_DESCRIPTION =
    "Political campaigning or lobbying, by: generating high volumes of campaign materials, "
            ~ "generating campaign materials personalized to or targeted at specific demographics, building "
            ~ "conversational or interactive systems such as chatbots that provide information about campaigns "
            ~ "or engage in political advocacy or lobbying, building products for political campaigning or "
            ~ "lobbying purposes.";

    constant PRIVACY_NAME = "Privacy";
    constant PRIVACY_DESCRIPTION =
    "Activity that violates people's privacy, including: tracking or monitoring an "
            ~ "individual without their consent, facial recognition of private individuals, classifying "
            ~ "individuals based on protected characteristics, using biometrics for identification or "
            ~ "assessment, unlawful collection or disclosure of personal identifiable information or "
            ~ "educational, financial, or other protected records.";

    constant UNQUALIFIED_LAW_NAME = "Unqualified Law";
    constant UNQUALIFIED_LAW_DESCRIPTION =
    "Engaging in the unauthorized practice of law, or offering tailored legal advice "
            ~ "without a qualified person reviewing the information.";

    constant UNQUALIFIED_FINANCIAL_NAME = "Unqualified Financial";
    constant UNQUALIFIED_FINANCIAL_DESCRIPTION =
    "Offering tailored financial advice without a qualified person reviewing "
            ~ "the information.";

    constant UNQUALIFIED_HEALTH_NAME = "Unqualified Health";
    constant UNQUALIFIED_HEALTH_DESCRIPTION =
    "Telling someone that they have or do not have a certain health condition, "
            ~ "or providing instructions on how to cure or treat a health condition.";

    # Aggregate all categories
    constant ALL_CATEGORIES = [
        [ILLEGAL_NAME, ILLEGAL_DESCRIPTION],
        [CHILD_ABUSE_NAME, CHILD_ABUSE_DESCRIPTION],
        [ANIMAL_ABUSE_NAME, ANIMAL_ABUSE_DESCRIPTION],
        [HATE_VIOLENCE_HARASSMENT_NAME, HATE_VIOLENCE_HARASSMENT_DESCRIPTION],
        [MALWARE_NAME, MALWARE_DESCRIPTION],
        [CYBERSECURITY_THREATS_NAME, CYBERSECURITY_THREATS_DESCRIPTION],
        [PHYSICAL_HARM_NAME, PHYSICAL_HARM_DESCRIPTION],
        [CRBN_NAME, CRBN_DESCRIPTION],
        [ECONOMIC_HARM_NAME, ECONOMIC_HARM_DESCRIPTION],
        [FRAUD_NAME, FRAUD_DESCRIPTION],
        [ADULT_NAME, ADULT_DESCRIPTION],
        [POLITICAL_NAME, POLITICAL_DESCRIPTION],
        [PRIVACY_NAME, PRIVACY_DESCRIPTION],
        [UNQUALIFIED_LAW_NAME, UNQUALIFIED_LAW_DESCRIPTION],
        [UNQUALIFIED_FINANCIAL_NAME, UNQUALIFIED_FINANCIAL_DESCRIPTION],
        [UNQUALIFIED_HEALTH_NAME, UNQUALIFIED_HEALTH_DESCRIPTION],
    ];

    # Method to filter categories
    method get_filtered_categories(:@exclude_categories = []) {
        return ALL_CATEGORIES.grep({ !($_[0] ∈ @exclude_categories) });
    }
}


