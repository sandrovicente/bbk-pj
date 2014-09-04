use strict;
use warnings;
use Test::More;
use Data::Dumper;

BEGIN {
	use_ok('ordererlib');
} 

my @c_0_ev = (
    {req=>"invite", id=>1, tsms => 1, cseq_n=>1, origin=>"c_1"},
    {res=>"100", id=>2, tsms => 1, cseq_n=>1, origin=>0},
    {res=>"180", id=>3, tsms => 1, cseq_n=>1, origin=>0},
    {res=>"180", id=>4, tsms => 1, cseq_n=>1, origin=>0},
    {res=>"200", id=>5, tsms => 1, cseq_n=>1, origin=>0},
    {req=>"ack", id=>6, tsms => 1, cseq_n=>1, origin=>"c_1"});

my @c_1_ev = (
    {req=>"invite", id=>100, tsms => 1, cseq_n=>1, origin=>"c_2"},
    {res=>"100", id=>200, tsms => 1, cseq_n=>1, origin=>"c_2"},
    {res=>"100", id=>201, tsms => 1, cseq_n=>1, origin=>"c_2"},
    {res=>"180", id=>300, tsms => 1, cseq_n=>1, origin=>"c_2"},
    {res=>"180", id=>301, tsms => 1, cseq_n=>1, origin=>"c_2"},
    {res=>"200", id=>400, tsms => 1, cseq_n=>1, origin=>"c_2"},
    {req=>"ack", id=>500, tsms => 1, cseq_n=>1, origin=>"c_2"});

my @c_2_ev = (
    {req=>"invite", id=>1000, tsms => 1, cseq_n=>1, origin=>0},
    {res=>"100", id=>2000, tsms => 1, cseq_n=>1, origin=>"c_2"},
    {res=>"100", id=>2001, tsms => 1, cseq_n=>1, origin=>"c_2"},
    {res=>"180", id=>3000, tsms => 1, cseq_n=>1, origin=>"c_2"},
    {res=>"180", id=>3001, tsms => 1, cseq_n=>1, origin=>"c_2"},
    {res=>"200", id=>4000, tsms => 1, cseq_n=>1, origin=>"c_2"},
    {req=>"ack", id=>5000, tsms => 1, cseq_n=>1, origin=>0}); 

my @c_3_ev = (
    {req=>"invite", id=>10000, tsms => 1, cseq_n=>1, origin=>0},
    {res=>"180", id=>30000, tsms => 1, cseq_n=>1, origin=>"c_3"},
    {res=>"180", id=>30001, tsms => 1, cseq_n=>1, origin=>"c_3"},
    {res=>"200", id=>40000, tsms => 1, cseq_n=>1, origin=>"c_3"},
    {req=>"ack", id=>50000, tsms => 1, cseq_n=>1, origin=>0}); 

my %clust = (
    c_0 => \@c_0_ev,
    c_1 => \@c_1_ev,
    c_2 => \@c_2_ev,
    c_3 => \@c_3_ev
    );

my $ev;

sub sip_le_string {
	my($r_list_ev) = @_;

	my $ret = join "\n", map {
		my($req, $res); 
		$req = $_->{req} || "";
		$res = $_->{res} || ""; 
		"\t$req\t$res\t$_->{_ord}\t$_->{id}" 
	} @{$r_list_ev}; 
	$ret = "$ret\n";
}

my %order = (
    IN => [qw(c_0 c_1 c_2 c_3)],
    OUT => [qw(c_3 c_2 c_1 c_0)]
    );

my $merged = [];
foreach $ev(@{$order{IN}}) {
	print ">>$ev\n";
	my $ord = &order_sipn($clust{$ev});

	$merged = &order_merge_sipn($merged, $ord);
	
	#print sip_le_string($ord);
}

