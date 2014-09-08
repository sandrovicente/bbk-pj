package lm_env;

# Environment configuration
#


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


# Mapping from components to component classes

our %COMP_NET_ID = (
'101.161.159.233' => 'c_0',
'101.161.159.253' => 'c_0',
'101.161.159.17' => 'c_0',
'101.161.159.37' => 'c_0',
'101.239.7.159' => 'c_2',
'101.239.7.169' => 'c_2',
'101.239.7.179' => 'c_1',
'101.239.7.189' => 'c_1',
'101.239.7.199' => 'c_1',
'101.239.7.209' => 'c_1',
'101.239.7.219' => 'c_2',
'101.239.7.229' => 'c_2',
'101.239.7.223' => 'c_3',
'101.239.7.233' => 'c_3',
'101.239.37.159' => 'c_1',
'101.239.37.169' => 'c_1',
'101.239.37.179' => 'c_1',
'101.239.37.189' => 'c_1',
'101.239.37.199' => 'c_2',
'101.239.37.209' => 'c_2',
'101.239.37.219' => 'c_2',
'101.239.37.229' => 'c_2',
'101.239.37.223' => 'c_3',
'101.239.37.233' => 'c_3',
'101.241.175.243' => 'c_0',
'101.241.175.253' => 'c_0',
'101.241.175.7' => 'c_0',
'101.241.175.17' => 'c_0',
'101.137.1.17' => 'c_0',
'101.137.1.27' => 'c_0',
'101.137.1.37' => 'c_0',
'101.137.1.47' => 'c_0',
'ned_sip_c_01' => 'c_0',
'ned_sip_c_02' => 'c_0',
'ned_sip_c_03' => 'c_0',
'ned_sip_c_04' => 'c_0',
'irl_sip_c_23' => 'c_2',
'irl_sip_c_24' => 'c_2',
'irl_sip_c_13' => 'c_1',
'irl_sip_c_14' => 'c_1',
'irl_sip_gwc_32' => 'c_3',
'irl_sip_gwc_33' => 'c_3',
'kon_sip_c_01' => 'c_0',
'kon_sip_c_02' => 'c_0',
'kon_sip_c_03' => 'c_0',
'kon_sip_c_04' => 'c_0',
'lux_sip_c_21' => 'c_2',
'lux_sip_c_22' => 'c_2',
'lux_sip_c_11' => 'c_1',
'lux_sip_c_12' => 'c_1',
'lux_sip_gwc_30' => 'c_3',
'lux_sip_gwc_31' => 'c_3',
'usa_sip_c_01' => 'c_0',
'usa_sip_c_02' => 'c_0',
'usa_sip_c_03' => 'c_0',
'usa_sip_c_04' => 'c_0',
);


# order of classes of components for request messages

our %COMP_ORDER = (
    IN => [qw(c_0 c_1 c_2 c_3)],
    OUT => [qw(c_3 c_2 c_1 c_0)]
    );


use ordererlib;

# association between component classes and SIP message handlers

our %COMP_HANDLERS = (
	"c_0" => \&msg_handler_opensips,
	"c_1" => \&msg_handler_opensips,
	"c_2" => \&msg_handler_opensips,
	"c_3" => \&msg_handler_rs
);

