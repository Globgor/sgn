=head1 NAME

t/unit/mason/text/homepage_1.t - homepage templates, part 1 of 2: the text is shown in the user's language

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
    '/homepage/announcements.mas',
    'Managing Editor Tomato Genetics Cooperative',
    'A message from the TGC',
);

page_texts_ok(
    '/homepage/breeders_toolbox.mas',
    'SGN Breeder\'s Toolbox',
);

page_texts_ok(
    '/homepage/carousel.mas',
    'Exploitation of genetic and epigenetic variation in the regulation of tomato fruit quality traits',
    'The new Tomato Genome assembly (SL3.0) and annotations (ITAG3.0) are now available on SGN',
    'September 15th - 19th 2019, Jerusalem, Israel',
    'The 16th Solanaceae Conference',
    'Download the Genome Sequence',
    'Find sequences by similarity',
);

page_texts_ok(
    '/homepage/community.mas',
    'Community Annotation',
    'more...',
);

page_texts_ok(
    '/homepage/events.mas',
    'See all events...',
);

page_texts_ok(
    '/homepage/forum.mas',
    'Browse or advertise jobs here.',
    'View all topics...',
    'Forum topics',
    'Job Listings',
);

page_texts_ok(
    '/homepage/github_pullrequests.mas',
    'Recent Changes to Database',
);

page_texts_ok(
    '/homepage/iconmenu.mas',
    'Click to access the Breeder\'s toolbox',
    'Submit map information to SGN',
    'Search/browse tomato genome',
    'Become an SGN locus editor',
    'Click to access SolCyc',
    'Genomes and Sequences',
);

page_texts_ok(
    '/homepage/image_of_the_week.mas',
    'Featured Image',
);

page_texts_ok(
    '/homepage/labs.mas',
    'See all featured labs...',
    'Featured Lab',
);

page_texts_ok(
    '/homepage/legal.mas',
    'SGN, BTI and its employees make no representation or warranty, express or implied, including without limitation any warranties of merchantability or fitness for a particular purpose or warranties as to the identity or ownership of data or information, the quality, accuracy or completeness of data or information, or that the use of such data or information will not infringe any patent, intellectual property or proprietary rights of any party.',
    'Data and information released from the Sol Genomics Network (SGN) are provided on an "AS IS" basis, without warranty of any kind, including without limitation the warranties of merchantability, fitness for a particular purpose and non-infringement. Availability of this data and information does not constitute scientific publication. Data and/or information may contain errors or be incomplete.',
    'SGN or BTI shall not be liable for any claim for any loss, harm, illness or other damage or injury arising from access to or use of data or information, including without limitation any direct, indirect, incidental, exemplary, special or consequential damages, even if advised of the possibility of such damages.',
    'In accordance with scientific standards, appropriate acknowledgment of SGN should be made in any publications or other disclosures concerning data or information made available by SGN. If results using preliminary sequence data are to be published, SGN recommends reference in a manuscript as follows:',
    'For acknowledgments, the following is recommended:',
    'NOTICE and DISCLAIMER/LIMITATION OF LIABILITY',
);

page_texts_ok(
    '/homepage/locus_of_the_week.mas',
    'Search other loci...',
    'See previous...',
    'Featured Locus',
);

done_testing;