ok(eq_array($merged, [
          {
            'req' => 'invite',
            'origin' => 'c_1',
            'cseq_n' => 1,
            'id' => 1,
            'tsms' => 1,
            '_ord' => 0
          },
          {
            'req' => 'invite',
            'origin' => 'c_2',
            'cseq_n' => 1,
            'id' => 100,
            'tsms' => 1,
            '_ord' => 0
          },
          {
            'req' => 'invite',
            'origin' => 0,
            'cseq_n' => 1,
            'id' => 1000,
            'tsms' => 1,
            '_ord' => 0
          },
          {
            'req' => 'invite',
            'origin' => 0,
            'cseq_n' => 1,
            'id' => 10000,
            'tsms' => 1,
            '_ord' => 0
          },
          {
            'origin' => 'c_3',
            'cseq_n' => 1,
            'id' => 30000,
            'tsms' => 1,
            '_ord' => 0,
            'res' => 180
          },
          {
            'origin' => 'c_3',
            'cseq_n' => 1,
            'id' => 30001,
            'tsms' => 1,
            '_ord' => 1,
            'res' => 180
          },
          {
            'origin' => 'c_3',
            'cseq_n' => 1,
            'id' => 40000,
            'tsms' => 1,
            '_ord' => 0,
            'res' => 200
          },
          {
            'origin' => 'c_2',
            'cseq_n' => 1,
            'id' => 2000,
            'tsms' => 1,
            '_ord' => 0,
            'res' => 100
          },
          {
            'origin' => 'c_2',
            'cseq_n' => 1,
            'id' => 200,
            'tsms' => 1,
            '_ord' => 0,
            'res' => 100
          },
          {
            'origin' => 0,
            'cseq_n' => 1,
            'id' => 2,
            'tsms' => 1,
            '_ord' => 0,
            'res' => 100
          },
          {
            'origin' => 'c_2',
            'cseq_n' => 1,
            'id' => 2001,
            'tsms' => 1,
            '_ord' => 1,
            'res' => 100
          },
          {
            'origin' => 'c_2',
            'cseq_n' => 1,
            'id' => 201,
            'tsms' => 1,
            '_ord' => 1,
            'res' => 100
          },
          {
            'origin' => 'c_2',
            'cseq_n' => 1,
            'id' => 3000,
            'tsms' => 1,
            '_ord' => 0,
            'res' => 180
          },
          {
            'origin' => 'c_2',
            'cseq_n' => 1,
            'id' => 300,
            'tsms' => 1,
            '_ord' => 0,
            'res' => 180
          },
          {
            'origin' => 0,
            'cseq_n' => 1,
            'id' => 3,
            'tsms' => 1,
            '_ord' => 0,
            'res' => 180
          },
          {
            'origin' => 'c_2',
            'cseq_n' => 1,
            'id' => 3001,
            'tsms' => 1,
            '_ord' => 1,
            'res' => 180
          },
          {
            'origin' => 'c_2',
            'cseq_n' => 1,
            'id' => 301,
            'tsms' => 1,
            '_ord' => 1,
            'res' => 180
          },
          {
            'origin' => 0,
            'cseq_n' => 1,
            'id' => 4,
            'tsms' => 1,
            '_ord' => 1,
            'res' => 180
          },
          {
            'origin' => 'c_2',
            'cseq_n' => 1,
            'id' => 4000,
            'tsms' => 1,
            '_ord' => 0,
            'res' => 200
          },
          {
            'origin' => 'c_2',
            'cseq_n' => 1,
            'id' => 400,
            'tsms' => 1,
            '_ord' => 0,
            'res' => 200
          },
          {
            'origin' => 0,
            'cseq_n' => 1,
            'id' => 5,
            'tsms' => 1,
            '_ord' => 0,
            'res' => 200
          },
          {
            'req' => 'ack',
            'origin' => 'c_1',
            'cseq_n' => 1,
            'id' => 6,
            'tsms' => 1,
            '_ord' => 0
          },
          {
            'req' => 'ack',
            'origin' => 'c_2',
            'cseq_n' => 1,
            'id' => 500,
            'tsms' => 1,
            '_ord' => 0
          },
          {
            'req' => 'ack',
            'origin' => 0,
            'cseq_n' => 1,
            'id' => 5000,
            'tsms' => 1,
            '_ord' => 0
          },
          {
            'req' => 'ack',
            'origin' => 0,
            'cseq_n' => 1,
            'id' => 50000,
            'tsms' => 1,
            '_ord' => 0
          }
	]));


#print "-------\n";
#print sip_le_string($merged);

#print "-------\n";
#print Dumper($merged);

done_testing();
