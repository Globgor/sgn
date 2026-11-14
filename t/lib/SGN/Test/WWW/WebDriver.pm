
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

* find_element() - waits for a quiet page and blocking dialogs to clear; missing elements still throw and hidden elements return immediately.

* find_element_ok() - retries missing elements for up to 300 seconds, then wraps find_element in the original ok() test.

* select_datatable_tab() - selects a DataTable tab by its target pane ID.

* wait_until($code, $timeout = 120, $interval = 0.2) - polls without adding assertions; notes timeout and preserves open alerts.

* wait_for_ajax($timeout = 300) - waits for document complete, idle jQuery and hidden working modal for 0.5 seconds after load or AJAX activity.

* is_visible($element) - checks page visibility, including hidden parents, independently of viewport bounds.

* wait_for_reload($action) - runs an action, waits for a new document, then waits for page quiet.

* wait_for_working_dialog($max = 300) - waits for page quiet after a working operation.

For all other driver functions, use the driver() accessor, for example: $swd->driver->get_window_size().

For downloads, a /download dir needs to be mapped in the breedbase_web docker and in the selenium docker to the same host dir. The download dir can be obtained from this object using $d->download_dir(); .


=head1 AUTHOR

Lukas Mueller <lam87@cornell.edu>

=cut

 

package SGN::Test::WWW::WebDriver;

use Moose;

use Try::Tiny;
use Time::HiRes qw(time sleep);
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
    
    my $driver = Selenium::Remote::Driver->new(firefox_profile => $profile, base_url => $ENV{SGN_TEST_SERVER}, remote_server_addr => $ENV{SGN_REMOTE_SERVER_ADDR} || 'localhost');
    

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
    my $d = $self->driver();
    my $username_field = $self->find_element("username", "id");
    $username_field->click();
    $username_field->send_keys($username);
    my $password_field = $d->find_element("password", "name");
    $password_field->click();
    $password_field->send_keys($password);
    my $login_button = $d->find_element("submit_password", "id");
    my $url = $d->get_current_url();
    $login_button->click();
    $self->wait_until(sub { $d->get_current_url() ne $url }) or die "Login did not redirect\n";
    $self->wait_for_ajax();
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
    my $result = $self->driver->get($url);
    $self->wait_for_ajax() or die "Page did not settle after get $url\n";
    return $result;
}

sub get_ok { 
    my $self = shift;
    my $url = shift;
    my $test_name = shift || "get $url test";
    ok($self->get($url), $test_name);
}
    
sub find_element { 
    my $self = shift;
    my @locator = @_;
    die "Cannot find an element while an alert is open\n" if $self->_alert_is_open();
    my $element = $self->driver->find_element(@locator);
    $self->wait_for_ajax() or die "Page did not settle\n";
    my $ready = $self->wait_until(sub {
        # Prefer the visible copy when workflow messages share a locator.
        my @elements = @{$self->driver->find_elements(@locator)};
        $element = $elements[0];
        foreach my $candidate (@elements) {
            if ($self->is_visible($candidate)) {
                $element = $candidate;
                last;
            }
        }
        return $element && $self->_element_ready($element);
    });
    die "Element not ready: $locator[0]\n" unless $ready && !$self->_alert_is_open();
    return $element;
}

sub find_element_ok { 
    my $self = shift;
    my $name = shift;
    my $method = shift;
    my $test_name = shift || print STDERR "You can provide a test name parameter for find_element_ok\n";
    my $element = $self->wait_until(sub { $self->find_element($name, $method) }, 300);
    die "Cannot find element $method=$name\n" unless ref $element;
    ok($element, $test_name);
    return $element;
}

sub _alert_is_open {
    my ($self) = @_;
    return eval { $self->driver->get_alert_text(); 1 } || 0;
}

