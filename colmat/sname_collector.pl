use strict;
use warnings;
use lib "..";
use ordererlib;
use lm_env;

#
# Clone of collector.pl, but use contents of "From" header as key (as opposed to Cid)
#
# Obs.: Collector could be modified to perform this task as well, even simultaneously 
# generate outputs for two further MapReduce processes (MR-2 and MR-3).
# 
# This is in the cod improvement task list

use JSON::XS;
use Data::Dumper;

sub check_sip_validity {
    my ($ref_sipmsg) = @_;
    if ($ref_sipmsg->{req} && $ref_sipmsg->{req} eq "OPTIONS") {
        return 0;
    }

    return 1;
}

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

		my $comp = $COMP_NET_ID{$f[1]};
		if (defined $comp) {
			my $ref_handler = $COMP_HANDLERS{$comp};
			my $sipmsg = $ref_handler->(\$_);

            # carry on if was able to extract sip message
			next if (!$sipmsg);

            my $ref_psip = &parse_sip($sipmsg, $comp);
   
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
                print "$ref_psip->{tsms}\t";
                print "$ref_psip->{from_uri}\t$ref_psip->{to_uri}\t";
                print "$json_sip";
                print "\n";
            }
            else { print STDERR "*ERR: Component $comp\t". Dumper($sipmsg); }

		}
}
