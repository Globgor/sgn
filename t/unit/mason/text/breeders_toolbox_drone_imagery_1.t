=head1 NAME

t/unit/mason/text/breeders_toolbox_drone_imagery_1.t - breeders_toolbox/drone_imagery templates, part 1 of 3: the text is shown in the user's language

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
    '/breeders_toolbox/drone_imagery/drone_imagery_analysis.mas',
    'AIREMLf90 GBLUPs Y~replicate+GRM+temporal random regression using days after planting. Multivariate genetic + permanent environment effects',
    'AIREMLf90 GBLUPs Y~replicate+GRM+temporal random regression using growing degree days. Multivariate genetic + permanent environment effects',
    'Genotyping Protocol To Calculate Genomic Relationship Matrix (optional. If none selected, an identity matrix is used):',
    'Sommer Spatial GBLUPs Y~replicate+GRM+spatial. Multivariate genetic + 2Dspl spatial effects',
    'Go To Save Analysis Results For Genetic and Environment BLUPS and Residuals',
    'How to calculate the relationship matrix with high-throughput phenotypes:',
);

page_texts_ok(
    '/breeders_toolbox/drone_imagery/drone_imagery_analytics.mas',
    'Select the field trial you are interested in. Select only one. Field trial MUST have row and column assigned and should be a rectangular design.',
    'AIREMLf90 GBLUPs Y~replicate+GRM+temporal random regression using days after planting. Multivariate genetic + permanent environment effects',
    'Genotyping Protocol To Calculate Genomic Relationship Matrix (optional. If none selected, an identity matrix is used):',
    'Sommer Spatial GBLUPs Y~replicate+GRM+Row+Col+2Dspline. Multivariate genetic + 2Dspl spatial effects',
    'ASREML Spatial GBLUPs Y~replicate+GRM+Row+Col+spatial. Univariate genetic + AR1xAR1 spatial effects',
    'Sommer Spatial GBLUPs Y~replicate+GRM+Row+Col+2Dspline. Univariate genetic + 2Dspl spatial effects',
);

page_texts_ok(
    '/breeders_toolbox/drone_imagery/drone_imagery_export_imaging_events.mas',
    'Exporting imaging events will return a spreadsheet file defining the imaging events, a zipfile containing the orthophoto imges, and a zipfile containing the GeoJSON plot-polygon definitions.',
    'Phenotypic values will not be exported in this workflow, please use the Wizard of the "Download Image-Phenotype File" to retrieve phenotypic values.',
    'Exporting imaging events is important for transferring data across ImageBreed instances.',
    'This workflow will guide you through exporting aerial imaging event(s) from the database',
    'Export Aerial Imaging Event(s)',
    'Go to export imaging event(s)',
);

page_texts_ok(
    '/breeders_toolbox/drone_imagery/drone_run_details.mas',
    'Imaging Event Date',
    'Imaging Event Name',
    'Description',
);

page_texts_ok(
    '/breeders_toolbox/drone_imagery/generate_plot_polygons_section.mas',
    'View and edit template parameters. These parameters can be filled using the above button clicks',
    'Draw Plot Polygon Template (Does not save. Apply multiple templates if needed.)',
    'View and use previous plot polygon templates used on this field trial',
    'Previously Used Plot Polygon Templates For This Field Trial:',
    'Either click the four corners of the area of interest:',
    'Draw Plot Polygon Template (Does not save)',
);

page_texts_ok(
    '/breeders_toolbox/drone_imagery/generate_plot_polygons_standard_process_raw_images_section.mas',
    'View and edit template parameters. These parameters can be filled using the above button clicks',
    '(A) Draw Plot Polygon Template (Does not save. Apply multiple templates if needed.)',
    'View and use previous plot polygon templates used on this field trial',
    'Previously Used Plot Polygon Templates For This Field Trial:',
    'Either (A) Click the four corners of the area of interest:',
    '(B) Draw Plot Polygon Template (Does not save)',
);

page_texts_ok(
    '/breeders_toolbox/drone_imagery/generate_plot_polygons_standard_process_raw_images_section_ground_control_points.mas',
    'If a previous imaging event on this field experiment has already completed the standard process and has ground control points (GCPs) defined, then that imaging event can be used to automate the rest of the standard process on this new imaging event.',
    'Has a previous imaging event on this field trial completed the standard process and also has GCPs defined already?:',
    'Please click and save at least three points. The names of the GCPs MUST be consistent across imaging events!',
    'For best results, use ground control points at the far four corners of the field.',
    'Click on the ground control points (GCPs) in the image below and save them.',
    'Select the aerial imaging event to use as a template:',
);

done_testing;
