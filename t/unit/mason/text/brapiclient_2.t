=head1 NAME

t/unit/mason/text/brapiclient_2.t - brapiclient templates, part 2 of 3: the text is shown in the user's language

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
    '/brapiclient/markerprofile_detail.mas',
    'MarkerProfileDbId e.g. 1622',
    'MarkerProfile Details',
    'Get Details',
);

page_texts_ok(
    '/brapiclient/markerprofile_search.mas',
    'MarkerProfile Search',
    'Search',
);

page_texts_ok(
    '/brapiclient/observation_levels.mas',
    'Show ObservationLevels',
    'Observation Levels',
);

page_texts_ok(
    '/brapiclient/phenotypes_search.mas',
    'Phenotypes For a Study in ObservationUnits Format',
    'Phenotypes For a Study in Granular Format',
    'ObservationDbIds e.g. 70741,70666,70773',
    'Phenotypes For a Study in Table Format',
    'GermplasmDbIds e.g. 139',
    'StudyDbIds e.g. 139,137',
);

page_texts_ok(
    '/brapiclient/phenotyping_handhelds.mas',
    'Get Observation Variables',
    'Phenotyping Handhelds',
    'Get Trial Layout(s)',
    'Not yet implemented',
    'Database Select',
    'local',
);

page_texts_ok(
    '/brapiclient/programs.mas',
    'ProgramName e.g. test',
    'Get Programs',
    'Programs',
);

page_texts_ok(
    '/brapiclient/seasons.mas',
    'Show Seasons',
    'Seasons',
);

page_texts_ok(
    '/brapiclient/studies_detail.mas',
    'StudyDbId e.g. 137',
    'Study Details',
    'Get Details',
);

page_texts_ok(
    '/brapiclient/studies_germplasm.mas',
    'StudyDbId e.g. 139',
    'Study Germplasm',
    'Get Germplasm',
);

page_texts_ok(
    '/brapiclient/studies_layout.mas',
    'StudyDbId e.g. 139',
    'Study Layout',
    'Get Layout',
);

page_texts_ok(
    '/brapiclient/studies_observations.mas',
    'ObservationDbId e.g. 70666',
    'ObservationDbId e.g. 70741',
    'Study Observations',
    'StudyDbId e.g. 139',
    'Get Observations',
    'Plant',
);

page_texts_ok(
    '/brapiclient/studies_post.mas',
    'BrAPI Study POST',
);

done_testing;
