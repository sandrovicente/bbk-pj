package statlib;

# Package with simple statistical functions
#

use strict;
use warnings;
use Exporter;
use vars qw(@ISA @EXPORT);

use List::Util qw(max min sum);

@ISA = qw(Exporter);	
@EXPORT= qw(
    &stat_count
    &stat_count2
    &time_diff_com
    &ts_to_treadable
    &summarize_list_ev2
);


# Given an LE and a filter for either response codes or requests types, 
# calculates the total number of messages 

sub stat_count {
    my $r_res = {};

    my ($r_sip_msg_list, $r_filter_l) = @_;
    for my $r_sip_msg(@{$r_sip_msg_list}) {
        if (defined $r_sip_msg->{req}) {
            if (!$r_filter_l || !($r_filter_l && $r_sip_msg->{req} ~~ @{$r_filter_l})) 
            { 
                $r_res->{req}->{$r_sip_msg->{req}} += 1;
            }
        } elsif (defined $r_sip_msg->{res}) {
            if (!$r_filter_l || !($r_filter_l && $r_sip_msg->{res} ~~ @{$r_filter_l})) 
            { 
                $r_res->{res}->{$r_sip_msg->{res}} += 1;
        
            }
        }
    }

    return $r_res;
}

# Calculate the number of messages using 'stat_count' and generate a text response line (split by '\t')
#

sub stat_count2 {
    my ($r_sip_msg_list, $r_filter_l) = @_;

    my $r_stat = &stat_count($r_sip_msg_list, $r_filter_l);
    my ($req_pr, $req_ct);
    $req_pr = join "\t", map{ $req_ct+=$r_stat->{req}->{$_}; "$_,$r_stat->{req}->{$_}" } keys %{$r_stat->{req}};
    
    my ($res_pr, $res_ct);
    $res_pr = join "\t", map{ $res_ct+=$r_stat->{res}->{$_}; "$_,$r_stat->{res}->{$_}" } keys %{$r_stat->{res}};
    
    return $req_ct . "\t" . $req_pr . ";\t" . $res_ct . "\t" . $res_pr; 
}

# Convert timestamps in seconds in unix format to human readable ISO like form

sub ts_to_treadable {
    my ($time) = @_;
    
    my ($seconds, $minutes, $hours, $day_of_month, $month, $year,
    $wday, $yday, $isdst) = localtime($time);
    
    return sprintf("%02d:%02d:%02d-%04d/%02d/%02d",
        $hours, $minutes, $seconds, $year+1900, $month+1, $day_of_month);
}


# Calculate summarized LE
#
# receives an ordered LE across all component classes
#
# Generates a single record with the summarized contents for the LE

sub summarize_list_ev2 {
    my ($r_le) = @_;
    
    my $n_req=0;
    my $req_ts=0;
	my $last_ts=0;
    my @req_ts_arr = ();
	my @last_ts_arr = ();
    my ($ts_ini, $ts_end);
    my $ts_name="-";
    
    my @tokens = ();
    
    for my $ev(@{$r_le}) {
        if ($ev->{tsms} && $ev->{cseq} && ($ev->{cseq} =~ 'INVITE' || $ev->{cseq} =~ 'ACK') ) {
            $ts_ini = $ts_ini || $ev->{tsms};
            $ts_end = $ev->{tsms};
        }
        
        if ($ev->{req}) {
            push(@tokens, $ev->{req});
        } 
        elsif ($ev->{res}) {            
            # disregard provisional "trying"
            next if ($ev->{res} =~ '100');
            
            push(@tokens, $ev->{res});
            
            # discard responses from non-INVITE from statistics 
            next if ($ev->{cseq} !~ 'INVITE');
            
            ++$n_req;
            $req_ts += $ev->{req_ts};
			$last_ts += $ev->{last_ts};
            push(@req_ts_arr, $ev->{req_ts});
			push(@last_ts_arr, $ev->{last_ts});
            
        } 
        elsif ($ev->{type} eq 'n') {
            push(@tokens, $ev->{result});
            $ts_name = $ev->{ts_diff};
        }
    }
    
    if ($n_req > 0) {
        # calculate statistics
        my $req_mean = $req_ts / $n_req;
        my $last_mean = $last_ts / $n_req;

		my $req_max = max @req_ts_arr;
        my $req_min = min @req_ts_arr;

		my $last_max = max @last_ts_arr;
		my $last_min = min @last_ts_arr;

        my $req_std = sum (map { ($_ - $req_mean)**2 } @req_ts_arr);
        $req_std = $n_req > 1 ? $req_std / ($n_req-1) : 0; # generate stddev == 0 for single values
        $req_std = sqrt($req_std);
        
		my $last_std = sum(map { ($_ - $last_mean)**2 } @last_ts_arr);
		$last_std = $n_req > 1 ? $last_std / ($n_req-1) : 0;
		$last_std = sqrt($last_std);

		my $count = scalar @req_ts_arr; # should be the same for last
        my $tk = join ";", map{ "$_" } @tokens;
        
        #print "$key\t$ts_ini\t$ts_end\t$ts_name\t$count\t$max\t$req_mean\t$min\t$std\t$ret\n";
        return {ts_ini => $ts_ini, 
			ts_end => $ts_end, 
			ts_name => $ts_name, 
			count => $count, 
			req_max => $req_max, 
			req_mean => $req_mean, 
			req_min => $req_min, 
			req_std => $req_std, 
			last_mean => $last_mean,
			last_max => $last_max,
			last_min => $last_min,
			last_std => $last_std,
			token => $tk};
		
    }
    # returns undef otherwise
}


# Calculate 'last_ts' and 'req_ts' time differences
#
# Given a LE for a SINGLE COMPONENT CLASS
# calculate the timestamp differences between messages 'last_ts' and between requests and responses 'req_ts' 

sub time_diff_com {
    my ($r_le) = @_;

    my $last_req_ts;
    my $last_msg_ts;

    foreach my $ev(@{$r_le}) {
        if ($ev->{req}) {
            $last_req_ts = $ev->{tsms};
        }
        elsif ($ev->{res}) {
            if ($last_req_ts) {
                $ev->{req_ts} = $ev->{tsms} - $last_req_ts;
            }
        }
        if ($last_msg_ts) {
            $ev->{last_ts} = $ev->{tsms} - $last_msg_ts;
        }
        $last_msg_ts = $ev->{tsms};
    }
}

1;
