=head1 NAME

t/unit/mason/text/breeders_toolbox_trial_5.t - breeders_toolbox/trial templates, part 5 of 7: the text is shown in the user's language

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
    '/breeders_toolbox/trial/trial_coords.mas',
    'Please, confirm change of accessions between plots in the map...',
    'The field coordinates were updated successfully...',
    'Upload physical field coordinates for this trial',
    'Plot accession was replaced successfully...',
    'Please, confirm field map deletion...',
    'Even Block Numbers (e.g. 2,4,...)',
);

page_texts_ok(
    '/breeders_toolbox/trial/trial_coords_upload_dialogs.mas',
    'Field plots will be displayed in the physical trial layout based on the coordinates you provided in the row and column number.',
    'Physical trial layout will capture serpentine, zigzag and any other planting format use.',
    'The first row (header) should contain the following:',
    'The trial coord upload finished with no errors.',
    'Upload Coordinates Uploaded Sucessfully',
    'Upload trial coordinates file:',
);

page_texts_ok(
    '/breeders_toolbox/trial/trial_create_dialogs.mas',
    'A field trial represents a field where each plot has a globally unique plot name, a sequential plot number that is unique in the trial (e.g. 101, 102, 103 for three separate plots), and an accession representing the genotype being tested in that plot. In cases where crosses/families are being evaluated (e.g. F1 hybrid, backcrossing), cross unique ids or family names can be used instead of accessions. Each plot can belong to different blocks and reps depending on the experimental design you are using (e.g. complete block vs augmented design). Each plot can have a row number and col number indicating the relative position of the plot in the field.',
    'The parameters will consider a sample partially replicated design trial with 200 unreplicated accessions, 119 accessions replicated 4 times, 26 rows in design, 26 columns in design, bock sequence of 13 by 2 (13, 2) i.e 2 blocks with each having 13 rows; sub-block sequence of block of 13 by 1 (13, 1) i.e 1 sub-block with each having 13 rows in each block.',
    'If you go on to collect tissue samples for creating a 96 well plate for genotyping, when adding the genotyping plate (96 well plate layout) to the database you can use plot names or plant names or tissue sample names from this field trial. By doing so, we can create linkage between this field trial and the genotyping plate.',
    'Depending on the design you have picked, you will need to provide different design parameters (e.g. for complete block you will need to provide number of blocks, while for alpha lattice you will need to provide block size and number of replicates.).',
    'You also need to provide a list of accessions, cross unique ids or family names to use. Based on the design you have picked, the accessions, cross unique ids or family names will be randomized over the blocks or replicates in the trial.',
    'If you go on to perform crosses on this field trial, each cross can be linked to specific female and male plots. When you upload these crosses we can then automatically link this field trial to the crossing experiment in the database.',
);

page_texts_ok(
    '/breeders_toolbox/trial/trial_deletion.mas',
    'Are you sure you want to delete assayed traits data for this trial?',
    '2. Delete layout data and trial entry completely',
    'Trait deletion was successfully completed',
    'Proceed with deletion below...',
    'Delete Trial Phenotype Data',
    'Select Traits For Deletion',
);

page_texts_ok(
    '/breeders_toolbox/trial/trial_details.mas',
    'Stock Type Being Evaluated in This Trial',
    'Number of Stocks in This Trial',
    'Trial Will Be In Crosses',
    'Trial Will Be Genotyped',
    'Latest Trial Activity',
    'Breeding Program',
);

page_texts_ok(
    '/breeders_toolbox/trial/trial_entry_numbers.mas',
    'Generate Entry Number Template',
    'Upload Entry Number Template',
    'Delete Entry Numbers',
);

done_testing;
