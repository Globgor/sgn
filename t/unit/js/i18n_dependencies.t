=head1 NAME

t/unit/js/i18n_dependencies.t - scripts with user messages load the translation functions first

=head1 DESCRIPTION

A script that shows messages calls gettext(), which CXGN/I18N.js defines. Each
legacy script must name that dependency, so that the server sends I18N.js (and
Tannin before it) ahead of the script. Each webpack entry must import it, which
the build turns into the same dependency.

=cut

use strict;
use warnings;

use JSAN::ServerSide;
use Test::More;

my @legacy = qw(
    CXGN/AJAX/Ontology CXGN/Blast CXGN/BreederSearch CXGN/BreedersToolbox/Accessions
    CXGN/BreedersToolbox/AddTrial CXGN/BreedersToolbox/CrossDetailPage CXGN/BreedersToolbox/Crosses
    CXGN/BreedersToolbox/DerivedAccessions CXGN/BreedersToolbox/FieldBook
    CXGN/BreedersToolbox/GenotypingSubmission CXGN/BreedersToolbox/GenotypingTrial
    CXGN/BreedersToolbox/HTMLSelect CXGN/BreedersToolbox/MarkerSet CXGN/BreedersToolbox/UploadGrafts
    CXGN/BreedersToolbox/UploadPedigrees CXGN/BreedersToolbox/UploadPhenotype
    CXGN/BreedersToolbox/UploadRenameAccessions CXGN/BreedersToolbox/UploadTrial CXGN/BreedersToolbox/Vector
    CXGN/Dataset CXGN/Effects CXGN/Effects/Hotlist CXGN/Hotlist CXGN/Image CXGN/Locations CXGN/Onto/Browser
    CXGN/Page/Comments CXGN/Page/Form/JSFormPage CXGN/Phenome/Locus CXGN/Phenome/Tools CXGN/SelectionIndex
    CXGN/Stock CXGN/Sunshine/NetworkBrowser CXGN/Transformation CXGN/TrialTreeFolders brapi/Table
    heritability/heritability qualityControl/qualityControl solGS/analysisSelect solGS/analysisStatus
    solGS/anova solGS/clearCache solGS/cluster solGS/combineTrials solGS/correlation
    solGS/gebvPhenoRegression solGS/gebvsSave solGS/geneticGain solGS/heatMap solGS/kinship
    solGS/listTypeSelectionPopulation solGS/listTypeTrainingPopulation solGS/loadAcronyms solGS/pca
    solGS/pcaSave solGS/searchTrials solGS/selectionIndex solGS/selectionPopulations solGS/solGS
    tools/LabelDesigner tools/vigs
);

my @entries = qw(
    dataset_scatterplot decision_meeting environments field_trial_linkage fieldmap job mixedmodels
    qualitycontrol sequenced_accessions trialallocation/app trialallocation/downloads vectorViewer wizard
);

for my $script (@legacy) {
    my $jsan = JSAN::ServerSide->new( js_dir => 'js/source/legacy', uri_prefix => '/js/legacy' );
    $jsan->add($script);
    my @uris = $jsan->uris;
    my %place;
    @place{@uris} = 0 .. $#uris;
    my ( $tannin, $i18n, $self ) = @place{ '/js/legacy/tannin_min.js', '/js/legacy/CXGN/I18N.js', "/js/legacy/$script.js" };
    ok( defined $tannin && defined $i18n && defined $self && $tannin < $i18n && $i18n < $self, "$script loads gettext first" );
}

for my $entry (@entries) {
    open( my $in, '<', "js/source/entries/$entry.js" ) or die "$entry: $!";
    my $source = do { local $/ = undef; <$in> };
    close $in;
    like( $source, qr{^import\s+(['"])(?:[.][.]/)+legacy/CXGN/I18N[.]js\1;}m, "$entry imports gettext" );
}

done_testing;
