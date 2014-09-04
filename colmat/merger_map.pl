# Map function - Merging phase
#
# Receives records containing
#  1. Key= <component_id> '#' <correlation_id>
#  2. list of component's events ordered
#
# This map change the shape of these records and generate 
#
#  1. Key= <correlation_id>
#  2. <component_id>
#  3. list of component's events ordered

use strict;
use warnings;

while (<STDIN>) {
    my ($key, $payload, $initiator) = split(/\t\s*/);

    my ($comp_id, $corr_id) = split(/#/, $key);

    print $corr_id . "\t" . $comp_id . "\t" . $payload . "\t" . $initiator;
}
