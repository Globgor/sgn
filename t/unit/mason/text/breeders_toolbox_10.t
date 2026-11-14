=head1 NAME

t/unit/mason/text/breeders_toolbox_10.t - breeders_toolbox templates, part 10 of 10: the text is shown in the user's language

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
    '/breeders_toolbox/upload_transactions_dialogs.mas',
    'You can upload 4 different types of seedlot transactions. All of the transactions in each file have to be the same type.',
    'Transferring seeds from existing seedlot to a new seedlot. A new seedlot is created beforing adding new transaction.',
    'Upload Template Information For Existing Seedlot to Unspecified Seedlots/Plots Transactions',
    'Upload Template Information For Existing Seedlot to Existing Seedlot Transactions',
    'Upload Template Information For Accession/Cross to Existing Seedlot Transactions',
    'Removing seeds from existing seedlot to unspecified seedlot name or plot name',
);

component_compiles_ok('/breeders_toolbox/view_file.mas');

done_testing;
