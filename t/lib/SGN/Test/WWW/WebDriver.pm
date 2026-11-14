
=head1 NAME

SGN::Test::WWW::WebDriver - a wrapper around the Selenium::Remote::Driver tailored to the SGN codebase

=head1 SYNOPSIS

Your test script should look somewhat like this:

use strict;
use SGN::Test::WWW::WebDriver;

my $swd = SGN::Test::WWW::WebDriver->new();

$swd->get_ok('/my_favorite_url');
$swd->find_element_ok('frufrubutton', 'id');
# etc...

=head1 DESCRIPTION

This class does not inherit from Selenium::Remote::Driver, because that class is not implemented in Moose. Instead, this class has_a Selenium::Remote::Driver, which is accessible with the driver() accessor.

There are a number of convenience methods:

Perform logins using different account statuses:

* login_as($user_type) # curator, submitter, user

* logout() 

* while_logged_in_as($user_type, sub { ... })


Note that these function require the use of the cxgn_fixture database. The database fixture is loaded from a dump each time the tests are run when using the t/test_fixture.pl script.

Convenience accessors for driver functions:

* get() - same as the driver get, except that the host part of the url is added from the conf

* get_ok() - the get() wrapped around and ok

* find_element() - finds immediately, then waits up to 60 seconds for modal overlays; off-screen elements are scrolled into view. Hidden elements and timed-out lookups return the original element. After a timeout, further lookups on that document skip the guard.

* find_element_ok() - wraps the find_element in an ok() test.

* select_datatable_tab() - selects a DataTable tab by its target pane ID.

For all other driver functions, use the driver() accessor, for example: $swd->driver->get_window_size().

For downloads, a /download dir needs to be mapped in the breedbase_web docker and in the selenium docker to the same host dir. The download dir can be obtained from this object using $d->download_dir(); .


=head1 SLEEP OVERRIDE

Plain C<use SGN::Test::WWW::WebDriver;> replaces unqualified C<sleep> in the calling package with a page-settling wait, bounded by the requested duration except for remote-command latency. It observes jQuery and modal transitions for 0.75 seconds of quiet (0.5 seconds for pauses of one second or less). Existing alerts and sleeps longer than 60 seconds retain real sleeps. Leaving documents receive only document-token checks while no alert is open; page settling resumes on the new document. A page that fires beforeunload without leaving (for example, a download link) receives full sleeps.

Use C<use SGN::Test::WWW::WebDriver ();> to avoid installing the override, or set C<SGN_TEST_PLAIN_SLEEP=1> to retain real sleeps while bisecting a run. Sleeps without an argument retain Perl's original behavior. Fractional sleeps really sleep, using C<Time::HiRes>. Timers with gaps longer than 0.75 seconds are not observed. Body parsing and application callbacks still require their own result conditions.

=head1 ALERTS

Unexpected alerts stay open (C<unhandledPromptBehavior=ignore>) instead of being dismissed by the next command. Tests must explicitly accept or dismiss them.

=head1 AUTHOR

Lukas Mueller <lam87@cornell.edu>

=cut

 

package SGN::Test::WWW::WebDriver;

use Moose;

use Try::Tiny;
use Time::HiRes ();
use Package::Stash;
use Test::More;
use File::Spec::Functions;
use Selenium::Firefox;
use Selenium::Firefox::Profile;
use Selenium::Remote::Driver;


has 'host' => ( is => 'rw',
	      isa => 'Str',
		default => sub { $ENV{SGN_TEST_SERVER} },
    );

has 'driver' => ( is => 'rw',
		  isa => 'Selenium::Remote::Driver',
		  default => sub { Selenium::Remote::Driver->new('base_url' => $ENV{SGN_TEST_SERVER}, 'remote_server_addr' => $ENV{SGN_REMOTE_SERVER_ADDR} || 'localhost') },
    );

has 'user_data' => ( is => 'rw',
		     isa => 'Ref',
		     default => sub { 
			 { 
			     curator   => { username => 'janedoe',
					    password => 'secretpw',
			     },
			     user      => { username => 'freddy',
					    password => 'atgc',
			     },
			     submitter => { username => 'johndoe',
					    password => 'secretpw',
			     },
			 }
		     });

has 'download_dir' => (is => 'ro',
		       isa => 'Str',
		       default => sub {
			        return "/downloads";
			   }
    );

our $webdriver_instance;

sub import {
    return if @_ > 1;
    my $caller = caller;
    # Replace only unqualified sleeps in the importing test package.
    Package::Stash->new($caller)->add_symbol('&sleep', \&_settled_sleep);
}

sub _real_sleep { return Time::HiRes::sleep($_[0]); }

