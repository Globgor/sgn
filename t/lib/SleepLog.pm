package SleepLog;

# Trial only, not for upstream: count the seconds each test file spends in
# sleep(), called from the test file itself or from t/lib (WebDriver.pm).
# Loaded with PERL5OPT="-I.../t/lib -MSleepLog"; writes one line per test
# file to /tmp/sleep.log: file, calls, seconds asked, seconds slept.

use strict;
use warnings;

my ($calls, $asked, $slept) = (0, 0, 0);

BEGIN {
    *CORE::GLOBAL::sleep = sub (;$) {
        my $n = @_ ? $_[0] : 0;
        my $got = CORE::sleep($n);
        my $file = (caller)[1] // '';
        if ($file =~ m{t/selenium2/|t/unit_fixture/|t/unit_mech/|t/lib/}) {
            $calls++;
            $asked += $n;
            $slept += $got;
        }
        return $got;
    };
}

END {
    if ($0 =~ /\.t\z/ && open(my $fh, '>>', '/tmp/sleep.log')) {
        printf {$fh} "%s\t%d\t%d\t%d\n", $0, $calls, $asked, $slept;
        close $fh;
    }
}

1;
