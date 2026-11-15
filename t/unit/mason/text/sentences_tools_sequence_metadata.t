=head1 NAME

t/unit/mason/text/sentences_tools_sequence_metadata.t - tools/sequence_metadata templates: sentences appear in the user's language

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
    '/tools/sequence_metadata/api_sequence_metadata.mas',
    'Sequence Metadata queries can be made using a public API (Application Programming Interface). Below are the available endpoints related to sequence metadata that can be used to query the database using HTTP requests.',
    '{bold}Error:{end_bold} If an error is encountered processing the request, the response will return a JSON object with an {property} property containing an error message:',
    '{bold}default:{end_bold} max of specified feature',
    '{bold}default:{end_bold} none',
    '{bold}default:{end_bold} any',
);

page_sentences_ok(
    '/tools/sequence_metadata/protocols_sequence_metadata.mas',
    'View sequence metadata protocols associated with each sequence metadata data type. Click the name of the sequence metadata protocol to query data from that protocol.',
);

page_sentences_ok(
    '/tools/sequence_metadata/query_sequence_metadata.mas',
    'Return only sequence metadata features that have attribute values that match the added comparisons. If more than one attribute filter is added, the sequence metadata feature must match all of the filters.',
    '{icon}Back to Search',
);

component_compiles_ok('/tools/sequence_metadata/quick_query_sequence_metadata.mas');

page_sentences_ok(
    '/tools/sequence_metadata/upload_sequence_metadata_workflow.mas',
    'External links are defined using templates that can include the feature/chrom name, start and/or end position, and/or any attribute value as a variable in the URL. The variable will be replaced with the value for each sequence metadata result and displayed in the query results table. The variable in the URL takes the form of: {pattern} where {variable} can be: {feature}, {start}, {end} or the key of any attribute defined by the sequence metadata protocol.',
    'Select your gff3 file to upload. Then, click the {bold}Verify{end_bold} button to upload your file and check its format and contents. If successfully verified, click the {bold}Store{end_bold} button to store the data in the database.',
    'This workflow will guide you through the process of uploading sequence metadata to the database using a {link}gff3-formatted{end_link} file.',
    'If your data is not one of the above data types, please {link}contact us{end_link} about adding a new data type.',
    '{column} The name of the database feature (ie chromosome) the metadata is associated with',
    '{column} Secondary key/value attributes to be saved with the score',
);

done_testing;
