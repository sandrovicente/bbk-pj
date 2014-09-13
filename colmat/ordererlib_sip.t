use strict;
use Test::More;
use Data::Dumper;

BEGIN {
	use_ok('ordererlib');
}

my $sip_invite = 'INVITE sip:dfdasfsd.fdsafadsa@dxvdsf.asas SIP/2.0#015#012Record-Route: <sip:11.32.212.212;r2=on;lr;ftag=7c0c1159;did=2f4.06dcd7a1>#015#012Record-Route: <sip:11.21.88.197;r2=on;lr;ftag=7c0c1159;did=2f4.06dcd7a1>#015#012Via: SIP/2.0/UDP 11.32.212.212;branch=z9hG4bKa253.52c80386.0#015#012Via: SIP/2.0/UDP 10.203.231.196;branch=z9hG4bKa253.f1d33cf6.0#015#012Max-Forwards: 67#015#012P-Asserted-Identity: <sip:safsafads@fdsfdsf.xss>#015#012Contact: <sip:11.32.212.212:5060;did=2f4.f47aea41>#015#012To: <sip:dfdasfsd.fdsafadsa@dxvdsf.asas>#015#012From: <sip:safsafads@fdsfdsf.xss>;tag=7c0c1159#015#012Call-ID: MjJjODk0YzZmZTQ2OTIwNmM4NGM0OGEzZmU5NzIzMmQ.#015#012CSeq: 1 INVITE#015#012Allow: UPDATE, INVITE, ACK, CANCEL, OPTIONS, BYE#015#012Content-Type: application/sdp#015#012User-Agent: xxx-1.0.1.0#015#012Content-Length: 540#015#012Min-SE: 1800#015#012Supported: timer#015#012Session-Expires: 1800;refresher=uas#015#012#015#012v=0#015#012o=dfdasfsd 1397563290 1397563290 IN IP4 131.180.91.111#015#012s=Skype call#015#012c=IN IP4 131.11.11.11#015#012t=0 0#015#012m=audio 54004 RTP/AVP 9 0 8 100 104 102 103 117 116 124 18 101#015#012a=rtpmap:9 G722/8000#015#012a=rtpmap:0 PCMU/8000#015#012a=rtpmap:8 PCMA/8000#015#012a=rtpmap:100 SILK_V3/24000#015#012a=rtpmap:104 SILK_WB_V3/16000#015#012a=rtpmap:102 SILK_MB_V3/12000#015#012a=rtpmap:103 SILK_NB_V3/8000#015#012a=rtpmap:117 NWC/16000#015#012a=rtpmap:116 UNCODEDWB/16000#015#012a=rtpmap:124 UNCODEDSWB/24000#015#012a=rtpmap:18 G729/8000#015#012a=fmtp:18 annexb=no#015#012a=rtpmap:101 telephone-event/8000#015#012a=nortpproxy:yes#015#012';

my $sip_100 = 'SIP/2.0 100 Giving a try#015 Via: SIP/2.0/UDP 11.213.243.128:5060;received=11.213.243.128;branch=z9hG4bK-d8754z-7adf557b6c1c9206-1---d8754z-;rport=5060#015 To: <sip:dfdasfsd.fdsafadsa@dxvdsf.asas>#015 From: <sip:dfdasfsd@bombo.coo:5060>;tag=7c0c1159#015 Call-ID: MjJjODk0YzZmZTQ2OTIwNmM4NGM0OGEzZmU5NzIzMmQ.#015 CSeq: 1 INVITE#015 Content-Length: 0#015 #015 ';

my $sip_404 = 'SIP/2.0 404 Not Found#015 Via: SIP/2.0/UDP 11.213.243.128:5060;branch=z9hG4bK-d8754z-7adf557b6c1c9206-1---d8754z-;rport#015 To: <sip:dfdasfsd.fdsafadsa@dxvdsf.asas>;tag=b88f06a94;epid=0DE491BF79#015 From: <sip:dfdasfsd@bombo.coo:5060>;tag=7c0c1159#015 Call-ID: MjJjODk0YzZmZTQ2OTIwNmM4NGM0OGEzZmU5NzIzMmQ.#015 CSeq: 1 INVITE#015 Server: RTCC/5.0.0.0 CoreServer#015 User-Agent: yyy-0.0.1#015 ms-diagnostics: 1034;reason="Previous hop federated peer did not report diagnostic information";Domain="xixima.xabal";PeerServer="xixima.xabal.xe";source="banbababa.dfdafafa.sss.iii"#015 ms-diagnostics: 10003;source="babababa.xaca.das.aaa";reason="Proxy returned a SIP failure code";component="CoreServer";SipResponseCode="404";SipResponseText="Not Found"#015 ms-diagnostics-public: 10003;reason="Proxy returned a SIP failure code";component="CoreServer";SipResponseCode="404";SipResponseText="Not Found"#015 X-Remote-Reason: 1409; reason="404 - Not Found"; component="ConnectSIPServer"; hostname="xya-abcd-wfa"#015 Content-Length: 0#015 #015 ';

