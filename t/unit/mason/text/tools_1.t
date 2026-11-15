=head1 NAME

t/unit/mason/text/tools_1.t - tools templates, part 1 of 2: the text is shown in the user's language

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
    '/tools/available_seedlots.mas',
    'Select/Deselect All',
    'Breeding Program',
    'Seedlot Location',
    'Seedlot Name',
    'Accessions',
    'Weight(g)',
);

component_compiles_ok('/tools/boxplotter.mas');

page_texts_ok(
    '/tools/document_browser.mas',
    'Select TSV Document:',
    'Upload New Document',
    'Upload TSV Document',
    'Save new document',
    'Document Browser',
    'Type Search...',
);

component_compiles_ok('/tools/environment_stratification.mas');

component_compiles_ok('/tools/fieldmap.mas');

page_texts_ok(
    '/tools/gs.mas',
    'Note: This tool is not yet available.',
    'Predict Breeding Values',
    'Genomic Selection',
    'Generate Model',
);

component_compiles_ok('/tools/image_analysis.mas');

page_texts_ok(
    '/tools/mixedmodels.mas',
    'Choose the dependent variable for your analysis',
    '[ Choose dataset and dependent variable first ]',
    'Random factors with variable slope/intersects',
    'Choose the dataset for your analysis',
    'sommer with spatial correction spl2D',
    'Run analysis and go to next step',
);

page_texts_ok(
    '/tools/report.mas',
    'Your report was submitted. You’ll receive an email when it’s ready. Feel free to navigate to other pages.',
    'Enter email addresses separated by new lines (one per line)',
    'Welcome to the Personalized Report Generator',
    'Generate Report & Send Report',
    'Personalized Report Generator',
    'Available Report Scripts:',
);

component_compiles_ok('/tools/sixframe_translate_standalone.mas');

page_texts_ok(
    '/tools/tc_convert_deprecated.mas',
    'Converting between SGN unigenes and TGI TC sequences',
    'Mapping SGN-U to TGI TC',
    'Mapping TGI TC to SGN-U',
);

page_texts_ok(
    '/tools/trait_designer.mas',
    'The ontology that the new term will belong to. This is separate from the parent term(s) that the new term is chained to.',
    'Make it descriptive. Be sure to describe category meanings if using categorical data.',
    'Alternate names for the new term. Synonyms must not already exist in the database.',
    'Pipes (|)  will be removed from name.',
    'Optional. Pipes (|) will be removed.',
    'Optional. No special characters.',
);

done_testing;
