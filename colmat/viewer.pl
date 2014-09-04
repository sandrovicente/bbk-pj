use strict;
use warnings;

use ordererlib;
use statlib;
use lm_env;

use JSON::XS;


sub name_to_string {
    my ($ref_namemsg) = @_;

    if (defined $ref_namemsg->{type}) {
        return "N:"
            . $ref_namemsg->{from} . "\t"
            . $ref_namemsg->{ts_ini} . "\t"
            . $ref_namemsg->{ts_diff} . "\t"
            . $ref_namemsg->{result} . "\t"
            . "\n"
    }
}

sub sip_to_string {
	my ($ref_sipmsg) = @_;

    if (defined $ref_sipmsg->{'via'}) {
        my $type;
        my $tab = "";
        my $origin = &find_origin($ref_sipmsg, \%COMP_NET_ID);
        if (defined $ref_sipmsg->{'req'}) {
            $type = "Req-$ref_sipmsg->{'req'}";
        } elsif (defined $ref_sipmsg->{'res'}) {
            $type = "Res-$ref_sipmsg->{'res'}";
            $tab = " ";
        }

        my $last_ts = $ref_sipmsg->{last_ts};
        my $req_ts = $ref_sipmsg->{req_ts};

		return $tab . "$type C:$ref_sipmsg->{'cseq'} " . " $ref_sipmsg->{tsms} " 
            . $ref_sipmsg->{component} . "\t" #. " <- " . $ref_sipmsg->{origin} . "\t"
            . (defined $last_ts ? $last_ts : "") . "\t" 
            . (defined $req_ts ? $req_ts : "") . "\t" 
        . "\n";
    }
}

sub report{
    my ($key, $r_le) = @_;

    print "$key\n";
    print "\tFrom: " . $r_le->[0]->{from_uri} . "\n";
    print "\tTo: " . $r_le->[0]->{to_uri} . "\n";

    #&time_diff_com($r_le);

    foreach my $ev(@{$r_le}) {
        print sip_to_string($ev);
        print name_to_string($ev);
    }
    print "\n";
}


## MAIN - Loop ##
 
while (<STDIN>) {
    my ($key, $type, $msg) = split(/\t\s*/);

    my $r_le = decode_json($msg);

    &report($key, $r_le);

}
