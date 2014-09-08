# Executes ordering on a group of SIP events 
#
# store all SIP events with same reduce key (Cid + Coc) n a list
# order the events
# calculate measures for 'req_ts' and 'last_ts' 
# 

use strict;
use warnings;

use ordererlib;
use statlib;
use lm_env;

use Data::Dumper;
use JSON::XS;

sub proc_list {
    my($key, $initiator_count, $ref_messages) = @_;

    if (!$key) {
        return;
    }

    my $ref_msg_ord = &order_sipn($ref_messages);  # ordering
    &time_diff_com($ref_msg_ord);                  # calculate 'req_ts' and 'last_ts' 

    print $key. "\t" . encode_json ($ref_msg_ord) . "\t" . $initiator_count . "\n";
}


#### MAIN LOOP ####

my @messages = ();
my $prev_key;
my $initiator_count = 0;

while (<STDIN>) {
    my ($key, $initiator, $msg) = split(/\t\s*/);

    if (!$prev_key || $prev_key ne $key) {
        # process existing elements in the list
        &proc_list($prev_key, $initiator_count, \@messages);
        
        # clean up
        $initiator_count = 0;
        @messages = ();
        
        $prev_key = $key;
    }

    push(@messages, decode_json($msg));
    $initiator_count += $initiator;

}

&proc_list($prev_key, $initiator_count, \@messages);
