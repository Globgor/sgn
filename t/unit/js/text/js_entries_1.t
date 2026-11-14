=head1 NAME

t/unit/js/text/js_entries_1.t - scripts in entries, group 1: the messages go through gettext

=head1 DESCRIPTION

Each script must call gettext() for the messages listed here, and each legacy
script must be valid JavaScript (checked with Node.js when it is installed; a
webpack entry is a module, which the build checks). gettext() comes from
CXGN/I18N.js; t/unit/js/i18n_dependencies.t checks that it is loaded first.
This test does not run the scripts.

=cut

use strict;
use warnings;

use Test::More;

my @scripts = (
    [ 'js/source/entries/dataset_scatterplot.js',
        'gettext(\'outliers successfully stored!\')',
        'gettext(\'outliers successfully reseted!\')',
    ],
    [ 'js/source/entries/decision_meeting.js',
        'gettext(\'Please select one meeting first.\')',
        'gettext(\'Please select one accession list first.\')',
        'gettext(\'There are no accession decisions to save.\')',
        'gettext(\'Please select one meeting first so the year can be taken from the meeting date.\')',
        'gettext(\'Meeting ID not found.\')',
    ],
    [ 'js/source/entries/environments.js',
        'gettext(\'You must be logged in to use Environment Stratification\')',
        'gettext("An error occurred while preparing the dataset.")',
        'gettext("An error occurred while reading the phenotype file.")',
        'gettext("Please select a trait.")',
        'gettext("Alpha must be a number between 0 and 1.")',
        'gettext(\'Please select one dataset.\')',
        'gettext(\'Please select only one dataset.\')',
        'gettext(\'No results are available to download.\')',
        'gettext(\'XLSX export library is not available.\')',
        'gettext(\'XLSX export library is not compatible with this page.\')',
    ],
    [ 'js/source/entries/field_trial_linkage.js',
        'gettext("Error retrieving field trial to field trial linkage.")',
    ],
    [ 'js/source/entries/fieldmap.js',
        'gettext("An error occurred retrieving plot images")',
    ],
    [ 'js/source/entries/job.js',
        'gettext("Job dismissal removes record of this submission, but does not delete any resulting analyses or other data. Are you sure you want to proceed?")',
        'gettext("Error dismissing job.")',
        'gettext("Job record deleted.")',
        'gettext("Dismiss all finished and canceled jobs?")',
        'gettext("Error dismissing jobs.")',
        'gettext("Jobs cleared.")',
        'gettext("Are you sure you want to cancel?")',
        'gettext("Error canceling job.")',
        'gettext("Job canceled.")',
        'gettext("Dismiss old jobs?")',
        'gettext("Dismiss failed and timed out jobs?")',
    ],
    [ 'js/source/entries/mixedmodels.js',
        'gettext("Dropped!")',
        'gettext("ERROR!!!!!")',
        'gettext(\'Please select only one trait at a time to see the histogram!\')',
        'gettext(\'Please select at least one dataset!\')',
        'gettext(\'Please select only one dataset!\')',
    ],
    [ 'js/source/entries/qualitycontrol.js',
        'gettext(\'Please select a trait to see the boxplot!\')',
        'gettext(\'Error during AJAX request!\')',
        'gettext(\'Outliers successfully stored!\')',
        'gettext("Data successfully restored!")',
        'gettext("Only curators are allowed undo validated trial. Please contact a curator.")',
        'gettext(\'Error during restore!\')',
        'gettext(\'Please select at least one dataset!\')',
        'gettext(\'Please select only one dataset!\')',
    ],
);

my $node = grep { -x "$_/node" && !-d "$_/node" } split /:/, $ENV{PATH} // q{};

for my $script (@scripts) {
    my ( $file, @calls ) = @$script;
    open( my $in, '<:raw', $file ) or die "Cannot read $file: $!";
    my $source = do { local $/ = undef; <$in> };
    close $in;
    my @missing = grep { index( $source, $_ ) < 0 } @calls;
    ok( !@missing, "$file calls gettext for its messages" ) or diag( 'Missing: ', join( ', ', @missing ) );
  SKIP: {
        skip 'Node.js is not installed', 1 if !$node;
        skip 'a webpack entry, checked by the build', 1 if $file !~ m{/legacy/};
        is( system( 'node', '--check', $file ), 0, "$file is valid JavaScript" );
    }
}

done_testing;
