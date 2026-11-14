
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

* select_datatable_tab() - selects a DataTable tab by its target pane ID.

For all other driver functions, use the driver() accessor, for example: $swd->driver->get_window_size().

For downloads, a /download dir needs to be mapped in the breedbase_web docker and in the selenium docker to the same host dir. The download dir can be obtained from this object using $d->download_dir(); .


=head1 AUTHOR

Lukas Mueller <lam87@cornell.edu>

=cut

 

package SGN::Test::WWW::WebDriver;

use Moose;

use Try::Tiny;
use Time::HiRes ();
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
    no strict 'refs';
    # Replace only unqualified sleeps in the importing test package.
    *{"${caller}::sleep"} = \&_settled_sleep;
}

sub _settled_sleep (;$) {
    return CORE::sleep() unless @_;
    my ($seconds) = @_;
    my $self = $webdriver_instance;
    return CORE::sleep($seconds) unless $self && $seconds > 0;
    my (undef, $file, $line) = caller;
    my $started = Time::HiRes::time();
    my $deadline = $started + $seconds;
    my ($quiet_since, $polled);
    while (Time::HiRes::time() < $deadline) {
        if (eval { $self->driver->get_alert_text(); 1 }) {
            return CORE::sleep($seconds) unless $polled;
            return int(Time::HiRes::time() - $started);
        }
        last if Time::HiRes::time() >= $deadline;
        $polled = 1;
        my $settled = eval { $self->driver->execute_script(q{
            function rendered(e) {
                return e.getClientRects().length && getComputedStyle(e).visibility !== 'hidden';
            }
            if (document.readyState !== 'complete' || (window.jQuery && jQuery.active)) { return false; }
            var working = document.getElementById('working_modal');
            if (working && rendered(working)) { return false; }
            if (document.querySelector('.modal-backdrop:not(.in)')) { return false; }
            var modals = document.querySelectorAll('.modal');
            for (var i = 0; i < modals.length; i++) {
                var modal = modals[i];
                if (!rendered(modal)) { continue; }
                if (!modal.classList.contains('in')) { return false; }
                var dialog = modal.querySelector('.modal-dialog');
                var transform = dialog && getComputedStyle(dialog).transform;
                if (transform && transform !== 'none' && transform !== 'matrix(1, 0, 0, 1, 0, 0)') { return false; }
            }
            return true;
        }) };
        my $now = Time::HiRes::time();
        if ($settled) {
            $quiet_since = $now unless defined $quiet_since;
            return int($now - $started) if $now - $quiet_since >= 0.5 && $now < $deadline;
        }
        else {
            $quiet_since = undef;
        }
        my $remaining = $deadline - $now;
        last if $remaining <= 0;
        Time::HiRes::sleep($remaining < 0.2 ? $remaining : 0.2);
    }
    note("sleep $seconds not shortened at $file:$line");
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
    
    # Trial switch between W3C and legacy Selenium prompt capability names.
    my $prompt_capability = $ENV{SGN_TEST_LEGACY_ALERTS}
        ? 'unexpectedAlertBehaviour' : 'unhandledPromptBehavior';
    my $driver = Selenium::Remote::Driver->new(
        firefox_profile => $profile, base_url => $ENV{SGN_TEST_SERVER},
        remote_server_addr => $ENV{SGN_REMOTE_SERVER_ADDR} || 'localhost',
        extra_capabilities => { $prompt_capability => 'ignore' },
    );
    note("Requested $prompt_capability=ignore");
    

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
        my $wd = $self->find_element("working_modal", "id");
        $is_hidden = $wd->is_hidden();
        $count++;
        sleep(1);
    }
    print STDERR "... working dialog dismissed ...\n";
}

1;
   
    
