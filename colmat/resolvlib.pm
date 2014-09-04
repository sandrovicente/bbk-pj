## resolv pm
package resolvlib;

use strict;
use warnings;

use Exporter;
use Data::Dumper;

use List::Util qw(min);

use vars qw(@ISA @EXPORT);

@ISA = qw(Exporter);
@EXPORT = qw(
    &sel_cid_name_prox
);


sub push_acum_hash {
    my ($key, $r_hash, $r_item) = @_;

    if ($r_hash->{$key}) {
        push($r_hash->{$key}, $r_item);
    } else {
        $r_hash->{$key} = [$r_item];
    }

    return $r_hash;
}


sub sel_cid_name_prox {
    my ($allowed_diff, $r_n_list, $r_s_list)= @_;
        
    my %cid_nres_list = ();
    my %nres_cid_list = ();
    my %cid_min_diff = ();

    # for each call id, pick name resolution with elegible time differences
    foreach my $cid(keys %{$r_s_list}) {
        my $cid_ts = int($r_s_list->{$cid}->[2] / 1000); # timestamp in ms -> s
 
        foreach my $nr(keys %{$r_n_list}) {
            my $diff = abs($cid_ts - $r_n_list->{$nr}->[0]);
            if ( $diff <= $allowed_diff ) {  
                # append to name resolution list each callid found
                $nres_cid_list{$nr}->{$cid} = $diff; 

                $cid_min_diff{$cid} = $cid_min_diff{$cid} ? min($cid_min_diff{$cid}, $diff) : $diff; 
            }
        }
    }
    #print Dumper(\%cid_min_diff);
    
    foreach my $nr(keys %nres_cid_list) {
        my $min_diff = min map { $nres_cid_list{$nr}->{$_} } keys %{$nres_cid_list{$nr}};
        foreach my $cid(keys %{$nres_cid_list{$nr}}) {
            if ($nres_cid_list{$nr}->{$cid} == $min_diff && $cid_min_diff{$cid} == $min_diff) {
                #print "$nr -> $cid is eligible ($min_diff)\n";
            } else {
                delete $nres_cid_list{$nr}->{$cid};
            }
        }
    }
    #print Dumper(\%nres_cid_list);

    return \%nres_cid_list;
}

1;
