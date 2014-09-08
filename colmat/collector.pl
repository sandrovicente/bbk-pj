# Collector for SIP messages
#
# Receives as input a stream of raw log lines
# For valid SIP messages, generate as output a line containing 
#  component class
#  cid
#  initiatior flag
#  structured SIP event serialized in JSON   

use strict;
use warnings;
use ordererlib;
use lm_env;

use JSON::XS;
use Data::Dumper;


# Filter out OPTION SIP messages 

sub check_sip_validity {
    my ($ref_sipmsg) = @_;
    if ($ref_sipmsg->{req} && $ref_sipmsg->{req} eq "OPTIONS") {
        return 0;
    }

    return 1;
}

# Indicates if the SIP event is initiating the sequence
#
# receives
#   component class
#   reference to SIP message in hash structure
# returns 1 if the event is initiating the sequence or 0 otherwise

sub check_initator {
	my ($comp, $ref_sipmsg) = @_;

    # identify the initiator
    # should either be component on the 'IN' or 'OUT' side.
    # additionally, should be a INVITE request without previous origin
    if (($comp eq $COMP_ORDER{IN}[0] || $comp eq $COMP_ORDER{OUT}[0])   
        && $ref_sipmsg->{req} 
        && $ref_sipmsg->{req} eq 'INVITE' 
        && &find_origin($ref_sipmsg, \%COMP_NET_ID)->{origin} eq 0) {
        
        return 1;
    }
    return 0;
}

# main reading loop
# groups all messages for a given call id
while (<STDIN>) {
		my @f = split;
		next if (@f == 0);

        my $comp = $COMP_NET_ID{$f[1]}; # obtain component class
		if (defined $comp) {
			my $ref_handler = $COMP_HANDLERS{$comp}; # component handler for given class
			my $sipmsg = $ref_handler->(\$_);        # obtain text refering to SIP message

            # carry on if was able to extract sip message
			next if (!$sipmsg);

            my $ref_psip = &parse_sip($sipmsg, $comp);  # obtain structured SIP message
   
            # carry on if was able to parse and validate sip message
            # in particular, remove uninteresting OPTIONS requests 
            next if (!$ref_psip || !check_sip_validity($ref_psip));

            # extract ts from the original message
            my $ts = &find_calc_tsms($_);
            $ref_psip->{tsms} = $ts;
            $ref_psip->{comp_name} = $f[1];

            # identify the initiator
            my $initiator = check_initator($comp, $ref_psip);
            my $json_sip = encode_json $ref_psip;

            if ($ref_psip && $ref_psip->{callid}) {
                print "$comp\t$ref_psip->{callid}\t";
                print "$initiator\t";
                print "$json_sip";
                print "\n";
            }
            else { print STDERR "*ERR: ". Dumper($sipmsg); }

		}
}

