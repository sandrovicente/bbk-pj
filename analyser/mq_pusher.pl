use warnings;
use strict;

use Data::Dumper;

use Net::Stomp;

sub begin_pusher {
    my($hostname, $port, $user, $pwd) = @_;

    my $stomp = Net::Stomp->new( { hostname => $hostname, port => $port } );
    $stomp->connect( { login => $user, passcode => $pwd } );
    
    return $stomp;
}

sub pusher {
    my($stomp, $queue, $payload) = @_;
    
    $stomp->send(
    { destination => "/queue/$queue", body => $payload } );
}

sub finish_pusher {
    my($stomp) = @_;

    $stomp->disconnect;
}

die("Please enter the arguments 'hostname' 'port' 'queue' 'msq_login' 'msq_passord'") if $#ARGV < 4;

my ($host, $port, $queue, $msq_login, $msq_password) = @ARGV;

my @names;
my $records = [];

while (<STDIN>) {
	s/^\s*|\s*$//g;
	my @values = split(/,/);
	if (@names == 0) {
		@names = @values;
	} else {
		my %rec;
		for (my $i=0; $i < scalar @names; ++$i) {
			$rec{$names[$i]} = $values[$i]
		}
		push @{$records}, \%rec;	
	}
	
}

my $stomp = &begin_pusher($host, $port, $msq_login, $msq_password);

for my $r(@{$records}) {
    my $body = join ";", map { "$_=$r->{$_}" } keys %{$r};
    &pusher($stomp, $queue, $body);
    print "Pushed " . $body . "\n";
}

&finish_pusher($stomp)
