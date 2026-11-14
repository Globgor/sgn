=head1 NAME

t/unit/mason/text/sentences_breeders_toolbox_trial_5.t - breeders_toolbox/trial templates, part 5 of 5: sentences appear in the user's language

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
    '/breeders_toolbox/trial/upload_additional_file.mas',
    'Use {bold}Add to Collection{end_bold} to put the uploaded files into a file collection, either one you can edit or a new one created with the name and description you enter.',
);

done_testing;