# INVITE tests

my $sip_parse = &parse_sip($sip_invite); 
ok(defined $sip_parse);
is($sip_parse->{'req'}, 'INVITE', 'Parse sip INVITE');
is($sip_parse->{'via'}, '11.32.212.212');
my $via_l = $sip_parse->{'via_l'};
ok(defined $via_l, "via_l: @{$via_l}");

my %clas = ("11.32.212.212" => "xxx" );
&find_origin($sip_parse, \%clas);
is($sip_parse->{'origin'}, 'xxx', 'known origin');

# 100 trying tests

$sip_parse = &parse_sip($sip_100); 
ok(defined $sip_parse);
is($sip_parse->{'res'}, 100, 'Parse sip 100 response');
is($sip_parse->{'via'}, '11.213.243.128:5060');

is(&find_origin($sip_parse, \%clas)->{'origin'}, 0, 'external origin');

# 404 not found tests
$sip_parse = &parse_sip($sip_404); 
ok(defined $sip_parse);
is($sip_parse->{'res'}, 404, 'Parse sip 404 response');

# broken INVITE tests

my $sip_broken = 'INVITE sip:dfdasfsd.fdsafadsa@dxvdsf.asas SIP/2.0#015#012Record-Route: <sip:11.32.212.212;r';

# is this ok?? does NOT return undefined ..., but is BROKEN
my $sip_broken_parse = &parse_sip($sip_broken);
ok(defined $sip_broken_parse);
is($sip_broken_parse->{'req'}, 'INVITE');
is($sip_broken_parse->{'via'}, undef);

is(&find_origin($sip_parse, \%clas)->{'origin'}, 0, 'external origin');

# test parameter for component for the message 
$sip_parse = &parse_sip($sip_invite, 'COMP1'); 
ok(defined $sip_parse);
is($sip_parse->{'req'}, 'INVITE', 'Parse sip INVITE');
is($sip_parse->{'via'}, '11.32.212.212');
is($sip_parse->{component}, "COMP1");
my $via_l = $sip_parse->{'via_l'};
ok(defined $via_l, "via_l: @{$via_l}");

my @sipn = (
    {res => 200, origin => 0, tsms => 5, cseq_n => 2},
    {res => 200, origin => 0, tsms => 1, cseq_n => 1},
    {req => "BYE", origin => 0, tsms => 5, cseq_n => 2},
    {res => 100, origin => 0, tsms => 1, cseq_n => 1},
    {req => "ACK", origin => 0, tsms => 4, cseq_n => 1},
    {req => "INVITE", origin => 0, tsms => 1, cseq_n => 1},
);

my $ref_ord_sipn = &order_sipn(\@sipn);

my @sipn_expected = (
    {req => "INVITE", _ord=>0, origin => 0, tsms => 1, cseq_n => 1},
    {res => 100, _ord=>0, origin => 0, tsms => 1, cseq_n => 1},
    {res => 200, _ord=>0, origin => 0, tsms => 1, cseq_n => 1},
    {req => "ACK", _ord=>0, origin => 0, tsms => 4, cseq_n => 1},
    {req => "BYE", _ord=>0, origin => 0, tsms => 5, cseq_n => 2},
    {res => 200, _ord=>0, origin => 0, tsms => 5, cseq_n => 2},
);

ok(eq_array($ref_ord_sipn, \@sipn_expected), 'ordering check');
#print Dumper($ref_ord_sipn) . "\n";
# ordering list of events with repeated requests (i.e. repeated 180/183)

@sipn = (
    {res => 200, origin => 0, tsms => 1, cseq_n => 1},
    {req => "BYE", origin => 0, tsms => 2, cseq_n => 2},
    {res => 200, origin => 0, tsms => 2, cseq_n => 2},
    {res => 100, origin => 0, tsms => 1, cseq_n => 1},
    {res => 180, origin => 0, tsms => 1, cseq_n => 1},
    {res => 180, origin => 0, tsms => 1, cseq_n => 1},
	{req => "ACK", origin => 0, tsms => 1, cseq_n => 1},
    {req => "INVITE", origin => 0, tsms => 1, cseq_n => 1},
);

