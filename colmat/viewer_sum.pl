use strict;
use warnings;

use statlib;
use lm_env;

use List::Util qw(max min sum);
use JSON::XS;

use Data::Dumper;

sub report {
    my ($key, $r_le) = @_;

    my ($ts_ini, $ts_end, $ts_name, $count, $max, $mean, $min, $std, $ret) = summarize_list_ev($r_le);    

    if (defined $ret) {
        print "$key\t$ts_ini\t$ts_end\t$ts_name\t$count\t$max\t$mean\t$min\t$std\t$ret\n";
    }

}

## MAIN - Loop ##

while (<STDIN>) {
    my ($key, $type, $msg) = split(/\t\s*/);

    my $r_le = decode_json($msg);

    &report($key, $r_le);

}
