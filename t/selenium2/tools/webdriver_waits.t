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

local $SIG{ALRM} = sub { BAIL_OUT('WebDriver wait tests exceeded 27 seconds') };
alarm(27);

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

sub open_fixture {
    $t->get('/documents/what_is.txt');
    $driver->execute_script($jquery);
    my $deadline = Time::HiRes::time() + 4;
    while (Time::HiRes::time() < $deadline) {
        return 1 if eval { $driver->execute_script(q{
            return document.readyState === 'complete' && window.jQuery && jQuery.active === 0;
        }) };
        Time::HiRes::sleep(0.1);
    }
    BAIL_OUT('Static fixture did not become ready');
}

sub wait_for_alert {
    my $deadline = Time::HiRes::time() + 2;
    while (Time::HiRes::time() < $deadline) {
        my $text = eval { $driver->get_alert_text() };
        return $text if defined $text;
        Time::HiRes::sleep(0.05);
    }
    BAIL_OUT('Expected test alert did not open');
}

# BEGIN STAGE A: element lookup and modal coverage.
open_fixture();
my $capabilities = eval { $driver->get_capabilities() };
is(ref($capabilities), 'HASH', 'session capabilities are available');
is(ref($capabilities) eq 'HASH' ? $capabilities->{unhandledPromptBehavior} : undef,
    'ignore', 'session keeps unexpected alerts open');
$driver->execute_script(q{setTimeout(function () { alert('webdriver wait test guard'); }, 50);});
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

