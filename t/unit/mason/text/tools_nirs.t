=head1 NAME

t/unit/mason/text/tools_nirs.t - tools/nirs templates: the text is shown in the user's language

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
    '/tools/nirs/manage_nirs_main.mas',
    'View and manage uploaded NIRS data files',
    'View and manage your NIRS analyses',
    'View and manage your NIRS models',
    'These are deleted NIRS files',
    'Your Obsoleted NIRS Data',
    'All Obsoleted NIRS Data',
);

page_texts_ok(
    '/tools/nirs/nirs_analysis_plot_spectra_dialogs.mas',
    'Select the dataset you are interested in plotting spectra for (the accessions or plots or tissues samples in the dataset need to have spectra uploaded):',
    'Query related stocks (e.g. if you have accessions in the dataset, the query will search for spectra on associated plots, plants, etc. and vice versa):',
    'This workflow will guide you through querying and plotting spectral data in the database.',
    'Select the protocol you are interested in plotting spectra:',
    'Search Parameters:',
    'Go to Next Step',
);

page_texts_ok(
    '/tools/nirs/nirs_analysis_predict_dialogs.mas',
    'Select the dataset you are interested in predicting phenotypes for (the accessions or plots or tissues samples in the dataset need to have spectra uploaded):',
    'This workflow will guide you through predicting phenotypes from trained spectral models in the database.',
    'Select the spectral model to use in predictions',
    'Do you want to save the prediction results?:',
    'Predict Phenotypes From Spectral Model',
    'Predict Phenotypes from Spectral Model',
);

page_texts_ok(
    '/tools/nirs/nirs_analysis_train_dialogs.mas',
    'Select the trait you are interested in. If there are no available options, the training and test datasets you selected do not share any traits in common!',
    'Select the dataset you are interested in training (the accessions or plots or tissues samples in the dataset need to have spectra uploaded)',
    'Select Custom Dataset for Testing? If No, the training and test set will be partitioned from the training dataset you already selected:',
    'Dataset (Optional) (the accessions or plots or tissues samples in the dataset need to have spectra uploaded):',
    'This workflow will guide you through the training of a model using spectra and phenotypes in the database.',
    'Show random forest variable importance? (Note this may take a long time to run):',
);

done_testing;