$ref_ord_sipn = &order_sipn(\@sipn);
#print Dumper($ref_ord_sipn);

ok(eq_array($ref_ord_sipn, [
    {req => "INVITE", _ord=>0, origin => 0, tsms => 1, cseq_n => 1},
    {res => 100, _ord=>0, origin => 0, tsms => 1, cseq_n => 1},
    {res => 180, _ord=>0, origin => 0, tsms => 1, cseq_n => 1},
    {res => 180, _ord=>1, origin => 0, tsms => 1, cseq_n => 1},
    {res => 200, _ord=>0, origin => 0, tsms => 1, cseq_n => 1},
	{req => "ACK", _ord=>0, origin => 0, tsms => 1, cseq_n => 1},
    {req => "BYE", _ord=>0, origin => 0, tsms => 2, cseq_n => 2},
    {res => 200, _ord=>0, origin => 0, tsms => 2, cseq_n => 2}
	]), 'ordering check with repeated responses');
print join "\n", map { ">$_->{req}\t$_->{res}\t$_->{cseq_n}" } @{$ref_ord_sipn}; print "\n";

my @a = (
    {req=>"invite", _ord=>0, id=>1},
    {res=>"100", _ord=>0, id=>2},
    {res=>"200", _ord=>0, id=>3},
    {req=>"ack", _ord=>0, id=>5});
my @b = (
    {req=>"invite", _ord=>0, id=>100},
    {res=>"100", _ord=>0, id=>200},
    {res=>"180", _ord=>0, id=>300},
    {res=>"200", _ord=>0, id=>400},
    {req=>"ack", _ord=>0, id=>500});
my @c = (
    {req=>"invite", _ord=>0, id=>1000},
    {res=>"100", _ord=>0, id=>2000},
    {res=>"180", _ord=>0, id=>3000},
    {res=>"200", _ord=>0, id=>4000},
    {req=>"ack", _ord=>0, id=>5000});

my @ab_expected = (
    {req=>"invite", _ord=>0, id=>1},
    {req=>"invite", _ord=>0, id=>100},
    {res=>"100", _ord=>0, id=>200},
    {res=>"100", _ord=>0, id=>2}, 
    {res=>"180", _ord=>0, id=>300},
    {res=>"200", _ord=>0, id=>400},
    {res=>"200", _ord=>0, id=>3},
    {req=>"ack", _ord=>0, id=>5},
    {req=>"ack", _ord=>0, id=>500},
);

my @abc_expected = (
    {req=>"invite", _ord=>0, id=>1},
    {req=>"invite", _ord=>0, id=>100},
    {req=>"invite", _ord=>0, id=>1000},
    {res=>"100", _ord=>0, id=>2000},
    {res=>"100", _ord=>0, id=>200},
    {res=>"100", _ord=>0, id=>2}, 
    {res=>"180", _ord=>0, id=>3000},
    {res=>"180", _ord=>0, id=>300},
    {res=>"200", _ord=>0, id=>4000},
    {res=>"200", _ord=>0, id=>400},
    {res=>"200", _ord=>0, id=>3},
    {req=>"ack", _ord=>0, id=>5},
    {req=>"ack", _ord=>0, id=>500},
    {req=>"ack", _ord=>0, id=>5000}
    );

my @nl = ();
my $rret = &order_merge_sipn(\@a, \@nl);
ok(eq_array($rret, \@a), 'merging check identity');

#print Dumper($rret) . "\n". Dumper(\@a);
#print join "\n", map { ">$_->{id}\t$_->{req}\t$_->{res}" } @{$rret}; print "\n";

$rret = &order_merge_sipn(\@a, \@b);
ok(eq_array($rret, \@ab_expected), 'merging check');

$rret = &order_merge_sipn($rret, \@c); 
ok(eq_array($rret, \@abc_expected), 'merging check 2');

#print join "\n", map { ">$_->{id}\t$_->{req}\t$_->{res}" } @{$rret}; print "\n";

# test ordering CANCELs

@sipn = (
    {req => "INVITE", origin => 0, tsms => 1, cseq_n => 1},
    {res => 100, origin => 0, tsms => 1, cseq_n => 1},
    {res => 180, origin => 0, tsms => 1, cseq_n => 1},
    {res => 180, origin => 0, tsms => 1, cseq_n => 1},
    {req => "CANCEL", origin => 0, tsms => 1, cseq_n => 1},
    {res => 487, origin => 0, tsms => 1, cseq_n => 1},
	{res => 200, origin => 0, tsms => 1, cseq_n => 1},
);

$ref_ord_sipn = &order_sipn(\@sipn);
print Dumper($ref_ord_sipn);



done_testing(); 
