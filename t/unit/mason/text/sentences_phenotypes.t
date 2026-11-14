=head1 NAME

t/unit/mason/text/sentences_phenotypes.t - phenotypes templates: sentences appear in the user's language

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
    '/phenotypes/submission_guide.mas',
    'For submitting phenotyping experiments to SGN you will be asked to fill in a few steps. Phenotypes are linked with plant accessions. If the accession is already in the database, you will have to make sure the accession in your file has exactly the same name. Search the {link}phenotype database{end_link} for existing accessions. Since phenotypes are scored on single plants in the field or a greenhouse, or on plots of several plants, you will need to assign in each experiment unique identifiers for each one of your experimental units (a single plant or a plot).',
    'following columns should have trait scored values. Headers should be ontology IDs. These terms {bold}must{end_bold} be pre-loaded in the database (e.g. the {link}Solanaceae Phenotype Ontology{end_link} ). If your ontology does not exist in the database, or if you have terms that need to be added to an existing ontology,{link2} contact us{end_link2} first.',
    '{strong}Organism name:{end_strong} Start typing the species scientific name. An autocomplete list should pop up. If your organism is not in the list, please {link}contact us{end_link}.',
    'Where the experiment was performed. We also support {link}WGS84 geodetic datum{end_link}. For a full geolocation fill in the longitude, latitide, and altitude fields.',
    '{strong}Repeat number{end_strong} (optional)',
);

done_testing;
