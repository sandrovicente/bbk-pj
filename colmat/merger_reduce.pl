# Receives records in this structure
#
#  1. Key= <correlation_id>
#  2. <component_id>
#  3. list of component's events ordered
#
#  Reduces on the key merging list events across all component classes 

use strict;
use warnings;

use ordererlib;
use lm_env;

use JSON::XS;

use Data::Dumper;


# Reduce function
#
# Obtain ordered LEs from all component classes
# Find which component class initiated the events
# Merge and order LEs starting by the class component that initiated the events

sub proc_list {
    my($key, $init_comp, $ref_messages) = @_;

    if (!$key) {
        return;
    }

    # initiator component hasn't been found (?!) Maybe partial log
    if (!$init_comp) {
    
        print STDERR "*** Broken ***\n" . Dumper($ref_messages);
        return;
    }

    my $order_key;
    map { if ($COMP_ORDER{$_}[0] eq $init_comp) {$order_key = $_} } keys %COMP_ORDER;

    my $r_merged_sip_list = [];
    foreach my $comp(@{$COMP_ORDER{$order_key}}) {
        if ($ref_messages->{$comp}) {
            $r_merged_sip_list = &order_merge_sipn($r_merged_sip_list, $ref_messages->{$comp});
        }
    }

    print "$key\ts\t" . encode_json($r_merged_sip_list) . "\n";
}


### MAIN LOOP ###

my %messages = ();
my $prev_key;
my $init_comp;

while (<STDIN>) {
    my ($key, $comp, $msg, $initiator) = split(/\t\s*/);

    if (!$prev_key || $prev_key ne $key) {
        # process existing elements in the list
        &proc_list($prev_key, $init_comp, \%messages);
        
        # clean up
        %messages = ();
        undef $init_comp;
        
        $prev_key = $key;
    }

    if ($initiator =~ /1/) {
        $init_comp = $comp;
    }

    $messages{$comp} = decode_json $msg;

}

&proc_list($prev_key, $init_comp, \%messages);

