use strict;
use warnings;
use Test::More;
use Data::Dumper;

BEGIN {
    use_ok('resolvlib', qw(sel_cid_name_prox ) );
}

my %name_list = (
          n1 => [
            '1406192433',
            '1406192436',
            '3',
            'someone@yahoo.com',
            'OK'
          ],
          n2 => [
            '1406192436',
            '1406192436',
            '0',
            'someoneelse@yahoo.com',
            'OK'
          ]
          
    );

my %sip_list = (
    callid_1 => ['c_0',
        'callid_1',
        '1406192433999',
        'destination@yahoo.com',
        'BLOB'],
    callid_2 => ['c_0',
        'callid_2',
        '1406192431999',
        'destination@yahoo.com',
        'BLOB'],
    callid_3 => ['c_0',
        'callid_3',
        '1406192436999',
        'destination@yahoo.com',
        'BLOB'],
    callid_4 => ['c_0',
        'callid_4',
        '1406192434000',
        'destination@yahoo.com',
        'BLOB']
 );
 
my $r_result = &sel_cid_name_prox(2, \%name_list, \%sip_list);
print Dumper($r_result);
    
ok(eq_array($r_result, {
    n1 => { callid_1 => 0 },
	n2 => { callid_3 => 0 },
    }), 'matching name distances per callid' ); 


%name_list = (
          n1 => [
            '1406192433',
            '1406192436',
            '3',
            'someone@yahoo.com',
            'OK'
          ],
          n2 => [
            '1406192436',
            '1406192436',
            '0',
            'someoneelse@yahoo.com',
            'OK'
          ]
          
    );

%sip_list = (
    callid_1 => ['c_0',
        'callid_1',
        '1406192433999',
        'destination@yahoo.com',
        'BLOB'],
    callid_2 => ['c_0',
        'callid_2',
        '1406192431999',
        'destination@yahoo.com',
        'BLOB'],
    callid_3 => ['c_0',
        'callid_3',
        '1406192437999',
        'destination@yahoo.com',
        'BLOB'],
    callid_4 => ['c_0',
        'callid_4',
        '1406192433000',
        'destination@yahoo.com',
        'BLOB']
 );
 
my $r_result = &sel_cid_name_prox(2, \%name_list, \%sip_list);
print Dumper($r_result);

done_testing();
