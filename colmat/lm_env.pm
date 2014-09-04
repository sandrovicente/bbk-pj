package lm_env;

use strict;
use warnings;

use Exporter;
use vars qw(@ISA @EXPORT);

@ISA = qw(Exporter);	
@EXPORT= qw(
	%COMP_NET_ID
	%COMP_HANDLERS
    %COMP_ORDER
);

our %COMP_NET_ID = (
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

our %COMP_ORDER = (
    IN => [qw(c_0 c_1 c_2 c_3)],
    OUT => [qw(c_3 c_2 c_1 c_0)]
    );

# handlers to obtain sip message from log message (or undef if not containing it)
use ordererlib;

our %COMP_HANDLERS = (
	"c_0" => \&msg_handler_opensips,
	"c_1" => \&msg_handler_opensips,
	"c_2" => \&msg_handler_opensips,
	"c_3" => \&msg_handler_sipgw
);

