=head1 NAME

t/unit/mason/text/sentences_homepage.t - homepage templates: sentences appear in the user's language

=head1 DESCRIPTION

Renders components with SGN::Test::MasonText in English and with a test
translation. Components needing real data are compiled only.

=cut

use strict;
use warnings;
use utf8;

use lib 't/lib';
use Test::More;
use SGN::Test::MasonText qw( page_sentences_ok component_compiles_ok );

page_sentences_ok(
    '/homepage/announcements.mas',
    'You may also have some information that would be of interest to the research community but do not have time etc. to do follow up work for a refereed paper.',
    'Reports can include some interesting preliminary results and will not preclude later publishing in a refereed journal.',
    'The 2014 Report of the Tomato Genetics Cooperative (TGC) will likely be published at the end of October.',
    'There is time for researchers to submit reports on their tomato related research.',
    'For more information on the TGC see {link}{address}{end_link}.',
    'Please submit reports to me at {link}{email}{end_link}.',
);

page_sentences_ok(
    '/homepage/breeders_toolbox.mas',
    'Access the SGN {link}Breeder\'s Toolbox.{end_link}',
);

page_sentences_ok(
    '/homepage/carousel.mas',
    'The {species} sequencing project',
    'Browse the {species} genome',
    '{species} Downloads',
    '{species} Genome',
);

page_sentences_ok(
    '/homepage/community.mas',
    'As an SGN locus editor, {link}contribute to webpages for your favorite genes and mutant lines{end_link} and share relevant data and publications with the community.',
);

page_sentences_ok(
    '/homepage/iconmenu.mas',
    '{species} genome',
);

done_testing;
