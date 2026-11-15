=head1 NAME

t/unit/mason/text/stock_1.t - stock templates, part 1 of 2: the text is shown in the user's language

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
    '/stock/accession_files.mas',
    'Uploaded Additional Files',
);

page_texts_ok(
    '/stock/accession_related_transformation_info.mas',
    'Transformants (Accessions) Derived from the same Transformation ID',
    'Number of Insertions and Expression Data',
    'Control Transformants (Accessions)',
    'Add accession names to a List',
    'Transformation Experiment',
    'Number of Insertions:',
);

page_texts_ok(
    '/stock/accession_usage.mas',
    'Accession Usage as Female Parent',
    'Accession Phenotype Performance',
    'Accession Usage as Male Parent',
    'Accession Usage for Trials',
    'Total Number of Plots',
    'Observation Variable',
);

page_texts_ok(
    '/stock/add_phenotype.mas',
    'Trait name',
    'Submit',
    'Value',
);

component_compiles_ok('/stock/add_vector.mas');

component_compiles_ok('/stock/additional_info_section.mas');

page_texts_ok(
    '/stock/delete.mas',
    'Un-Obsolete This Stock',
);

page_texts_ok(
    '/stock/direct_genotypes.mas',
    'Genotyping Project Description',
    'Genotyping Project Name',
    'Genotype Description',
    'Protocol Name',
    'Download',
);

page_texts_ok(
    '/stock/download_stock_phenotypes_dialog.mas',
    'Suppress User Defined Phenotype Outliers:',
    'For repeated measurements, return the:',
    'Include Intercrop Accessions:',
    'Additional Search Options',
    'All Values Multiple Line',
    'Include Trait Synonyms:',
);

component_compiles_ok('/stock/index.mas');

page_texts_ok(
    '/stock/new_stock.mas',
    'Create a New Stock',
    'Stock details',
);

page_texts_ok(
    '/stock/obsolete_accessions_using_list_dialog.mas',
    'The accessions were obsoleted successfully.',
    'Obsolete Accessions Using a List',
    'Select a List of Accessions:',
    'Optional',
    'Success',
    'Submit',
);

done_testing;
