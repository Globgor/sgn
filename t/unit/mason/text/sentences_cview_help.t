=head1 NAME

t/unit/mason/text/sentences_cview_help.t - cview/help templates: sentences appear in the user's language

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
    '/cview/help/map_submission.mas',
    'We need the following information for each accession used in the mapping or polymorphism data files. (Some accessions are already in our database; {link}Contact us{end_link} if you\'re not sure). This information can be sent in an email or text file.',
    'One or more {bold}marker data files{end_bold} describing the markers used. The file format describing each type of marker is different, so that for one map, many marker description files may be required.',
    '{column}: (optional) If the marker is already in SGN, providing its marker id ({marker_code} number) will allow us to process your map more quickly.',
    '{column}: Mapmaker\'s confidence for this marker - one of {codes}. If your mapping software doesn\'t calculate a confidence, just omit this column.',
    'A {bold}mapping file{end_bold} which contains the information about the markers positions each linkage group.',
);

done_testing;
