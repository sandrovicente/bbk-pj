use strict;
use warnings;

use JSON::XS;

use Data::Dumper;

use LWP::UserAgent;
use HTTP::Request;

my ($host, $port) = ('localhost', 9200);

if (@ARGV >= 2) {
	$host = $ARGV[0];
	$port = $ARGV[1];
}

print "Using host= $host, port= $port\n";

my $rest_url_root = "http://$host:$port/events/";

# curl -<REST Verb> <Node>:<Port>/<Index>/<Type>/<ID>

sub put_data {
    my($type, $key, $content) = @_;
    
    my $dec_content = decode_json $content;
    my $new_content; # = encode_json $dec_content->[0];
    
    my $seq = 0;
    for my $json_content (@{$dec_content}) {
    
        my $url = $rest_url_root . $type . "/" . $key . "_" . $seq;
        
        $json_content->{_ord} = int($seq);
        
        my $ua = LWP::UserAgent->new;
        my $req = HTTP::Request->new("PUT", $url);
        $req->content_type('application/JSON');
        $req->content(encode_json $json_content);
        my $resp = $ua->request($req);
        #print Dumper($resp);
        print "$url\t" . $resp->status_line . "\n";
        ++$seq;
    }        
}

## Main LOOP ##

while (<STDIN>) {
    my ($key, $msg) = split(/\t\s*/);
    
    #my $r_le = decode_json($msg);
    
    &put_data("event_sequence", $key, $msg);
}
    
