
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

* find_element() - forwards to the driver find_element() function

* find_element_ok() - wraps the find_element in an ok() test.

* select_datatable_tab() - selects a DataTable tab by its target pane ID, then waits for its pane and AJAX.

* wait_until($code, $timeout = 30, $interval = 0.2) - polls a condition, treating exceptions as false; returns its true value or false with one Test::More note on timeout.

* wait_for_element($locator, $how = 'xpath', $timeout = 30) - returns an element once it is displayed, or false on timeout.

* wait_for_ajax($timeout = 60) - waits for a complete document, no active jQuery requests, and no visible working modal for 0.5 continuous seconds. Fetch results require a separate condition.

* wait_for_working_dialog($max = 300) - watches up to three seconds for a visible working modal or active jQuery request; if seen, waits up to $max seconds for the page to be idle for 0.5 continuous seconds, as in wait_for_ajax. Returns true if neither appears.

Wait helpers do not add tests. A timeout produces one Test::More note on stdout and returns false. Internally, wait_until also accepts a fourth argument describing the awaited condition.

For all other driver functions, use the driver() accessor, for example: $swd->driver->get_window_size().

For downloads, a /download dir needs to be mapped in the breedbase_web docker and in the selenium docker to the same host dir. The download dir can be obtained from this object using $d->download_dir(); .


=head1 AUTHOR

Lukas Mueller <lam87@cornell.edu>

=cut

 

package SGN::Test::WWW::WebDriver;

use strict;
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
    $self->wait_for_element("username", "id");
    my $d = $self->driver();
    my $username_field = $d->find_element("username", "id");
    $username_field->click();
    $username_field->send_keys($username);
    my $password_field = $d->find_element("password", "name");
    $password_field->click();
    $password_field->send_keys($password);
    my $login_button = $d->find_element("submit_password", "id");
    my $login_url = $d->get_current_url();
    $login_button->click();
    # The successful login callback redirects away from /user/login.
    $self->wait_until(sub {
        return $d->get_current_url() ne $login_url;
    }, 60, 0.2, 'successful login redirect');
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
    return $self->driver->get($url);
}

sub get_ok { 
    my $self = shift;
    my $url = shift;
    my $test_name = shift || "get $url test";
    ok($self->get($url), $test_name);
}
    
sub find_element { 
    my $self = shift;
    return $self->driver->find_element(@_);
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
    $self->wait_for_element($tab_id, "id");
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


sub wait_until {
    my ($self, $code, $timeout, $interval, $description) = @_;
    $timeout = 30 unless defined $timeout;
    $interval = 0.2 unless defined $interval;
    my (undef, $file, $line) = caller;
    $description ||= "condition at $file:$line";
    my $deadline = time() + $timeout;

    while (1) {
        my $value = eval { $code->() };
        return $value if $value;
        my $remaining = $deadline - time();
        last if $remaining <= 0;
        sleep($remaining < $interval ? $remaining : $interval);
    }
    note("Timed out waiting for $description");
    return 0;
}

sub wait_for_element {
    my ($self, $locator, $how, $timeout) = @_;
    $how = 'xpath' unless defined $how;
    $timeout = 30 unless defined $timeout;
    return $self->wait_until(sub {
        my $element = $self->find_element($locator, $how);
        return $element->is_displayed() ? $element : 0;
    }, $timeout, 0.2, "displayed element $how=$locator");
}

sub wait_for_ajax {
    my ($self, $timeout) = @_;
    $timeout = 60 unless defined $timeout;
    my $idle_since;
    return $self->wait_until(sub {
        my $idle = eval { $self->driver->execute_script(q{
            return document.readyState === 'complete' &&
                (typeof jQuery === 'undefined' || jQuery.active === 0) &&
                !Array.from(document.querySelectorAll('#working_modal')).some(function (modal) {
                    return modal.getClientRects().length > 0 &&
                        window.getComputedStyle(modal).visibility !== 'hidden';
                });
        }) };
        if (!$idle) {
            $idle_since = undef;
            return 0;
        }
        $idle_since = time() unless defined $idle_since;
        return time() - $idle_since >= 0.5;
    }, $timeout, 0.2, 'page idle for 0.5 seconds');
}

sub wait_for_working_dialog {
    my ($self, $max) = @_;
    $max = 300 unless defined $max;
    my $started = time();
    my $working = sub {
        return $self->driver->execute_script(q{
            var modal = document.getElementById('working_modal');
            return (typeof jQuery !== 'undefined' && jQuery.active > 0) ||
                (!!modal && modal.getClientRects().length > 0 &&
                    window.getComputedStyle(modal).visibility !== 'hidden');
        });
    };

    # Absence during this observation window is normal, not a timeout.
    my $shown = 0;
    while (1) {
        $shown = eval { $working->() };
        last if $shown;
        my $remaining = $started + 3 - time();
        return 1 if $remaining <= 0;
        sleep($remaining < 0.2 ? $remaining : 0.2);
    }

    return $self->wait_for_ajax($max);
}

1;
