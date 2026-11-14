package main;

use strict;
use warnings;

use lib 't/lib';

use Test::More;
use Time::HiRes ();
use SGN::Test::WWW::WebDriver ();

my ($t, $driver);
my $jquery;

END {
    alarm(0);
    if ($driver) {
        my $expired;
        local $SIG{ALRM} = sub { $expired = 1; die "WebDriver cleanup timed out\n"; };
        alarm(2);
        eval {
            my $text = eval { $driver->get_alert_text() };
            die "WebDriver cleanup timed out\n" if $expired;
            $driver->accept_alert() if defined $text && $text =~ /^webdriver wait test/;
            die "WebDriver cleanup timed out\n" if $expired;
            $driver->close();
        };
        alarm(0);
    }
}

local $SIG{ALRM} = sub { die "WebDriver wait tests exceeded 180 seconds\n" };
alarm(180);

{
    open my $file, '<:encoding(UTF-8)', 'js/source/legacy/jquery.js'
        or die "Cannot open repository jQuery: $!";
    local $/;
    $jquery = <$file>;
    close $file;
}

$t = SGN::Test::WWW::WebDriver->new();
$driver = $t->driver();
$driver->set_timeout('implicit', 0);

sub page_script {
    my ($script) = @_;
    return $driver->execute_script(q{
        var s = document.createElement('script');
        // Keep fixture functions in the same realm as the application hook.
        s.textContent = 'window.webdriverWaitScriptResult = (function () {\n' + arguments[0] + '\n})();';
        (document.head || document.documentElement).appendChild(s);
        s.remove();
        return window.webdriverWaitScriptResult;
    }, $script);
}

sub open_fixture {
    $t->get('/documents/what_is.txt');
    page_script($jquery);
    my $deadline = Time::HiRes::time() + 4;
    while (Time::HiRes::time() < $deadline) {
        return 1 if eval { $driver->execute_script(q{
            return document.readyState === 'complete' && window.jQuery && jQuery.active === 0;
        }) };
        Time::HiRes::sleep(0.1);
    }
    die "Static fixture did not become ready\n";
}

sub wait_for_alert {
    my $deadline = Time::HiRes::time() + 2;
    while (Time::HiRes::time() < $deadline) {
        my $text = eval { $driver->get_alert_text() };
        return $text if defined $text;
        Time::HiRes::sleep(0.05);
    }
    die "Expected test alert did not open\n";
}

# BEGIN STAGE A: element lookup and modal coverage.
open_fixture();
my $capabilities = eval { $driver->get_capabilities() };
is(ref($capabilities), 'HASH', 'session capabilities are available');
is(ref($capabilities) eq 'HASH' ? $capabilities->{unhandledPromptBehavior} : undef,
    'ignore', 'session keeps unexpected alerts open');
page_script(q{setTimeout(function () { alert('webdriver wait test guard'); }, 50);});
is(wait_for_alert(), 'webdriver wait test guard', 'guard test alert opened');
my $command_succeeded = eval { $driver->execute_script('return 1;'); 1 };
my $command_error = $@;
ok(!$command_succeeded, 'page command is rejected while an alert is open');
like($command_error, qr/unexpected alert open/i, 'open alert reports the WebDriver prompt error');
my $guard_alert = eval { $driver->get_alert_text() };
is($guard_alert, 'webdriver wait test guard', 'rejected page command leaves the alert open');
$driver->accept_alert() if defined $guard_alert && $guard_alert eq 'webdriver wait test guard';

$driver->execute_script(q{
    var hidden = document.createElement('div');
    hidden.id = 'webdriver_wait_hidden';
    hidden.style.display = 'none';
    document.body.appendChild(hidden);
});
my $started = Time::HiRes::time();
my $hidden = $t->find_element('webdriver_wait_hidden', 'id');
my $elapsed = Time::HiRes::time() - $started;
is($hidden->get_attribute('id'), 'webdriver_wait_hidden', 'hidden element is returned');
cmp_ok($elapsed, '<', 2, 'hidden element does not wait for visibility');

