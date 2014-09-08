# Bind name resolution event to SIP LE across all components
#
# Executed after SIP event X name resolution matching (MR-4) 
#

use strict;
use warnings;

use Data::Dumper;
use JSON::XS;

# Reduce function
#
# receives 
#  reference to a serialized LE
#  reference to a name resolution record
# 
#  returns a serialized LE containing the name resolution record
#
sub proc_key {
    my($key, $ref_s_msg, $ref_t_msg) = @_;

    my $messages = decode_json $ref_s_msg->[0];

    if (@{$ref_t_msg}) {
        # build a name resolution entry for the LE
        my $pos;
        my $name = {
            type => 'n',
            callid => $key,
            from => $ref_t_msg->[$pos = 0],
            ts_ini => $ref_t_msg->[++$pos],
            ts_end => $ref_t_msg->[++$pos],
            ts_diff => $ref_t_msg->[++$pos],
            ret => $ref_t_msg->[++$pos],
            result => $ref_t_msg->[++$pos],
        };
        

        push(@{$messages}, $name);

    }
    my $encoded = encode_json $messages;
    print $key . "\tf\t" . $encoded . "\n";

}

# Check if the Reduce is applied to a valid key. 
# Noop if invalid
#
sub proc_key_entry {
    my($key, $ref_s_msg, $ref_t_msg) = @_;

    if (defined $key && @{$ref_s_msg}) {
        &proc_key(@_);
    } 
}

############
## main loop 
############

## each cid should have up to 2 entries, one for name and another sip. 
## sip is mandatory

my @s_messages = ();
my @n_messages = ();
my $prev_key;

while (<STDIN>) {
    
    my ($key, $type, @remainder) = split(/\t\s*/);

    if (!$prev_key || $prev_key ne $key) {
        # process existing elements in the list
        &proc_key_entry($prev_key, \@s_messages, \@n_messages);
        
        # clean up
        @s_messages = ();
        @n_messages = ();
        
        $prev_key = $key;
    }

    if ($type eq 'n') {
        @n_messages = @remainder;
    } elsif ($type eq 's') {
        @s_messages = @remainder;
    }
}

&proc_key_entry($prev_key, \@s_messages, \@n_messages);
