package ordererlib;

#
# Logic for processing SIP messages: Parsing and Ordering
#


use strict;
use warnings;
use Exporter;
use vars qw(@ISA @EXPORT);

@ISA = qw(Exporter);	
@EXPORT= qw(
	&msg_handler_opensips 
	&msg_handler_rs 
	&parse_sip
	&find_origin
    &order_sipn
    &order_merge_sipn
    &find_calc_tsms
);


# handler to extract SIP message from OpenSIPs log format
#
# receives a raw log line (OpenSIPs)
# returns text referring to SIP contents

sub msg_handler_opensips {
	my $msg = ${$_[0]}; # Message is passed as _reference_
	if ($msg =~ m/.*MESSAGE RECEIVED\([^\)]+\):#012(.*)#012$/) {
		return $1;
	}
	return 0;
}


# handler to extract SIP message from reSIPprocate log format 
#
# receives a raw log line (reSIPprocate)
# returns text referring to the SIP contents

sub msg_handler_rs {
	my $msg = ${$_[0]}; # Message is passed as _reference_
	if ($msg =~ m/.*SIP \w+ \'([^\']+)\#015\ \'/) {
		return $1;
	}
	return 0;
}


# Obtain contents from formatted SIP uri
#
# receives a string containing "To:" or "From:" SIP header contents
#   e.g. "Tlzqf TU0"<sip:tlzqf-tu0@mzoduftu_fbntq__1.ponjdsptpgu.dpn>;tag=70efe8f224;epid=D51E4E9048
# returns the part refering to the SIP URI
#   e.g <sip:tlzqf-tu0@mzoduftu_fbntq__1.ponjdsptpgu.dpn>

sub parse_sip_uri {
    my ($sip_field) = @_;

    if ($sip_field =~ m/([^\<\s:;]+@[^\>\s:;]+)/) {
        return $1;
    }
}


# parse text from SIP message, converting it into a hash structure 
#
# receives 
#   the text contaning the sip message; and
#   the component class (CoC)
#
# returns a reference to the SIP message codified in a hash structure

