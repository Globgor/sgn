=head1 NAME

t/unit/mason/text/breeders_toolbox_genotyping_trials_4.t - breeders_toolbox/genotyping_trials templates, part 4 of 4: the text is shown in the user's language

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
    '/breeders_toolbox/genotyping_trials/upload_genotyping_data_qc_dialogs.mas',
    'Genotype QC does not save your genotypes in the database, it only scans them against genotyping protocols already saved in the database.',
    'A similarity matrix between the samples in your file and the saved genotypes for the protocol you selected',
    'The marker names should be exactly the marker names that you want to compare against and not any other ID',
    'Select a genotyping protocol in the database against which you want to compare genotypes against.',
    'To actually store data into the database, please use "Upload Genotyping Data".',
    'Select the genotyping protocol you want to compare against',
);

done_testing;
