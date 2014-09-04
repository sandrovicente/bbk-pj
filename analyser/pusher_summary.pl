use strict;
use warnings;

use JSON::XS;
use statlib;

use Data::Dumper;

use LWP::UserAgent;
use HTTP::Request;

my ($host, $port) = ('localhost', 9200);

if (@ARGV >= 2) {
	$host = $ARGV[0];
	$port = $ARGV[1];
}
print "Using host= $host, port= $port\n";

my $rest_url_root = "http://$host:$port/summaries/";

# curl -<REST Verb> <Node>:<Port>/<Index>/<Type>/<ID>

sub put_data {
    my($type, $key, $content) = @_;
    
    my $dec_content = decode_json $content;
    
    my $r_summary = summarize_list_ev2($dec_content);
    
    if (defined $r_summary) {
        my $url = $rest_url_root . $type . "/" . $key;
        my %summary_content = (
            ts_ini => $r_summary->{ts_ini},
            ts_end => $r_summary->{ts_end},
            ts_name => $r_summary->{ts_name},
            count => $r_summary->{count}, 
            req_max => $r_summary->{req_max},
            req_min => $r_summary->{req_min},
            req_mean => $r_summary->{req_mean}, 
            req_std => $r_summary->{req_std},
            last_max => $r_summary->{last_max},
            last_min => $r_summary->{last_min},
            last_mean => $r_summary->{last_mean}, 
            last_std => $r_summary->{last_std},
            pattern => $r_summary->{token}
        );

        my $ua = LWP::UserAgent->new;
        my $req = HTTP::Request->new("PUT", $url);
        $req->content_type('application/JSON');
        $req->content(encode_json \%summary_content);
        my $resp = $ua->request($req);
        #print Dumper($resp);
        print Dumper(\%summary_content);
        print "$url\t" . $resp->status_line . "\n";
    }    
}

## Main LOOP ##

while (<STDIN>) {
    my ($key, $msg) = split(/\t\s*/);
    
    #my $r_le = decode_json($msg);
    
    &put_data("summary2", $key, $msg);
}
    
