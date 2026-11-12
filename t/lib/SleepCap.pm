package SleepCap;

# Trial only, not for upstream: cap every sleep() called from a selenium
# test or t/lib at $ENV{SLEEP_CAP} seconds (default 2), and log per test
# file to /tmp/sleep.log: file, calls, seconds asked, seconds slept.
# Loaded with PERL5OPT="-I.../t/lib -MSleepCap".

use strict;
use warnings;

my ($calls, $asked, $slept) = (0, 0, 0);

BEGIN {
    *CORE::GLOBAL::sleep = sub (;$) {
        my $n = @_ ? $_[0] : 0;
        my $file = (caller)[1] // '';
        if ($file =~ m{t/selenium2/|t/lib/}) {
            my $cap = $ENV{SLEEP_CAP} // 2;
            $calls++;
            $asked += $n;
            $n = $cap if $n > $cap;
            my $got = CORE::sleep($n);
            $slept += $got;
            return $got;
        }
        return CORE::sleep($n);
    };
}

END {
    if ($0 =~ /\.t\z/ && open(my $fh, '>>', '/tmp/sleep.log')) {
        printf {$fh} "%s\t%d\t%d\t%d\n", $0, $calls, $asked, $slept;
        close $fh;
    }
}

1;
