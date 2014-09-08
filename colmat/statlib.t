use strict;
use warnings;
use Test::More;
use Data::Dumper;

BEGIN {
	use_ok('statlib');
} 

my $ref_ord_sipn = [
    {req => "INVITE", _ord=>0, origin => 0, tsms => 1, cseq_n => 1},
    {res => 100, _ord=>0, origin => 0, tsms => 1, cseq_n => 1},
    {res => 180, _ord=>0, origin => 0, tsms => 1, cseq_n => 1},
    {res => 180, _ord=>1, origin => 0, tsms => 1, cseq_n => 1},
    {res => 200, _ord=>0, origin => 0, tsms => 1, cseq_n => 1},
	{req => "ACK", _ord=>0, origin => 0, tsms => 1, cseq_n => 1},
    {req => "BYE", _ord=>0, origin => 0, tsms => 2, cseq_n => 2},
    {res => 200, _ord=>0, origin => 0, tsms => 2, cseq_n => 2}
	];

ok(eq_array(&stat_count($ref_ord_sipn),
	{ 
		req => { 
			  INVITE => 1,
			  ACK => 1,
			  BYE => 1 },
		 res => {
			  100 => 1,
			  180 => 2, 
			  200 => 2 }}));

my $list_ev_0 = [
	{req => "INVITE", cseq=>"1 INVITE", tsms => 1},
	{res => "100", cseq=>"1 INVITE", tsms => 2, req_ts=>1},
	{res => "200", cseq=>"1 INVITE", tsms => 12, req_ts=>11},
];
 

my $ret = &summarize_list_ev2($list_ev_0);
my ($ts_ini, $ts_end, $ts_name, $count, $max, $mean, $min, $std, $token) = map { $ret->{$_} } qw(ts_ini ts_end ts_name count req_max req_mean req_min req_std token);

is($count, 1);
is($max,11);
is($min,11);
is($mean,11);
is($std,0);
is($token, "INVITE;200");

print "ts_ini=$ts_ini, ts_end=$ts_end, ts_name=$ts_name, count=$count, max=$max, mean=$mean, min=$min, std=$std, token=$token\n";

my $list_ev = [
	{req => "INVITE", cseq=>"1 INVITE", tsms => 1},
	{res => "100", cseq=>"1 INVITE", tsms => 2, req_ts=>1, last_ts=>1},
	{res => "180", cseq=>"1 INVITE", tsms => 4, req_ts=>3, last_ts=>2},
	{res => "180", cseq=>"1 INVITE", tsms => 8, req_ts=>7, last_ts=>4},
	{res => "180", cseq=>"1 INVITE", tsms => 12, req_ts=>11, last_ts=>4},
	{res => "200", cseq=>"1 INVITE", tsms => 12, req_ts=>11, last_ts=>0},
];

$ret = &summarize_list_ev2($list_ev);
($ts_ini, $ts_end, $ts_name, $count, $max, $mean, $min, $std, $token) = map { $ret->{$_} } qw(ts_ini ts_end ts_name count req_max req_mean req_min req_std token);

is($count, 4);
is($max,11);
is($min,3);
is($mean,8);
is(int($std*1000),3829);
is($ts_ini, 1);
is($ts_end, 12);
is($token, "INVITE;180;180;180;200");

print "ts_ini=$ts_ini, ts_end=$ts_end, ts_name=$ts_name, count=$count, max=$max, mean=$mean, min=$min, std=$std, token=$token\n";

my $list_ev2 = [
	{req => "INVITE", cseq=>"1 INVITE", tsms => 1},
	{res => "100", cseq=>"1 INVITE", tsms => 2, req_ts=>1, last_ts=>1},
	{res => "180", cseq=>"1 INVITE", tsms => 4, req_ts=>3, last_ts=>2},
	{res => "180", cseq=>"1 INVITE", tsms => 8, req_ts=>7, last_ts=>4},
	{res => "180", cseq=>"1 INVITE", tsms => 12, req_ts=>11, last_ts=>4},
	{res => "200", cseq=>"1 INVITE", tsms => 12, req_ts=>11, last_ts=>4},
	{req => "ACK", cseq=>"1 ACK", tsms => 13},
	{req => "BYE", cseq=>"2 BYE", tsms => 120},
	{res => "200", cseq=>"2 BYE", tsms => 122, req_ts=>2, last_ts=>2},
];

$ret = &summarize_list_ev2($list_ev2);
($ts_ini, $ts_end, $ts_name, $count, $max, $mean, $min, $std, $token) = map { $ret->{$_} } qw(ts_ini ts_end ts_name count req_max req_mean req_min req_std token);

is($count, 4);
is($max,11);
is($min,3);
is($mean,8);
is(int($std*1000),3829); # must account only for call establishing
is($token, "INVITE;180;180;180;200;ACK;BYE;200"); # but report full pattern
is($ts_ini, 1);
is($ts_end, 13);

# testing the new summarizer

my $r_ret = &summarize_list_ev2($list_ev);

print Dumper($r_ret); 

is($r_ret->{count}, 4);
is($r_ret->{req_max},11);
is($r_ret->{req_min},3);
is($r_ret->{req_mean},8);
is(int($r_ret->{req_std}*1000),3829);
is($r_ret->{last_max}, 4);
is($r_ret->{last_min}, 0);
is($r_ret->{last_mean}, 2.5);
is(int($r_ret->{last_std}*1000),1914); 
is($r_ret->{ts_ini}, 1);
is($r_ret->{ts_end}, 12);
is($r_ret->{token}, "INVITE;180;180;180;200");

done_testing();
1
