# zcat GA_15_04_2014/*.gz | perl orderer.pl "MjJjODk0YzZmZTQ2OTIwNmM4NGM0OGEzZmU5NzIzMmQ." 1

use strict;
use warnings;
use ordererlib;

# 5c9954f-ee9a-4dce-9d67-af2de3fa9b9a

# maps server names and ip's to component classes
my %clas = (
"10.16.195.100" => "c_0",
"10.16.195.102" => "c_0",
"10.16.195.104" => "c_0",
"10.16.195.106" => "c_0",
"10.203.231.195" => "c_2",
"10.203.231.196" => "c_2",
"10.203.231.201" => "c_2",
"10.203.231.202" => "c_2",
"10.203.231.197" => "c_1",
"10.203.231.198" => "c_1",
"10.203.231.199" => "c_1",
"10.203.231.200" => "c_1",
"10.24.171.101" => "c_0",
"10.24.171.102" => "c_0",
"10.24.171.103" => "c_0",
"10.24.171.104" => "c_0",
"10.203.234.199" => "c_2",
"10.203.234.200" => "c_2",
"10.203.234.201" => "c_2",
"10.203.234.202" => "c_2",
"10.203.234.195" => "c_1",
"10.203.234.196" => "c_1",
"10.203.234.197" => "c_1",
"10.203.234.198" => "c_1",
"10.244.0.104" => "c_0",
"10.244.0.105" => "c_0",
"10.244.0.106" => "c_0",
"10.244.0.107" => "c_0",
"10.203.231.227" => "c_3",
"10.203.231.228" => "c_3", 
"10.203.234.227" => "c_3",
"10.203.234.228" => "c_3",
"ams-lync-ces1" => "c_0",
"ams-lync-ces2" => "c_0",
"ams-lync-ces3" => "c_0",
"ams-lync-ces4" => "c_0",
"hkn-lync-ces1" => "c_0",
"hkn-lync-ces2" => "c_0",
"hkn-lync-ces3" => "c_0",
"hkn-lync-ces4" => "c_0",
"sn2-lync-ces1" => "c_0",
"sn2-lync-ces2" => "c_0",
"sn2-lync-ces3" => "c_0",
"sn2-lync-ces4" => "c_0",
"du5-lync-css3" => "c_1",
"du5-lync-css4" => "c_1",
"lu4-lync-css1" => "c_1",
"lu4-lync-css2" => "c_1",
"du5-lync-ccs3" => "c_2",
"du5-lync-ccs4" => "c_2",
"lu4-lync-ccs1" => "c_2",
"lu4-lync-ccs2" => "c_2",
"du5-lync-sip172" => "c_3",
"du5-lync-sip173" => "c_3",
"lu4-lync-sip180" => "c_3",
"lu4-lync-sip181" => "c_3"
);


# handlers to obtain sip message from log message (or undef if not containing it)
my %handlers = (
	"c_0" => \&msg_handler_opensips,
	"c_1" => \&msg_handler_opensips,
	"c_2" => \&msg_handler_opensips,
	"c_3" => \&msg_handler_sipgw
	
);

# list of messages per component classes
my %clust = (
    "c_0" => [],
    "c_1" => [],
    "c_2" => [],
    "c_3" => [] 
    );

sub sip_to_string {
	my ($ref_sipmsg) = @_;

    if (defined $ref_sipmsg->{'via'}) {
        my $type;
        if (defined $ref_sipmsg->{'req'}) {
            $type = "Req-$ref_sipmsg->{'req'}";
        } elsif (defined $ref_sipmsg->{'res'}) {
            $type = "Res-$ref_sipmsg->{'res'}";
        }
		return "[$type V:$ref_sipmsg->{'via'},C:$ref_sipmsg->{'cseq'} To:$ref_sipmsg->{to_uri} From:$ref_sipmsg->{from_uri}] " . $ref_sipmsg->{local} . " <- " . $ref_sipmsg->{'origin'} ;
    }
}


sub output_per_component {
    my ($ref_cmp_list, $debug) = @_;
    my $k;

	my $r_merged_ord_psip_list = [];
	
	foreach $k ( @{$ref_cmp_list} ) {
        print ">>$k\n";
        my $handler_ref = $handlers{$k};
        my $ord_msgs = $clust{$k};

		my @parsed_sip_list = ();
        foreach my $msg(@{$ord_msgs}) {
            my $sipmsg = $handler_ref->(\$msg); 
            next if (!$sipmsg);
            my $ref_psip = &parse_sip($sipmsg);

            my $ts = &find_calc_tsms($msg);
            $ref_psip->{tsms} = $ts;

        	&find_origin($ref_psip, \%clas); 
			$ref_psip->{local} = $k;
		
			 if ($debug) {
                 my $sipmsg_print = $sipmsg; 
                 $sipmsg_print =~ s/\#015/\n/g;
                 $sipmsg_print =~ s/\#012//g;
                print "* [$k < $ref_psip->{origin}]\t{$sipmsg_print}\n";
            }
			push @parsed_sip_list, $ref_psip;
        }
		my $r_ord_psip_list = &order_sipn(\@parsed_sip_list);
		$r_merged_ord_psip_list = &order_merge_sipn($r_merged_ord_psip_list, $r_ord_psip_list);
 
		print join "\n", map { sip_to_string($_) } @{$r_ord_psip_list}; print "\n";
		print "\n";
    }

	print ">>>>>\n";
	print join "\n", map { sip_to_string($_) } @{$r_merged_ord_psip_list}; print "\n";
}


my $sch = quotemeta "$ARGV[0]";

# process command line
my $start = $ARGV[1];
$start == 1 || $start == 0 || die("first argument 0 or 1!");
my $debug = lc($ARGV[2]) eq "d";

print "-----> search for $ARGV[0]\n";
my $line = 0;

# main reading loop
# groups all messages for a given call id
while (<STDIN>) {
    if (/$sch/) {
        my @f = split;
        my $comp = $clas{$f[1]};
        if (defined $comp) {
            ++$line;
            $_ = $line . " ". $_;
            push (@{ $clust{$comp} }, $_);
        }
    }
}

print ">>>>>>>>>>>>>>>>>>>>\n";

my @sequences = ( ['c_3', 'c_2', 'c_1', 'c_0'], ['c_0', 'c_1', 'c_2', 'c_3'] );


#does the processing
output_per_component(\@{$sequences[$start]}, $debug);