sub wait_until {
    my ($self, $code, $timeout, $interval) = @_;
    $timeout = 120 unless defined $timeout;
    $interval = 0.2 unless defined $interval;
    my (undef, $file, $line) = caller;
    my $deadline = time() + $timeout;
    $deadline = $self->{_wait_deadline} if defined $self->{_wait_deadline} && $self->{_wait_deadline} < $deadline;
    local $self->{_wait_deadline} = $deadline;
    while (1) {
        return 1 if $self->_alert_is_open();
        my $value = eval { $code->() };
        return $value if $value;
        my $remaining = $deadline - time();
        last if $remaining <= 0;
        sleep($remaining < $interval ? $remaining : $interval);
    }
    note("Timed out waiting for condition at $file:$line");
    return 0;
}

sub wait_for_ajax {
    my ($self, $timeout) = @_;
    $timeout = 300 unless defined $timeout;
    my $started = $self->wait_until(sub {
        $self->driver->execute_script(q{
            if (!window.sgnTestIdle) {
                window.sgnTestIdle = {since: Date.now()};
                var reset = function () { window.sgnTestIdle.since = Date.now(); };
                if (window.jQuery) { jQuery(document).ajaxSend(reset).ajaxComplete(reset); }
            }
            var working = Array.from(document.querySelectorAll('#working_modal')).some(function (e) {
                return e.getClientRects().length && getComputedStyle(e).visibility !== 'hidden';
            });
            if (document.readyState !== 'complete' || (window.jQuery && jQuery.active) || working) {
                window.sgnTestIdle.since = Date.now();
                return false;
            }
            return Date.now() - window.sgnTestIdle.since >= 500 ? performance.timeOrigin : 0;
        });
    }, $timeout);
    $self->{_page_started} = $started if $started && $started != 1;
    return $started;
}

sub is_visible {
    my ($self, $element) = @_;
    return 0 if $self->_alert_is_open();
    return $self->driver->execute_script(q{
        var e = arguments[0];
        if (e.tagName === 'OPTION') { e = e.closest('select'); }
        return !!e && e.getClientRects().length > 0 &&
            getComputedStyle(e).visibility !== 'hidden';
    }, $element);
}

sub _element_ready {
    my ($self, $element) = @_;
    return 0 if $self->_alert_is_open();
    return $self->driver->execute_script(q{
        var e = arguments[0];
        if (e.tagName === 'OPTION' || e.type === 'file' || e.type === 'hidden' ||
            !e.getClientRects().length || getComputedStyle(e).visibility === 'hidden') {
            return true;
        }
        var modal = e.closest('.modal');
        if (modal) {
            var dialog = modal.querySelector('.modal-dialog');
            var transform = dialog ? getComputedStyle(dialog).transform : 'none';
            if (!modal.classList.contains('in') ||
                (transform !== 'none' && transform !== 'matrix(1, 0, 0, 1, 0, 0)')) {
                return false;
            }
        }
        // Scroll nested containers too, even when the centre is inside the viewport.
        e.scrollIntoView({block: 'center', inline: 'center'});
        var r = e.getBoundingClientRect();
        var top = document.elementFromPoint(r.left + r.width / 2, r.top + r.height / 2);
        if (!top) { return true; }
        if (top.closest('#working_modal, .modal-backdrop')) { return false; }
        var blocking_modal = top.closest('.modal');
        return !blocking_modal || blocking_modal.contains(e);
    }, $element);
}

sub wait_for_reload {
    my ($self, $action) = @_;
    my $started = $self->_alert_is_open() ? $self->{_page_started} :
        $self->driver->execute_script('return performance.timeOrigin;');
    die "No document marker before reload\n" unless defined $started;
    $action->();
    my $reloaded = $self->wait_until(sub {
        $self->driver->execute_script('return performance.timeOrigin;') != $started;
    });
    die "Page did not reload\n" unless $reloaded && !$self->_alert_is_open();
    return $self->wait_for_ajax();
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
    $self->wait_for_ajax();

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
    return $self->wait_for_ajax($max);
}

1;
   
    