$driver->execute_script(q{
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
my $removed_at = $driver->execute_script('return window.webdriverWaitCoverRemovedAt;');
cmp_ok($removed_at || $returned_at + 10, '<=', $returned_at + 0.02, 'backdrop was removed before lookup returned');
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
$driver->execute_script(q{
    var cover = document.createElement('div');
    cover.className = 'modal-backdrop in';
    cover.style.cssText = 'position:fixed;left:0;top:0;width:100%;height:100%;z-index:2147483647;opacity:0.2';
    document.body.appendChild(cover);
    window.webdriverWaitCacheCoverRemoved = false;
    setTimeout(function () { cover.remove(); window.webdriverWaitCacheCoverRemoved = true; }, 1400);
});
$started = Time::HiRes::time();
$button = $t->find_element('webdriver_wait_button', 'id');
$elapsed = Time::HiRes::time() - $started;
is($button->get_attribute('id'), 'webdriver_wait_button', 'lookup still returns the covered element after a timeout');
ok(!$driver->execute_script('return window.webdriverWaitCacheCoverRemoved;'), 'a later lookup skips repeated coverage waiting');
cmp_ok($elapsed, '<', 1.2, 'a previous timeout prevents another full guard wait');
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

$driver->execute_script(q{
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
my $ajax_done_at = $driver->execute_script('return window.webdriverWaitAjaxDoneAt;');
cmp_ok($ajax_done_at || $returned_at + 10, '<=', $returned_at + 0.02, 'jQuery completion precedes the end of sleep');
cmp_ok($elapsed, '>=', 0.35, 'pending jQuery request delays sleep');
cmp_ok($elapsed, '<', 3.5, 'jQuery wait is bounded by the requested sleep');

$driver->execute_script(q{setTimeout(function () { alert('webdriver wait test initial'); }, 50);});
is(wait_for_alert(), 'webdriver wait test initial', 'initial test alert opened');
$started = Time::HiRes::time();
SGN::Test::WebDriverWaits::Imported::pause(2);
$elapsed = Time::HiRes::time() - $started;
cmp_ok($elapsed, '>=', 1.8, 'an initial alert retains the requested sleep');
is($driver->get_alert_text(), 'webdriver wait test initial', 'initial alert remains open');
$driver->accept_alert();

$driver->execute_script(q{setTimeout(function () { alert('webdriver wait test delayed'); }, 300);});
$started = Time::HiRes::time();
SGN::Test::WebDriverWaits::Imported::pause(3);
$elapsed = Time::HiRes::time() - $started;
cmp_ok($elapsed, '<', 2, 'sleep returns when an alert appears during polling');
is($driver->get_alert_text(), 'webdriver wait test delayed', 'delayed alert remains open');
$driver->accept_alert();

{
    local $ENV{SGN_TEST_PLAIN_SLEEP} = 1;
    $started = Time::HiRes::time();
    SGN::Test::WebDriverWaits::Imported::pause(1);
    $elapsed = Time::HiRes::time() - $started;
    cmp_ok($elapsed, '>=', 0.8, 'plain-sleep environment switch keeps a real sleep');
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

# BEGIN STAGE B2: passive fetch observation and document navigation.
open_fixture();
$driver->execute_script(q{
    window.webdriverWaitNativeFetch = window.fetch;
    window.webdriverWaitNativeJson = Response.prototype.json;
    window.webdriverWaitNativeText = Response.prototype.text;
    window.webdriverWaitSawResource = false;
    if (window.PerformanceObserver) {
        try {
            window.webdriverWaitObserver = new PerformanceObserver(function (list) {
                list.getEntries().forEach(function (entry) {
                    if (entry.name === window.webdriverWaitFetchUrl && entry.initiatorType === 'fetch' && entry.responseEnd > 0) {
                        window.webdriverWaitSawResource = true;
                        window.webdriverWaitSawResourceAt = Date.now() / 1000;
                    }
                });
            });
            window.webdriverWaitObserver.observe({entryTypes: ['resource']});
        } catch (error) {
            window.webdriverWaitObserver = null;
        }
    }
    window.fetch = function () {
        window.webdriverWaitOriginalPromise = window.webdriverWaitNativeFetch.apply(this, arguments);
        return window.webdriverWaitOriginalPromise;
    };
});
$t->find_element('body', 'css');
my $same_promise = $driver->execute_script(q{
    window.webdriverWaitFetchDone = 'pending';
    window.webdriverWaitFetchMethods = false;
    window.webdriverWaitFetchUrl = new URL('/documents/what_is.txt?webdriver_wait_fetch=1', location.href).href;
    var promise = fetch(window.webdriverWaitFetchUrl);
    var same = promise === window.webdriverWaitOriginalPromise;
    promise.then(function (response) {
        window.webdriverWaitFetchMethods = response.json === window.webdriverWaitNativeJson &&
            response.text === window.webdriverWaitNativeText;
        if (!response.ok) { throw new Error('HTTP ' + response.status); }
        return response.text();
    }).then(function () { window.webdriverWaitFetchDone = 'done'; window.webdriverWaitFetchDoneAt = Date.now() / 1000; },
        function (error) { window.webdriverWaitFetchDone = 'error: ' + error; });
    return same;
});
ok($same_promise, 'fetch returns the original native promise');
$started = Time::HiRes::time();
SGN::Test::WebDriverWaits::Imported::pause(3);
$returned_at = Time::HiRes::time();
$elapsed = $returned_at - $started;
my $fetch_state = $driver->execute_script(q{
    return [window.webdriverWaitFetchDone, window.webdriverWaitFetchMethods,
        window.webdriverWaitSawResource,
        window.webdriverWaitFetchDoneAt, window.webdriverWaitSawResourceAt];
});
is($fetch_state->[0], 'done', 'sleep does not return before native fetch completes');
cmp_ok($fetch_state->[3] || $returned_at + 10, '<=', $returned_at + 0.02, 'native fetch body completes before sleep returns');
ok($fetch_state->[1], 'fetch does not replace response body methods');
my $timing_ok = !$fetch_state->[2] ? $elapsed >= 2.8
    : $fetch_state->[4] <= $started + 1.5 ? $elapsed < 3
    : $elapsed >= 0.4;
ok($timing_ok,
    'completed resource timing allows early return; missing timing uses the full sleep');

open_fixture();
$driver->execute_script(q{
    window.webdriverWaitNativeFetch = window.fetch;
    window.fetch = function () {
        var args = arguments, receiver = this;
        var promise = new Promise(function (resolve, reject) {
            setTimeout(function () {
                window.webdriverWaitNativeFetch.apply(receiver, args).then(resolve, reject);
            }, 1000);
        });
        window.webdriverWaitOriginalPromise = promise;
        return promise;
    };
});
$t->find_element('body', 'css');
$same_promise = $driver->execute_script(q{
    window.webdriverWaitDelayedDone = 'pending';
    var promise = fetch('/documents/what_is.txt?webdriver_wait_delayed=1');
    var same = promise === window.webdriverWaitOriginalPromise;
    promise.then(function (response) { return response.text(); }).then(function () {
        window.webdriverWaitDelayedDone = 'done';
        window.webdriverWaitDelayedDoneAt = Date.now() / 1000;
    }, function (error) { window.webdriverWaitDelayedDone = 'error: ' + error; });
    return same;
});
ok($same_promise, 'delayed fetch returns the original promise');
$started = Time::HiRes::time();
SGN::Test::WebDriverWaits::Imported::pause(2);
$returned_at = Time::HiRes::time();
$elapsed = $returned_at - $started;
is($driver->execute_script('return window.webdriverWaitDelayedDone;'), 'done', 'sleep waits for a delayed fetch promise');
my $delayed_done_at = $driver->execute_script('return window.webdriverWaitDelayedDoneAt;');
cmp_ok($delayed_done_at || $returned_at + 10, '<=', $returned_at + 0.02, 'delayed fetch completes before sleep returns');
cmp_ok($elapsed, '>=', 0.6, 'unresolved fetch delays sleep');

open_fixture();
$driver->execute_script(q{
    window.webdriverWaitJson = Response.prototype.json;
    window.webdriverWaitBodyDone = false;
    window.fetch = function () {
        var stream = new ReadableStream({
            start: function (controller) {
                setTimeout(function () {
                    controller.enqueue(new TextEncoder().encode('{"ok":true}'));
                    controller.close();
                }, 1400);
            }
        });
        window.webdriverWaitResponse = new Response(stream, {headers: {'Content-Type': 'application/json'}});
        window.webdriverWaitOriginalPromise = Promise.resolve(window.webdriverWaitResponse);
        return window.webdriverWaitOriginalPromise;
    };
});
$t->find_element('body', 'css');
$same_promise = $driver->execute_script(q{
    var promise = fetch('/documents/what_is.txt?webdriver_wait_fake=1');
    var same = promise === window.webdriverWaitOriginalPromise;
    promise.then(function (response) {
        window.webdriverWaitJsonSame = response.json === window.webdriverWaitJson;
        return response.json();
    }).then(function (value) {
        window.webdriverWaitBodyDone = value.ok;
        window.webdriverWaitBodyDoneAt = Date.now() / 1000;
    });
    return same;
});
ok($same_promise, 'fetch preserves the original promise for a delayed body');
$started = Time::HiRes::time();
SGN::Test::WebDriverWaits::Imported::pause(2);
$returned_at = Time::HiRes::time();
$elapsed = $returned_at - $started;
ok($driver->execute_script('return window.webdriverWaitBodyDone;'), 'sleep does not return before the delayed body is read');
my $body_done_at = $driver->execute_script('return window.webdriverWaitBodyDoneAt;');
cmp_ok($body_done_at || $returned_at + 10, '<=', $returned_at + 0.02, 'delayed body completes before sleep returns');
ok($driver->execute_script('return window.webdriverWaitJsonSame;'), 'delayed response keeps its original json method');
cmp_ok($elapsed, '>=', 1, 'unobservable body completion does not cause an early return');

open_fixture();
$driver->execute_script(q{
    window.webdriverWaitNativeFetch = window.fetch;
    window.fetch = function () {
        window.webdriverWaitOriginalPromise = window.webdriverWaitNativeFetch.apply(this, arguments);
        return window.webdriverWaitOriginalPromise;
    };
});
$t->find_element('body', 'css');
$same_promise = $driver->execute_script(q{
    var controller = new AbortController();
    controller.abort();
    window.webdriverWaitAbortName = '';
    window.webdriverWaitAbortCount = 0;
    var promise = fetch('/documents/what_is.txt?webdriver_wait_abort=1', {signal: controller.signal});
    var same = promise === window.webdriverWaitOriginalPromise;
    promise.catch(function (error) {
        window.webdriverWaitAbortName = error.name;
        window.webdriverWaitAbortCount++;
    });
    return same;
});
ok($same_promise, 'aborted fetch returns the original promise');
my $deadline = Time::HiRes::time() + 2;
my $abort_name = '';
while (Time::HiRes::time() < $deadline) {
    $abort_name = $driver->execute_script('return window.webdriverWaitAbortName;');
    last if $abort_name;
    Time::HiRes::sleep(0.05);
}
is($abort_name, 'AbortError', 'aborted fetch preserves its rejection');
is($driver->execute_script('return window.webdriverWaitAbortCount;'), 1, 'application observes the rejection once');

open_fixture();
$t->find_element('body', 'css');
$driver->execute_script(q{
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

$driver->execute_script(q{setTimeout(function () { alert('webdriver wait test leaving'); }, 300);});
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
$t->find_element('body', 'css');
my $old_document = $driver->execute_script(q{
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
        performance.timeOrigin || performance.timing.navigationStart];
});
ok($navigation->[0], 'sleep does not return on the old document during reload');
isnt($navigation->[1], $old_document, 'reload changes the document time origin');
cmp_ok($navigation->[1] / 1000, '<=', $returned_at + 0.02, 'the new document existed before sleep returned');
cmp_ok($returned_at - $navigation->[1] / 1000, '>=', 0.6, 'the new document receives its own quiet window');
cmp_ok($elapsed, '<', 3.5, 'reload wait is bounded by the requested sleep');
# END STAGE B2

alarm(0);
done_testing();
