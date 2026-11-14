=head1 NAME

t/unit/mason/text/tools_sequence_metadata.t - tools/sequence_metadata templates: the text is shown in the user's language

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
    '/tools/sequence_metadata/api_sequence_metadata.mas',
    'Perform a query of the stored sequence metadata for a specific parent feature (i.e., chromosome) using any combination of additional filter criteria, provided as query parameters.  The feature must be provided, either by the feature ID or by the feature and species names.  If either the start or end positions are given, the name of the reference genome for those positions must be provided.',
    'nd_protocol_id(s) of sequence metadata protocol(s) (comma separated list of multiple nd_protocol_ids)',
    'Get all of the parent features (i.e., chromosomes) associated with loaded sequence metadata',
    'cvterm_id(s) of sequence metadata type(s) (comma separated list of multiple type_ids)',
    'Name of the parent feature (i.e., chromosome) associated with the sequence metadata',
    'ID of the parent feature (i.e., chromosome) associated with the sequence metadata',
);

page_texts_ok(
    '/tools/sequence_metadata/manage_sequence_metadata_main.mas',
    'View and query existing sequence metadata',
    'Query sequence metadata through an API',
    'Sequence Metadata Protocols',
    'Sequence Metadata API',
);

page_texts_ok(
    '/tools/sequence_metadata/query_sequence_metadata.mas',
    'Filter the sequence metadata by position, sequence metadata type and/or protocol, and/or by protocol attribute value(s).',
    'Querying the database for the requested sequence metadata...',
    'Filter by attribute values',
    'Data Type Information',
    'Greater Than or Equal',
    'Protocol Information',
);

component_compiles_ok('/tools/sequence_metadata/quick_query_sequence_metadata.mas');

page_texts_ok(
    '/tools/sequence_metadata/upload_sequence_metadata_workflow.mas',
    'Specifying the attribute here in the protocol will allow the attribute to be used as a filter in a query.  Make sure the attribute key exactly matches the key used in the gff file.',
    'Add templates for generating external links displayed with the sequence metadata results.',
    'Add a description for each of the key/value pairs included in the attributes column.',
    'Select a protocol for how your data was generated or create a new protocol',
    'The following gff3 columns are used by the sequence metadata uploader:',
    'The names in this column must match existing features in the database.',
);

done_testing;
