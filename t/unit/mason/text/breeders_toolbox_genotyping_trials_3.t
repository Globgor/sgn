=head1 NAME

t/unit/mason/text/breeders_toolbox_genotyping_trials_3.t - breeders_toolbox/genotyping_trials templates, part 3 of 4: the text is shown in the user's language

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
    '/breeders_toolbox/genotyping_trials/upload_genotyping_data_dialogs.mas',
    'Provide info about the genotyping protocol used. The genotyping protocol represents a specific instance of how genotypes were called for a set of markers in a genotyping platform. Many genotyping projects can use the same genotyping protocol.',
    'Select the genotyping project or create a new one. A genotyping project is a specific genotyping event. You can have many genotyping projects under the same genotyping protocol to indicate that those genotyping events used the same markers.',
    'If you are uploading many files that used the same genotyping protocol, you can do so, and the database will ensure that the marker information is consistent across the genotyping data (e.g. the same reference, alternate, position, etc.).',
    'Ideally the sample names in your VCF file will match sample names in genotyping plates in the database; however, the sample names in your file can also match accession names in the database.',
    'VCF is a tab separated format. If your VCF is very large (greater than 10GB), please consider converting it to an HDF5 (.h5) file using Tassel, and uploading the HDF5 formatted file instead.',
    'The SampleName.LabID column should contain the sample name (exported_tissue_sample_name or accession_name) and it must exist in the database already',
);

done_testing;
