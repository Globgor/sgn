=head1 NAME

t/unit/mason/text/sentences_util.t - util templates: sentences appear in the user's language

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
    '/util/styleguide.mas',
    'To import JavaScript one should use the {component} mason component. This will ensure that the script is loaded in the {head_tag} instead of being part of the {body_tag}. One provides this mason componant with a list of strings which are the path to the JavaScript file with slashes replaced by periods (e.g. {expression}) and the file extension removed.',
    'To import CSS one should use the {component} mason component instead of a {link_tag} element. This will ensure that a link is added to the {head_tag} instead of being part of the {body_tag}. One provides this mason componant with a list of strings which are one of the following:',
    'After the final step is completed, an endscreen will be shown. To set the content of the endscreen, use the {complete_method} mason method. You can also optionally set a special endscreen which is shown instead while there are pending steps using {pending_method}.',
    'By default, {complete_function}, {skip_function}, and {pending_function} also change the focus to the next step. Sometimes, you need to set a step to complete without changing the focus. To do this, pass {argument} as the second argument.',
    'Sometimes a step needs time to complete, such as uploads. You can mark a step as pending using {pending_function}. You can later fully complete the step using {complete_function}.',
    'Use the {function} JavaScript function to complete a step. {element} should be any DOM element within the step you would like to complete.',
);

done_testing;
