# Groups all records, for both SIP events and name resolution events
# Use identfiers found in both record types to find the closes match
# and associates the Cid, from matching SIP event, to name resolution event

use strict;
use warnings;

use Data::Dumper;

use Time::Local;
use resolvlib;


# Perform the Reduce function
#
# Receives
#  reduce key (the origin URI)
#  ref_s_msg: list of references to SIP records with the 'From URI' equal to the key. Each record contain:
#     position 0: component type
#     position 1: Cid
#     position 2: initial timestamp in ms
#     position 3: serialized SIP event
#    
#  ref_t_msg: list of references to name resolution records with the 'Origin URI' equal to the key. Each record contain:
#     position 0: timestamp ini
#     position 1: timestamp end
#     position 2: name resolution duration
#     position 3: return argument
#     position 4: name resolution status
#
# 

sub proc_key {
    my($key, $ref_s_msg, $ref_t_msg) = @_;

    if (!defined $key) {
        return;
    }

    my %call_id_map = ();

    #mapify sipmessages per callid
    # the first ts in sip record should be the closest time to the name resolution. That happens upon invite 
    foreach my $item(@{$ref_s_msg}) {
        if ($call_id_map{$item->[1]}) {
            push($call_id_map{$item->[1]}, $item);
        } 
        else {
            $call_id_map{$item->[1]} = [$item];
        }
    }

    # now $call_id_map should contain a hash
    # key is cid
    # value is a list of records with same cid

    # should pick the item if lowest timestamp in this list
    foreach my $item(keys %call_id_map) {
        my @r_first_event = sort { $a->[2] <=> $b->[2] } @{$call_id_map{$item}};
        $call_id_map{$item} = $r_first_event[0];
    }

    #mapfy name resolution messages creating name resolution id => name resolution record
    my $count = 0;
    my %name_map = map { "t".$count++ => $_ } @{$ref_t_msg};


    # find the closest match between SIP events and name resolution events
    # *** threshold is hardcoded!! 2

    my $result = &sel_cid_name_prox(2, \%name_map, \%call_id_map);

    foreach my $name_id(keys %{$result}) {
        # there must be only one closest match
        if (scalar (keys $result->{$name_id}) == 1) {
            my @cids = map {$_} keys $result->{$name_id};
            print "$cids[0]\t$key\t";
            print join "\t", map {$_} @{$name_map{$name_id}};
            print "\n";
        }
        else {
            print STDERR "*** WARN Unable to resolve reference for name record: '$key' [";
            print STDERR join ", ", map {$_} @{$name_map{$name_id}};
            print STDERR "], " . (keys $result->{$name_id}) . " eligible CIDs found\n"
        }
    }
}

## MAIN LOOP 

my @s_messages = ();
my @n_messages = ();
my $prev_key;

while (<STDIN>) {
    
    my ($key, $type, @remainder) = split(/[\t\s]+/);

    if (!$prev_key || $prev_key ne $key) {
        # process existing elements in the list
        &proc_key($prev_key, \@s_messages, \@n_messages);
        
        # clean up
        @s_messages = ();
        @n_messages = ();
        
        $prev_key = $key;
    }

    if ($type eq 'n') {
        push(@n_messages, \@remainder);
    } elsif ($type eq 's') {
        push(@s_messages, \@remainder);
    }
}

&proc_key($prev_key, \@s_messages, \@n_messages);
