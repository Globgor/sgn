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

# BEGIN STAGE B1: sleep import, idle conditions, alert handling and fallbacks.
{
    package SGN::Test::WebDriverWaits::Imported;
    use SGN::Test::WWW::WebDriver;
    sub pause { sleep($_[0]); }
    sub pause_bare { sleep $_[0]; }
}

{
    package SGN::Test::WebDriverWaits::Plain;
    use SGN::Test::WWW::WebDriver ();
    sub pause { sleep($_[0]); }
}

$started = Time::HiRes::time();
SGN::Test::WebDriverWaits::Imported::pause_bare(3);
$elapsed = Time::HiRes::time() - $started;
cmp_ok($elapsed, '>=', 0.4, 'settled page observes a quiet window');
cmp_ok($elapsed, '<', 3, 'settled page shortens bare sleep');

page_script(q{
    window.webdriverWaitAjaxDone = false;
    jQuery.ajaxTransport('+*', function (options) {
        if (options.url.indexOf('webdriver_wait_ajax=1') === -1) { return; }
        var xhr = new XMLHttpRequest();
        return {
            send: function (headers, complete) {
                xhr.open('GET', options.url, true);
                xhr.onload = function () {
                    setTimeout(function () {
                        window.webdriverWaitAjaxDone = true;
                        window.webdriverWaitAjaxDoneAt = Date.now() / 1000;
                        complete(xhr.status, 'OK', {text: xhr.responseText}, xhr.getAllResponseHeaders());
                    }, 1200);
                };
                xhr.onerror = function () { complete(0, 'error'); };
                xhr.send();
            },
            abort: function () { xhr.abort(); }
        };
    });
    jQuery.ajax({url: '/documents/what_is.txt?webdriver_wait_ajax=1', cache: false});
});
$started = Time::HiRes::time();
SGN::Test::WebDriverWaits::Imported::pause(3);
$returned_at = Time::HiRes::time();
$elapsed = $returned_at - $started;
ok($driver->execute_script('return window.webdriverWaitAjaxDone;'), 'sleep waits for the jQuery request');
my $ajax_times = $driver->execute_script('return [window.webdriverWaitAjaxDoneAt, Date.now() / 1000];');
cmp_ok($ajax_times->[0] || $ajax_times->[1] + 10, '<=', $ajax_times->[1], 'jQuery completion precedes the end of sleep');
cmp_ok($elapsed, '>=', 0.35, 'pending jQuery request delays sleep');
cmp_ok($elapsed, '<', 3.5, 'jQuery wait is bounded by the requested sleep');

page_script(q{setTimeout(function () { alert('webdriver wait test initial'); }, 50);});
is(wait_for_alert(), 'webdriver wait test initial', 'initial test alert opened');
$started = Time::HiRes::time();
SGN::Test::WebDriverWaits::Imported::pause(2);
$elapsed = Time::HiRes::time() - $started;
cmp_ok($elapsed, '>=', 1.8, 'an initial alert retains the requested sleep');
is($driver->get_alert_text(), 'webdriver wait test initial', 'initial alert remains open');
$driver->accept_alert();

page_script(q{
    jQuery.active++;
    setTimeout(function () { alert('webdriver wait test delayed'); jQuery.active--; }, 1000);
});
$started = Time::HiRes::time();
SGN::Test::WebDriverWaits::Imported::pause(3);
$elapsed = Time::HiRes::time() - $started;
cmp_ok($elapsed, '<', 2.8, 'sleep returns when an alert appears during polling');
is($driver->get_alert_text(), 'webdriver wait test delayed', 'delayed alert remains open');
$driver->accept_alert();

{
    local $ENV{SGN_TEST_PLAIN_SLEEP} = 1;
    $started = Time::HiRes::time();
    SGN::Test::WebDriverWaits::Imported::pause(1);
    $elapsed = Time::HiRes::time() - $started;
    cmp_ok($elapsed, '>=', 0.8, 'plain-sleep environment switch keeps a real sleep');
    $started = Time::HiRes::time();
    SGN::Test::WebDriverWaits::Imported::pause(0.35);
    $elapsed = Time::HiRes::time() - $started;
    cmp_ok($elapsed, '>=', 0.3, 'plain fractional sleep retains its duration');
}

