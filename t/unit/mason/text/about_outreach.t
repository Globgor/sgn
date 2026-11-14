=head1 NAME

t/unit/mason/text/about_outreach.t - about/outreach templates: the text is shown in the user's language

=head1 DESCRIPTION

Renders the components with HTML::Mason through SGN::Test::MasonText, without a
database or a Catalyst context. Each text must be on the page in English and,
with a test catalog, in its translated form. A component that needs real data
to run is only compiled.

=cut

use strict;
use warnings;
use utf8;

use lib 't/lib';
use Test::More;
use SGN::Test::MasonText qw( page_texts_ok component_compiles_ok );

page_texts_ok(
    '/about/outreach/index.mas',
    'This educational outreach activity was designed for grades K-5 and has been done in elementary schools and after school programs.  The purpose of the activity is to teach children about members of the Solanaceae family, the concept of plant families, and diversity.  Various Solanaceae family members (tomatoes, potatoes, eggplants, peppers, and tomatillos) in all shapes, sizes, and colors are purchased at a local grocery store for the activity.  After cutting the vegetables open to look at the seeds or lack of seeds in the case of potatoes, the children taste the tomatoes, peppers, and tomatillos.  In addition to these vegetables, photographs of family members that are not found in local stores and flowers of the various Solanaceae are shown to the students.  After this activity, the children get to dress up the family members for a party.  At the end, a Word Find puzzle is given to the students to reinforce the terms that were discussed.',
    'A laboratory exercise, "Tater Tots or Not?", based on in vitro potato microtuber production was developed for use in the biology curriculum at the high school level.  Joyce Van Eck and an Ithaca High School biology teacher, Linda Knewstub, designed a laboratory class that requires collaboration, critical thinking, and scientific inquiry.  The exercise covers the following aspects of curriculum content: traits of living organisms (life functions), requirements of photosynthesis and respiration (cell energy), scientific method and experimental design, and cell division (mitosis, asexual reproduction, vegetative propagation, stem cells).',
    'The bioinformatics summer internship accepts college undergraduates into the program. The internship is not available to graduate students. Students work at the Sol Genomics Network (SGN) for 8 - 10 weeks during the summer on their own bioinformatics-related projects. A staff member of SGN acts as project mentor for each student to help them learn the various programming skills necessary to develop their projects. As part of this internship, they also attend weekly seminars held at the Boyce Thompson Institute (BTI) that are given by plant scientists from BTI and Cornell.',
    'The US SOL outreach program focuses on Solanaceae biology and bioinformatics. The target audience is K-12 and college undergraduates, with a particular effort to engage underrepresented groups. Activities include presentations at elementary schools and associated after school programs, high schools, undergraduate classes, high school teacher curriculum workshops, and we provide hands-on laboratory activities. Bioinformatics training is taking place in the form of internships at SGN for undergraduate students.',
    'The purpose of outreach is to establish a link between the science community and students at all levels of education in order to foster interest in the sciences and expose students to scientific career paths. A specific mandate from funding agencies such as the National Science Foundation is to increase the participation of underrepresented groups in science.',
    'Introduction to using SGN for high school students and new users, with hands on exercises.',
);

done_testing;
