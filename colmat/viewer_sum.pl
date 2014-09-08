# Show LEs in summarized format
#
# Each line contain
# 
# - ts_ini
# - ts_end
# - ts_name: time elapsed to resolve name
# - count of messages
# - max 'req_ts' across all messags
# - mean 'req_ts' across all messages
# - min 'req_ts' across all messages
# - standard deviation from all 'req_ts' messages
# - max 'last_ts' across all messags
# - mean 'last_ts' across all messages
# - min 'last_ts' across all messages
# - standard deviation from all 'last_ts' messages
# - list of token containing the sequence of events
#

use strict;
use warnings;

use statlib;
use lm_env;

use List::Util qw(max min sum);
use JSON::XS;

use Data::Dumper;

my $separator = ",";
my @fields = qw(ts_ini ts_end ts_name count req_max req_mean req_min req_std last_mean last_max last_min last_std token);

sub report {
    my ($key, $r_le) = @_;

	my $ret = summarize_list_ev2($r_le);

    if (defined $ret) {
		print "$key$separator";
		print join $separator, map { "$ret->{$_}" } @fields; print "\n";
        #print "$key\t$ts_ini\t$ts_end\t$ts_name\t$count\t$max\t$mean\t$min\t$std\t$ret\n";
    }

}

## MAIN - Loop ##
print "cid$separator"; print join $separator, map { "$_" } @fields; print "\n";

while (<STDIN>) {
    my ($key, $type, $msg) = split(/\t\s*/);

    my $r_le = decode_json($msg);

    &report($key, $r_le);

}