sub _settled_sleep {
    return CORE::sleep() unless @_;
    my ($seconds) = @_;
    my $self = $webdriver_instance;
    return _real_sleep($seconds) if $ENV{SGN_TEST_PLAIN_SLEEP} || !$self || $seconds <= 0 || $seconds != int($seconds);
    return _real_sleep($seconds) if eval { $self->driver->get_alert_text(); 1 };
    # Longer sleeps wait for server-side jobs that the page cannot observe.
    return _real_sleep($seconds) if $seconds > 60;
    my $started = Time::HiRes::time();
    my ($quiet_since, $document, $leaving);
    $self->_wait($seconds, sub {
        if ($leaving) {
            my $token = eval { $self->driver->execute_script(
                'return performance.timeOrigin || performance.timing.navigationStart;'
            ) };
            return 0 if !$token || $token == $leaving;
            $leaving = undef;
        }
        my $idle = eval { $self->_page_script(q{
            var token = performance.timeOrigin || performance.timing.navigationStart;
            if (window.__sgnTestWait.leaving) { return -token; }
            function rendered(e) {
                return e.getClientRects().length && getComputedStyle(e).visibility !== 'hidden';
            }
            if (document.readyState !== 'complete' || (window.jQuery && (jQuery.active || (jQuery.timers && jQuery.timers.length)))) { return false; }
            var working = document.getElementById('working_modal');
            if (working && rendered(working)) { return false; }
            var modals = document.querySelectorAll('.modal');
            for (var i = 0; i < modals.length; i++) {
                var m = modals[i], dialog = m.querySelector('.modal-dialog');
                if (!rendered(m)) { continue; }
                var transform = dialog && getComputedStyle(dialog).transform;
                if (!m.classList.contains('in') || (transform && transform !== 'none' &&
                    transform !== 'matrix(1, 0, 0, 1, 0, 0)')) { return false; }
            }
            return document.querySelector('.modal-backdrop:not(.in)') ? 0 :
                token;
        }) };
        if ($idle && $idle < 0) {
            $leaving = -$idle;
            $quiet_since = undef;
            return 0;
        }
        my $now = Time::HiRes::time();
        $quiet_since = undef if !$idle || !defined $document || $document != $idle;
        $quiet_since = $now if $idle && !defined $quiet_since;
        $document = $idle;
        return defined $quiet_since && $now - $quiet_since >= ($seconds <= 1 ? 0.5 : 0.75);
    }, \$leaving);
    return int(Time::HiRes::time() - $started);
}

sub BUILD {
    my $self = shift;

    $webdriver_instance = $self;

    my $download_dir = $self->download_dir();

    chown 1200, 1250, $download_dir;
    chmod 0777, $download_dir;
    
    my $profile = Selenium::Firefox::Profile->new;
    $profile->set_preference( 'browser.download.folderList', 2 ); # Use custom download folder
    $profile->set_preference( 'browser.download.dir', $download_dir );
    $profile->set_preference( 'browser.download.manager.showWhenStarting', 0 );
    $profile->set_preference( 'browser.helperApps.neverAsk.saveToDisk', 'application/octet-stream,text/csv,application/zip,text/plain' );
    
    my $driver = Selenium::Remote::Driver->new(firefox_profile => $profile, base_url => $ENV{SGN_TEST_SERVER}, remote_server_addr => $ENV{SGN_REMOTE_SERVER_ADDR} || 'localhost',
        extra_capabilities => { unhandledPromptBehavior => 'ignore' });
    

    $self->driver($driver);
}

sub login_as { 
    my $self = shift;
    my $role = shift;
    $self->login( $self->user_data()->{$role}->{username},
		  $self->user_data()->{$role}->{password},
	);
}

sub login { 
    my $self = shift;
    my $username = shift;
    my $password = shift;
    
    $self->get("/user/login");
    sleep(2);
    my $d = $self->driver();
    my $username_field = $d->find_element("username", "id");
    $username_field->click();
    $username_field->send_keys($username);
    my $password_field = $d->find_element("password", "name");
    $password_field->click();
    $password_field->send_keys($password);
    my $login_button = $d->find_element("submit_password", "id");
    $login_button->click();
}

sub logout { 
    my $self = shift;
    return $self->get("/user/logout");
}

sub logout_ok { 
    my $self = shift;
    my $test_name = shift || "logout test";
    ok($self->logout(), $test_name);
}

sub while_logged_in_as {
    my ($self, $user_type, $sub) = @_;

    $self->login_as($user_type);
    try {
            $sub->( );
    } catch {
	die $_;
    } finally {
	$self->logout;
    };
}


sub base_url { 
    my $self = shift;
    return $self->host();
}
    
sub get { 
    my $self = shift;
    my $url = shift;
    return $self->driver->get($url);
}

sub get_ok { 
    my $self = shift;
    my $url = shift;
    my $test_name = shift || "get $url test";
    ok($self->get($url), $test_name);
}
    