ok(!SGN::Test::WebDriverWaits::Plain->can('sleep'), 'empty import does not install sleep');
$started = Time::HiRes::time();
SGN::Test::WebDriverWaits::Plain::pause(1);
$elapsed = Time::HiRes::time() - $started;
cmp_ok($elapsed, '>=', 0.8, 'empty import leaves a real sleep');

{
    my $real_sleep;
    local *SGN::Test::WWW::WebDriver::_real_sleep = sub { $real_sleep = $_[0]; return $_[0]; };
    local *SGN::Test::WWW::WebDriver::_wait = sub { die 'long sleep entered page polling'; };
    my $ok = eval { SGN::Test::WebDriverWaits::Imported::pause(61); 1 };
    ok($ok, 'sleep over 60 seconds avoids page polling');
    is($real_sleep, 61, 'sleep over 60 seconds selects the real-sleep branch');
}
# END STAGE B1

# BEGIN STAGE B2: document navigation.
open_fixture();
$t->_page_script('return true;');
page_script(q{
    window.webdriverWaitBeforeUnload = false;
    setTimeout(function () {
        window.dispatchEvent(new Event('beforeunload'));
        window.webdriverWaitBeforeUnload = true;
    }, 200);
});
$started = Time::HiRes::time();
SGN::Test::WebDriverWaits::Imported::pause(2);
$elapsed = Time::HiRes::time() - $started;
ok($driver->execute_script('return window.webdriverWaitBeforeUnload;'), 'beforeunload event was delivered');
cmp_ok($elapsed, '>=', 1.8, 'beforeunload keeps the old document busy until the sleep deadline');

page_script(q{setTimeout(function () { alert('webdriver wait test leaving'); }, 1000);});
$started = Time::HiRes::time();
my $leaving_page_polls = 0;
{
    my $page_script = \&SGN::Test::WWW::WebDriver::_page_script;
    local *SGN::Test::WWW::WebDriver::_page_script = sub {
        $leaving_page_polls++;
        return $page_script->(@_);
    };
    SGN::Test::WebDriverWaits::Imported::pause(3);
}
$elapsed = Time::HiRes::time() - $started;
cmp_ok($elapsed, '>=', 2.8, 'a leaving document keeps the timed wait when an alert appears');
is($leaving_page_polls, 1, 'page polling stops after observing the leaving document');
is($driver->get_alert_text(), 'webdriver wait test leaving', 'navigation does not cause automatic alert acceptance');
$driver->accept_alert();

open_fixture();
$t->_page_script('return true;');
my $old_document = page_script(q{
    window.webdriverWaitOldDocument = true;
    var old = performance.timeOrigin || performance.timing.navigationStart;
    setTimeout(function () { location.reload(); }, 500);
    return old;
});
$started = Time::HiRes::time();
SGN::Test::WebDriverWaits::Imported::pause(3);
$returned_at = Time::HiRes::time();
$elapsed = $returned_at - $started;
my $navigation = $driver->execute_script(q{
    return [window.webdriverWaitOldDocument === undefined,
        performance.timeOrigin || performance.timing.navigationStart, Date.now()];
});
ok($navigation->[0], 'sleep does not return on the old document during reload');
isnt($navigation->[1], $old_document, 'reload changes the document time origin');
cmp_ok($navigation->[1], '<=', $navigation->[2], 'the new document existed before sleep returned');
cmp_ok(($navigation->[2] - $navigation->[1]) / 1000, '>=', 0.6, 'the new document receives its own quiet window');
cmp_ok($elapsed, '<', 3.5, 'reload wait is bounded by the requested sleep');
# END STAGE B2

alarm(0);
done_testing();
