# Send full LEs to analytical database using RESTful interface 
#

use strict;
use warnings;

use JSON::XS;

use Data::Dumper;

use LWP::UserAgent;
use HTTP::Request;

#
# Default parameters for Elasticsearch
#
my ($host, $port, $index) = ('localhost', 9200, 'le');

if (@ARGV >= 3) {
	$host = $ARGV[0];
	$port = $ARGV[1];
	$index = $ARGV[2];
}

print "Using host= $host, port= $port, index='$index'\n";

my $rest_url_root = "http://$host:$port/f_$index/";

sub put_data {
    my($type, $key, $content) = @_;
    
    my $dec_content = decode_json $content;
    
    my $seq = 0;
    for my $json_content (@{$dec_content}) {
    
        my $url = $rest_url_root . $type . "/" . $key . "_" . $seq;
        
        $json_content->{_ord} = int($seq);
        
        my $ua = LWP::UserAgent->new;
        my $req = HTTP::Request->new("PUT", $url);
        $req->content_type('application/JSON');
        $req->content(encode_json $json_content);
        my $resp = $ua->request($req);
        print "$url\t" . $resp->status_line . "\n";
        ++$seq;
    }        
}

## Main LOOP ##

while (<STDIN>) {
    my ($key, $type, $msg) = split(/\t\s*/);
    
    &put_data("event_sequence", $key, $msg);
}
    
