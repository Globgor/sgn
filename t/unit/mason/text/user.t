=head1 NAME

t/unit/mason/text/user.t - user templates: the text is shown in the user's language

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
    '/user/change_account.mas',
    'Your private e-mail address is not publicly displayed online. It is used only for SGN staff to contact you about changes to your record or for e-mailing your password to you. Changing your private e-mail address will trigger a confirmation message from SGN to verify the address is usable by SGN.',
    'Please verify your current password to make changes. Select changes desired by checking the appropriate checkbox and entering the new information.',
    'Change Account Information',
    'Update User Information',
    'Confirm password',
    'Change password',
);

page_texts_ok(
    '/user/login.mas',
    'Go back',
    'Login',
);

page_texts_ok(
    '/user/quick_create_account.mas',
    'Password (at least 7 characters)',
    'Username (at least 7 characters)',
    'Private Email Address',
    'Quick Create Account',
    'Confirm Password',
    'First Name',
);

page_texts_ok(
    '/user/reset_password_form.mas',
    'Confirm password',
    'Reset Password',
    'New password',
);

done_testing;
