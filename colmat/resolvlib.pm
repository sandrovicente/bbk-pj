# Resolv
#
# Function for data matching

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

# Find closest match between records based on timestamps
#
# Receives
#   cut off limit for timestaps difference considered for the aproximation
#   map containing references to name resolution records
#   map containing references to sip records
# Returns 
#   a map of name resolution records
#    key=name resolution id
#    value=list sip records with timestamp within the cutoff limit   

sub sel_cid_name_prox {
    my ($allowed_diff, $r_n_list, $r_s_list)= @_;
        
    my %cid_nres_list = ();
    my %nres_cid_list = ();
    my %cid_min_diff = ();

    # for each call id record, calculate  name resolution with elegible time differences
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
    # at this point, 
    #  %cid_min_diff maps 'cid' to minimum timestamp difference among name resolution records
    #  %nres_cid_list contains the 'cid' with minimum timestamp difference for each name resolution record 
 
    # now searches in for each name record the cids with minimum time difference
    # purge the ones that are above the minimum

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

    return \%nres_cid_list;
}

1;
