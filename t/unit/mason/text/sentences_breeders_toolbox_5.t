=head1 NAME

t/unit/mason/text/sentences_breeders_toolbox_5.t - breeders_toolbox templates, part 5 of 6: sentences appear in the user's language

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
    '/breeders_toolbox/trialtree.mas',
    'Double click{break}trial to view',
);

page_sentences_ok(
    '/breeders_toolbox/trialtreefolders.mas',
    'Double click{break}trial ({icon}) or folder ({icon2}){break2}to view detail page.',
    'Breeding programs ({icon})',
    'Sampling trials ({icon})',
    'Analyses ({icon})',
);

page_sentences_ok(
    '/breeders_toolbox/upload_accession_rename_dialog.mas',
    '({xls} or {xlsx} formats are {bold}NOT{end_bold} supported)',
);

page_sentences_ok(
    '/breeders_toolbox/upload_graft_dialogs.mas',
    '({xls} or {xlsx} formats are {bold}NOT{end_bold} supported)',
);

page_sentences_ok(
    '/breeders_toolbox/upload_images.mas',
    'The values in the {column} column should should match the image filenames in the zipfile.',
);

page_sentences_ok(
    '/breeders_toolbox/upload_locations_dialogs.mas',
    '{column} must be an exisiting Breeding Program in the database, or multiple breeding programs separated by {separator}',
    '{column} The NOAA Station ID that is nearest and most relevant to the location. {link}Search Here{end_link}',
    '{column} used in the map and in uploads, must not conflict with an existing abbreviation',
    '{column} must be an uppercase english short name from the {link}ISO standard{end_link}',
    '{column} must be an {link}ISO Alpha-3 country code{end_link}',
    '{column} must not conflict with an existing location name',
);

page_sentences_ok(
    '/breeders_toolbox/upload_nirs_spreadsheet_dialogs.mas',
    '{column}: Required field that matches with existing data in the database. It can be the plot name, subplots, plant name, or tissue sample, depending how your trial is designed.',
    '{column}: Optional identifier for each NIRS read. The {identifier} must be an integer.',
    '{column}: Optional field to identify your device. Strings are allowed.',
    '{column}: Optional identifier for each sample. Strings are allowed.',
    '{column}: Optional field. The format allowed is: {format}.',
    '{column}: Optional field for general comments.',
);

done_testing;