use constant PAGE_HOOK => <<'JS';
(function () {
    var state = window.__sgnTestWait = {leaving: false};
    window.addEventListener('beforeunload', function () { state.leaving = true; });
})();
JS

sub _page_script {
    my ($self, $script, @args) = @_;
    unless ($ENV{SGN_TEST_PLAIN_SLEEP}) {
        $self->driver->execute_script(q{
            if (window.__sgnTestWait) { return; }
            // Install callbacks in the page realm, outside Marionette's sandbox.
            var s = document.createElement('script');
            s.textContent = arguments[0];
            (document.head || document.documentElement).appendChild(s); s.remove();
        }, PAGE_HOOK);
    }
    return $self->driver->execute_script($script, @args);
}

sub _wait {
    my ($self, $seconds, $condition, $leaving) = @_;
    my $deadline = Time::HiRes::time() + $seconds;
    while (Time::HiRes::time() < $deadline) {
        my $alert = eval { $self->driver->get_alert_text(); 1 };
        return 1 if $alert && !($leaving && $$leaving);
        return 1 if !$alert && eval { $condition->() } && Time::HiRes::time() < $deadline;
        my $remaining = $deadline - Time::HiRes::time();
        last if $remaining <= 0;
        Time::HiRes::sleep($remaining < 0.2 ? $remaining : 0.2);
    }
    return 0;
}

sub find_element { 
    my $self = shift;
    my $element = $self->driver->find_element(@_);
    my $ready = $self->_wait(60, sub {
        return !eval { $self->driver->execute_script(q{
            if (window.__sgnTestCoverTimedOut) { return false; }
            var e = arguments[0];
            if (e && e.tagName.toLowerCase() === 'option') { e = e.closest('select'); }
            if (!e || !e.isConnected || !e.getClientRects().length ||
                getComputedStyle(e).visibility !== 'visible') { return false; }
            var r = e.getBoundingClientRect(), x = r.left + r.width / 2, y = r.top + r.height / 2;
            if (x < 0 || y < 0 || x >= window.innerWidth || y >= window.innerHeight) {
                e.scrollIntoView({block: 'center', inline: 'center'});
                r = e.getBoundingClientRect(); x = r.left + r.width / 2; y = r.top + r.height / 2;
            }
            var top = document.elementFromPoint(x, y);
            if (!top) { return false; }
            if (top.closest('#working_modal, .modal-backdrop')) { return true; }
            var modal = top.closest('.modal');
            return !!modal && !modal.contains(e);
        }, $element) };
    });
    unless ($ready) {
        note("Timed out waiting for uncovered element $_[0]");
        eval { $self->driver->execute_script(
            'arguments[0].ownerDocument.defaultView.__sgnTestCoverTimedOut = true;', $element
        ) } unless eval { $self->driver->get_alert_text(); 1 };
    }
    return $element;
}

sub find_element_ok { 
    my $self = shift;
    my $name = shift;
    my $method = shift;
    my $test_name = shift || print STDERR "You can provide a test name parameter for find_element_ok\n";
    ok(my $element = $self->find_element($name, $method), $test_name);
    return $element;
}

sub select_datatable_tab {
    my ($self, $tab_id) = @_;
    $tab_id =~ s/^#//;

    my $selector = qq{//a[\@data-target="#$tab_id"]};
    my $tab = $self->find_element_ok(
        $selector,
        'xpath',
        "select DataTable tab $tab_id",
    );
    $tab->click();
    sleep(5);

    return $tab;
}

sub accept_alert { 
    my $self = shift;
    $self->driver->accept_alert();
}

sub accept_alert_ok { 
    my $self = shift;
    my $test_name = shift;
    ok($self->accept_alert(), $test_name);
}

sub download_linked_file {
    my $self = shift;
    my $link_id = shift;

    my $download_link = $self->find_element($link_id, "id");
    
    my $href = $download_link->get_attribute("href");
    
    my $cookies = $self->driver()->get_all_cookies();
    
    my $token = "";
    foreach my $cookie (@$cookies) { 
	if ($cookie->{name} eq "sgn_session_id") { 
	    $token = $cookie->{value};
	}
    }

    system("wget --header \"Cookie: sgn_session_id=$token\" --directory-prefix=/tmp $href");


}


sub wait_for_working_dialog {
    my $self = shift;
    my $max = shift || 300;

    sleep(3);

    my $is_hidden = 0;
    my $count = 0;
    print STDERR "... waiting for working dialog ...\n";
    while ( !$is_hidden && $count < $max ) {
        my $wd = $self->driver->find_element("working_modal", "id");
        $is_hidden = $wd->is_hidden();
        $count++;
        sleep(1);
    }
    print STDERR "... working dialog dismissed ...\n";
}

1;
   
    