sub parse_sip {
	my($sipmsg, $component) = @_;
	my %tuple;

	# find SIP request pattern
	if ($sipmsg =~ m/^(\w+) [^\ ]+ SIP\/2\.0/) {
		$tuple{'req'} = $1;
	} 
    # otherwise find SIP response pattern
	elsif ($sipmsg =~ m/^SIP\/2\.0 (\d+) /) {
		$tuple{'res'} = $1;
	} 

    # find cseq: field
	if ($sipmsg =~ m/cseq: (\d+) (\w+)/i) {
		$tuple{'cseq'} = "$1\t$2";
        $tuple{'cseq_n'} = $1;
	}
	
	if ($sipmsg =~ m/TO: ([^#]+)/i) {
		$tuple{'to'} = $1;
        $tuple{'to_uri'} = parse_sip_uri($1);
    }

	if ($sipmsg =~ m/from: ([^#]+)/i) {
		$tuple{'from'} = $1;
        $tuple{'from_uri'} = parse_sip_uri($1);
	}

    # find MULTIPLE via: fields
	while ($sipmsg =~ m/VIA: \S+ ([^#;]+)/ig) {
		push(@{$tuple{'via_l'}}, $1);
	}
    $tuple{'via'} = $tuple{'via_l'}[0]; # original via is required
	
    # find callid
	if ($sipmsg =~ m/call-id: ([^#;]+)/i) {
		$tuple{'callid'} = $1;
	}

    if ($component) {
        $tuple{component} = $component;
    }

	return \%tuple;
}


# Find component that originated the SIP message
#
# receives 
#  a reference to a SIP hash structure
#  a reference to a mapping from components to component class
# returns a reference to a SIP hash structure containing field 'origin' with the component class that originated the message

sub find_origin() {
	my ($r_msgtuple, $r_clas) = @_; # two hash references

	my $via = $r_msgtuple->{'via'};
	my $clas_name = $r_clas->{$via};
	$r_msgtuple->{'origin'} = defined $clas_name ? $clas_name : 0;

	return $r_msgtuple
}

###############
# SIP Ordering tree
# 
# determines the precedence between SIP events 

our %SIP_ORDER = (
    req => {
        INVITE => {req => {0 => -1},res => {0 => -1}},
        CANCEL => {
            req => {INVITE => 1, ACK => -1, BYE => 0, 0 => 0},
            res => {1 => 0, 2 => -1, 4 => -1, 0 => 0 }
        },
        ACK => {
            req => {INVITE => 1, CANCEL => 1, BYE => -1, 0 => 0},
            res => {1 => 1, 2 => 1, 0 => 0}
        },
        BYE => {
            req => {INVITE => 1, CANCEL => 0, ACK => 1, 0 => 1},
            res => {1 => -1, 2 => -1 , 0 => 0}
        }
    },
    res => {
        1 => {
            req => {INVITE => 1, CANCEL => 0, 0 => -1},
            res => {1 => 0, 0 => -1}
        },
        2 => {
            req => {INVITE => 1, CANCEL => 1, ACK => -1, BYE => 1, 0 => 0},
            res => {1 => 1, 0 => 0}
        },
        4 => {
            req => {INVITE => 1, CANCEL => 1, 0 => 1},
            res => {2 => 1, 0 => 1}
        },
        5 => {
            req => {INVITE => 1, 0 => 0},
            res => {0 => 0}
        },
        6 => {
            req => {
                INVITE => 1, 0 => 0
            },
            res => { 0 => 0 }
        },
    }
);

###############


# Helper function
# 
# receives
#  reference to SIP message hash structure
#  position in the ordering tree
#
# returns
#  a new position in the ordering tree corresponding to the given SIP message  

sub find_order_item {
    my ($src, $pos) = @_;

    my $p;
    if ($src->{req}) {
        $p = $pos->{req}->{$src->{req}} ;

        if (!defined $p) { 
            $p = $pos->{req}->{0}; 
        }
    } elsif ($src->{res}) {
        $p = $pos->{res}->{$src->{res}};
        
        if (!$p) {
            my $res_key = substr $src->{res}, 0, 1;
            $p = $pos->{res}->{$res_key};

            if (!defined $p) { 
                $p = $pos->{req}->{0}; 
            }
        }
    }
    
    return $p;
}


# SIP message ordering
#
# receives a reference to a list of SIP message structures
# sort the SIP messages using the local component timestamp
#  and the structure of the SIP protocol
# returns an ordered list of SIP messages (component level) 

sub order_sipn() {
    my $ref_sipn = $_[0]; # array of hash ref;

    my @sorted = sort {

        if ($a->{tsms} < $b->{tsms}) {
            return -1;
        } elsif ($a->{tsms} > $b->{tsms}) {
            return 1;
        } else {
            my $pos = &find_order_item($a, \%SIP_ORDER);
            if (defined $pos) {
                my $p = &find_order_item($b, $pos);

                return $p;
            }
            
            return 0;
        }
    } @{$ref_sipn};

	my $prev_label;
	my $prev_ref;
	my $ref;
	foreach $ref(@sorted) {
		my $current = $ref->{req} || $ref->{res};
		$ref->{_ord} = ($prev_label && $prev_label eq $current ? $prev_ref->{_ord} + 1 : 0);
		$prev_label = $current;
		$prev_ref = $ref;
	}

    return \@sorted;
}


# helper matcher
#
# given a condition, pre-action, loop-action and final action:
# evalutes pre-action if condition is true, then keeps checking conditon and evaluating loop action. 
#  at the end, if condition has been true at least once, evaluates final action. 

sub while_matcher() {
	my ($r_cond, $r_pre, $r_loop, $r_end) = @_;

    if (&{$r_cond}) {
        &{$r_pre};
        while (&{$r_cond}) {
            &{$r_loop};
        }
        &{$r_end};
        return 1;
    }
    return 0;
}


# Merge two ordered lists of SIP events (per component)
#
# receives
#  reference to acummulating list
#  reference to source list
#
# returns acummulating list with merged events from the source list in causal order

sub order_merge_sipn {
    my($r_list1, $r_list2) = @_; # list1 always is request originator, list2 is response originator
    my @ret = ();

    my $n1 = @{$r_list1};
    my $n2 = @{$r_list2};
    my $i = 0, my $j = 0;

    while ($i < $n1 && $j < $n2) {
        # same req/req -> first req1's then req2
        if (&while_matcher(
             sub{ return ($i < $n1 && 
                          defined $r_list1->[$i]->{req} && 
                          defined $r_list2->[$j]->{req} &&
                          $r_list1->[$i]->{req} eq $r_list2->[$j]->{req} &&
                          $r_list1->[$i]->{_ord} eq $r_list2->[$j]->{_ord}
					); },
             sub{},
             sub{ push @ret, $r_list1->[$i]; ++$i; },
             sub{ push @ret, $r_list2->[$j]; ++$j; } 
            )) 
        { #noop --> matcher did all job
          #  print "---> $i $j req/req match\n";
        } 
        # same res/res -> first res2, then all res1's
        elsif (&while_matcher(
             sub{ return ($j < $n2 && 
                          defined $r_list1->[$i]->{res} && 
                          defined $r_list2->[$j]->{res} &&
                          $r_list1->[$i]->{res} eq $r_list2->[$j]->{res} &&
                          $r_list1->[$i]->{_ord} eq $r_list2->[$j]->{_ord}
				); },
             sub{ push @ret, $r_list2->[$j]; },
             sub{ push @ret, $r_list1->[$i]; ++$i; },
             sub{ ++$j; } 
            ))
        { #noop --> matcher did all job
          #  print "---> $i $j res/res match\n";
        } 
        elsif ( defined $r_list1->[$i]->{req} && defined $r_list2->[$j]->{req} )
        { # req / req different -> req1 wins
            push @ret, $r_list1->[$i]; ++$i;
            #  print "---> $i $j req/req mismatch\n";

        }
        elsif ( defined $r_list1->[$i]->{req} && defined $r_list2->[$j]->{res} )
        { # req / res -> req wins
            push @ret, $r_list1->[$i]; ++$i;
            #  print "---> $i $j req/res \n";
        }
        elsif ( defined $r_list1->[$i]->{res} && defined $r_list2->[$j]->{req} )
        { # res / req -> res wins
            push @ret, $r_list1->[$i]; ++$i;
            #  print "---> $i $j res/req \n";
        }
        elsif ( defined $r_list1->[$i]->{res} && defined $r_list2->[$j]->{res} )
        { # res / res different -> res2 wins
            push @ret, $r_list2->[$j]; ++$j;
            #  print "---> $i $j res/res mismatch\n";
        }
    }
    # append remaining items to ret
    if ($i < $n1) {
        push @ret, @{$r_list1}[$i..$n1-1];
    } elsif ($j < $n2) {
        push @ret, @{$r_list2}[$j..$n2-1];
    }

    return \@ret;
}


use Time::Local;

# Calculate timestamp in milliseconds
#
# receives a timestamp in ISO text format
# returns timestamp as UNIX epoch in milliseconds

sub find_calc_tsms {
    my ($str) = @_;

    my @t = ($str =~ m!(\d{4})\-(\d{2})\-(\d{2})T(\d{2}):(\d{2}):(\d{2})\.(\d{3})!);
    --$t[1]; # months from 0-11
    
    my $ts = timegm @t[5,4,3,2,1,0];
    $ts = $ts*1000 + $t[6];
}

1;
