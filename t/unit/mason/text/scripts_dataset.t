=head1 NAME

t/unit/mason/text/scripts_dataset.t - scripts in the dataset templates: the script text is shown in the user's language

=head1 DESCRIPTION

Renders the components with HTML::Mason through SGN::Test::MasonText, without a
database or a Catalyst context. Each text must be on the page in English and,
with a test catalog, in its translated form, as a JSON string inside a script. A component that needs real data
to run is only compiled.

=cut

use strict;
use warnings;
use utf8;

use lib 't/lib';
use Test::More;
use SGN::Test::MasonText qw( page_script_texts_ok component_compiles_ok );

page_script_texts_ok(
    '/dataset/authorize.mas',
    'Accounts connected - you may close this window',
    'Could not store connection info',
);

page_script_texts_ok(
    '/dataset/index.mas',
    'Error retrieving analyses using this dataset.',
);

page_script_texts_ok(
    '/dataset/publish.mas',
    'Are you sure you want to unlink this published metadata from the dataset?  This will remove the archived data on this server and the connection between the dataset and the external service.  This will NOT remove anything from the external service.',
    'Are you sure you want to reserve a DOI now?  If the external dataset is still private, the DOI will become active once it is published.  Once a DOI is active, it cannot be disabled.',
    'Are you sure you want to publish this dataset now? This cannot be undone.',
    'The selected dataset archive is not associated with an external article!',
    'You must allow popup windows in your browser to continue',
    'Could not remove dataset published issues',
);

page_script_texts_ok(
    '/dataset/tool_compatibility.mas',
    'An error occurred calculating tool compatibility',
    'An error occurred retrieving tool compatibility',
    'Error calculating tool compatibility.',
    'Error retrieving tool compatibility.',
);

done_testing;
