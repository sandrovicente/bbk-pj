# obtain and store a list of <keys> <sip messages> separated by tabs
# accumulate all sip messages
# parse them and return a SIP-ORDERED LIST OF EVENTS for the provided <key>

use strict;
use warnings;

use Data::Dumper;

use Time::Local;

sub find_calc_tsms {
    my ($str) = @_;

    my @t = ($str =~ m!(\d{4})\-(\d{2})\-(\d{2})\ (\d{2}):(\d{2}):(\d{2})!);
    --$t[1]; # months from 0-11
    
    my $ts = timegm @t[5,4,3,2,1,0];
    
    return ($ts, $&);
}


## reduce function

sub proc_list {
    my($key, $ref_messages) = @_;

    if (!defined $key) {
        return;
    }

    print "$key";
    if (scalar @{$ref_messages} != 2) {
        print STDERR "*** ERR: message inconsistent";
        print Dumper($ref_messages);
        
        return;
    }

    my @ord_messages = sort { if ($a->[3] eq 'BEGIN') { return -1; } else { return 1; } } @{$ref_messages};
    
    my ($ts1, $ts1_s) = find_calc_tsms($ord_messages[0]->[1] . " " . $ord_messages[0]->[0]); 
    my ($ts2, $ts2_s) = find_calc_tsms($ord_messages[1]->[1] . " " . $ord_messages[1]->[0]); 
    my $ts_diff = $ts2 - $ts1;
    
    print "\t$ts1\t$ts2\t$ts_diff";
    print "\t" . $ord_messages[0]->[2];
    print "\t" . $ord_messages[1]->[2];
    print "\t" . $ord_messages[1]->[3];

    #print $key. "\t" . join "\t", map { map { "$_" } @{$_} } @{$ref_messages};
    print "\n";
}


#### MAIN LOOP ####

my @messages = ();
my $prev_key;

while (<STDIN>) {
    
    my ($key, @remainder) = split(/[\t\s]+/);

    if (!$prev_key || $prev_key ne $key) {
        # process existing elements in the list
        &proc_list($prev_key, \@messages);
        
        # clean up
        @messages = ();
        
        $prev_key = $key;
    }

    push(@messages, \@remainder);
}

&proc_list($prev_key, \@messages);
