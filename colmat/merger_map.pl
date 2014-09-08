# Map function - Merging phase
#
# Receives records containing
#  1. Key= <CoC> '#' <Cid>
#  2. list of component  events ordered
#  3. initiator
#
# This map change the shape of these records and generate 
#
#  1. Key= <Cid>
#  2. <CoC>
#  3. list of component's events ordered
#  4. initiator

use strict;
use warnings;

while (<STDIN>) {
    my ($key, $payload, $initiator) = split(/\t\s*/);

    my ($comp_id, $corr_id) = split(/#/, $key);

    print $corr_id . "\t" . $comp_id . "\t" . $payload . "\t" . $initiator;
}