$started = Time::HiRes::time();
my $found = eval { $t->find_element('webdriver_wait_absent', 'id'); 1 };
my $error = $@;
$elapsed = Time::HiRes::time() - $started;
ok(!$found, 'absent element throws');
like($error, qr/no such element|unable to locate/i, 'absent element keeps the lookup error');
cmp_ok($elapsed, '<', 2, 'absent element does not wait for the guard');

page_script(q{
    var button = document.createElement('button');
    button.id = 'webdriver_wait_button';
    button.style.cssText = 'position:fixed;left:40px;top:40px;width:80px;height:40px;z-index:2147483600';
    document.body.appendChild(button);
    var cover = document.createElement('div');
    cover.className = 'modal-backdrop in';
    cover.style.cssText = 'position:fixed;left:0;top:0;width:100%;height:100%;z-index:2147483647;opacity:0.2';
    document.body.appendChild(cover);
    window.webdriverWaitCoverRemoved = false;
    setTimeout(function () {
        cover.remove();
        window.webdriverWaitCoverRemoved = true;
        window.webdriverWaitCoverRemovedAt = Date.now() / 1000;
    }, 1200);
});
ok($driver->execute_script('return !window.webdriverWaitCoverRemoved;'), 'backdrop is present before lookup');
$started = Time::HiRes::time();
my $button = $t->find_element('webdriver_wait_button', 'id');
my $returned_at = Time::HiRes::time();
$elapsed = $returned_at - $started;
is($button->get_attribute('id'), 'webdriver_wait_button', 'covered element is returned');
ok($driver->execute_script('return window.webdriverWaitCoverRemoved;'), 'lookup waits for the backdrop to disappear');
my $cover_times = $driver->execute_script('return [window.webdriverWaitCoverRemovedAt, Date.now() / 1000];');
cmp_ok($cover_times->[0] || $cover_times->[1] + 10, '<=', $cover_times->[1], 'backdrop was removed before lookup returned');
cmp_ok($elapsed, '>=', 0.2, 'backdrop delays the lookup');
cmp_ok($elapsed, '<', 3, 'lookup resumes after the backdrop disappears');

my @guard_notes;
{
    my $original_note = \&SGN::Test::WWW::WebDriver::note;
    local *SGN::Test::WWW::WebDriver::_wait = sub { return 0; };
    local *SGN::Test::WWW::WebDriver::note = sub {
        return push @guard_notes, @_ if $_[0] =~ /Timed out waiting for uncovered element/;
        return $original_note->(@_);
    };
    $t->find_element('webdriver_wait_button', 'id');
}
like(join('', @guard_notes), qr/Timed out waiting for uncovered element webdriver_wait_button/,
    'a guard timeout records its locator');
page_script(q{
    var cover = document.createElement('div');
    cover.className = 'modal-backdrop in';
    cover.style.cssText = 'position:fixed;left:0;top:0;width:100%;height:100%;z-index:2147483647;opacity:0.2';
    document.body.appendChild(cover);
    window.webdriverWaitCacheCoverRemoved = false;
    setTimeout(function () { cover.remove(); window.webdriverWaitCacheCoverRemoved = true; }, 3000);
});
$started = Time::HiRes::time();
$button = $t->find_element('webdriver_wait_button', 'id');
$elapsed = Time::HiRes::time() - $started;
is($button->get_attribute('id'), 'webdriver_wait_button', 'lookup still returns the covered element after a timeout');
ok(!$driver->execute_script('return window.webdriverWaitCacheCoverRemoved;'), 'a later lookup skips repeated coverage waiting');
cmp_ok($elapsed, '<', 2.5, 'a previous timeout prevents another full guard wait');
open_fixture();
# END STAGE A


alarm(0);
done_testing();
