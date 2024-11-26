#  Copyright (c) 2024. Prediction By Invention https://predictionbyinvention.com/
#
#  THIS SOFTWARE IS PROVIDED "AS IS" WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED,
#  INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A
#  PARTICULAR PURPOSE, AND NON-INFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR
#  COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES, OR OTHER LIABILITY, WHETHER
#  IN AN ACTION OF CONTRACT, TORT, OR OTHERWISE, ARISING FROM, OUT OF, OR
#  IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.

use v6.d;
use UUID::V4;

class Normative::Proposition {
    # A normative proposition

    # Normative operators, read as:
    # – it is required that...
    # – it is ought to be that...
    # – it is indifferent that...
    our enum Operator (INDIFFERENT => 1, OUGHT => 2, REQUIRED => 3);

    # Modal operators, read as:
    # – it is possible that...
    # – it is impossible that...
    our enum Modality <POSSIBLE IMPOSSIBLE>;

    # Modal operator subscripts:
    # – it is logically possible that...
    # – it is theoretically possible that...
    # – it is practically possible that...
    our enum ModalitySubscript <LOGICAL THEORETICAL PRACTICAL NONE>;

    # Norm levels, read as:
    # Norm Category       Ordinal Level    Description
    # Ethical/Moral Norms 6000             Universal principles of right and wrong, justice, and human values.
    # Legal Norms         5000             Codified laws enforceable by legal systems.
    # Prudential Norms    4500             Focus on self-preservation and rational self-interest.
    # Social/Political Norms 4000         Civic duties or expectations governing behavior in society or politics.
    # Scientific/Technical Norms 3500     Standards of rigor, accuracy, and innovation in science and technology.
    # Environmental Norms 3250            Principles of sustainability and ecological conservation.
    # Cultural/Religious Norms 3000       Practices tied to cultural or religious identity, specific to a community.
    # Community Norms     2750            Informal expectations within a local or small-group community.
    # Code of Conduct     2500            Expectations within a profession, organization, or community.
    # Professional/Organizational Norms 2000 Operational conduct in specific roles or workplaces.
    # Economic Norms      2250            Norms regulating fairness in markets or financial systems.
    # Etiquette Norms     1500            Polite behavior and socially acceptable conduct in everyday interactions.
    # Game Norms          1000            Rules specific to games, sports, or competitive activities.
    # Aesthetic Norms     500             Standards of beauty, taste, or artistic expression.
    our enum Level (
    ETHICAL_MORAL => 6000,
    LEGAL => 5000,
    PRUDENTIAL => 4500,
    SOCIAL_POLITICAL => 4000,
    SCIENTIFIC_TECHNICAL => 3500,
    ENVIRONMENTAL => 3250,
    CULTURAL_RELIGIOUS => 3000,
    COMMUNITY => 2750,
    CODE_OF_CONDUCT => 2500,
    PROFESSIONAL_ORGANIZATIONAL => 2000,
    ECONOMIC => 2250,
    ETIQUETTE => 1500,
    GAME => 1000,
    AESTHETIC => 500
    );


    has Str $.uuid = uuid-v4();
    has Str $.proposition-value;
    # TODO add endeavour
    has Operator $.operator;
    has Level $.level;
    has Modality $.modality;
    has ModalitySubscript $.modal-subscript;

    method new-from-xml(Str %xml-data) {
        # say %data;
        # say %data{'NormativeProposition'}[1];
    }

}
