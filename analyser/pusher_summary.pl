# Send summarized LEs to analytical database using RESTful interface 
#

use strict;
use warnings;

use JSON::XS;
use statlib;

use Data::Dumper;

use LWP::UserAgent;
use HTTP::Request;

# ElasticSearch default values

my ($host, $port, $index) = ('localhost', 9200, 'le');

if (@ARGV >= 3) {
	$host = $ARGV[0];
	$port = $ARGV[1];
	$index = $ARGV[2];
}

print "Using host= $host, port= $port, index='$index'\n";

my $rest_url_root = "http://$host:$port/s_$index/";

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
        print "$url\t" . $resp->status_line . "\n";
    }    
}

## Main LOOP ##

while (<STDIN>) {
    my ($key, $type, $msg) = split(/\t\s*/);
    
    &put_data("summary", $key, $msg);
}
    
