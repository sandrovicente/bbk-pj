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

sub put_data {
    my($type, $key, $content) = @_;
    
    my $dec_content = decode_json $content;
    
    my $seq = 0;
    my $bulk = [];
    for my $json_content (@{$dec_content}) {
    
        $json_content->{_ord} = int($seq);
 
        push($bulk, { index => { _index => "f_$index", _type=> $type,  _id => $key . "_" . $seq } });
        push($bulk, $json_content); 

        ++$seq;
    }    

    my $bulk_url = "http://$host:$port/_bulk";

    my $ua = LWP::UserAgent->new;
    my $req = HTTP::Request->new("POST", $bulk_url);
    $req->content_type('application/JSON');

    my $serial_bulk = join "\n", map { encode_json $_ } @{$bulk};
    $serial_bulk .= "\n";

    $req->content($serial_bulk);
    my $resp = $ua->request($req);

    print $serial_bulk;
    print "$bulk_url\t" . $resp->status_line . "\n";
}

## Main LOOP ##

while (<STDIN>) {
    my ($key, $type, $msg) = split(/\t\s*/);
    
    &put_data("event_sequence", $key, $msg);
}
    
