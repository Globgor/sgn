=head1 NAME

t/unit/mason/text/breeders_toolbox_1.t - breeders_toolbox templates, part 1 of 10: the text is shown in the user's language

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
    '/breeders_toolbox/add_accessions_dialogs.mas',
    'When checked, add synonyms of existing accession entries to the synonyms already stored in the database.  When not checked, remove any existing synonyms of existing accession entries and store only the synonyms in the upload file.',
    'Note: Use the fuzzy search to match similar names to prevent uploading of duplicate accessions. Fuzzy searching is much slower than regular search. Only a curator can disable the fuzzy search.',
    'Note: Use the fuzzy search to match similar names to prevent uploading of duplicate accessions. Fuzzy searching is much slower than regular search.',
    'When checked, automatically create a new accession list with the accessions in your upload file.',
    'The following accessions are new and will be added to the database:',
    'The following accessions already exist in the database:',
);

page_texts_ok(
    '/breeders_toolbox/add_data_agreement_dialogs.mas',
    'Modify Data Agreement',
    'Submit',
    'Close',
);

page_texts_ok(
    '/breeders_toolbox/add_derived_accessions_using_list_dialog.mas',
    'Description provided will be stored as description for the specify derived accession',
    'Add New Accessions Derived from Accessions/Plants/Tissue Samples Using a List',
    'List must be accessions, plants or tissue samples list type',
    'Derived accession names must not exist in the database',
    'New derived accessions were added successfully',
    'Names in the list must exist in the database',
);

page_texts_ok(
    '/breeders_toolbox/add_new_trait_dialogs.mas',
    'An observation variable is composed of a trait for the attribute being observed, a method describing how the attribute was measured, and a scale indicating the units of the observation.',
    'In this workflow you can add a new ontology to the database. Once an ontology is added, you can add terms into it from the add observation variables workflow.',
    'Having many observation variables that are in fact recording the same thing is dangerous and can cause the database data to become fragmented.',
    'A method defines the how it was measured measured. It is one component of an observation variable; the others are a trait and a scale.',
    'A trait defines the attribute being measured. It is one component of an observation variable; the others are a method and a scale.',
    'Here you can select a trait that already exists in an ontology in the database or you can add a new trait into an ontology.',
);

page_texts_ok(
    '/breeders_toolbox/add_seedlot_dialogs.mas',
    'Seedlot/Plot/Subplot/Plant name to be used as the source for the first transaction',
    'Amount (number of materials):',
    'Amount OR Weight(g) Required',
    'Transaction Description:',
    'One Content Required',
    'Seedlot Description:',
);

page_texts_ok(
    '/breeders_toolbox/add_transactions_using_list.mas',
    'There are four different types of seedlot transactions: Transferring seeds from an existing seedlot to another existing seedlot, to a new seedlot, to a plot or to unspecified seedlot or plot.',
    'Seedlot list option can be used only for transferring seeds from existing seedlots to unspecified seedlots/plots.',
    'Note: This option is for transferring seeds to unspecified seedlots/plots only',
    'You can use upload option for all transaction types',
    'The seedlot transactions were saved successfully.',
    'New seedlot transactions were added successfully',
);

component_compiles_ok('/breeders_toolbox/add_vectors_dialogs.mas');

done_testing;
