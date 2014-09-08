die("Please enter the arguments 'hostname' 'port' 'queue' 'msq_login' 'msq_passord'") if $#ARGV < 4;

my ($host, $port, $queue, $msq_login, $msq_password) = @ARGV;
 
  use Net::Stomp;
  my $stomp = Net::Stomp->new( { hostname => $host, port => $port } );
  $stomp->connect( { login => $msq_login, passcode => $msq_password } );
  $stomp->subscribe(
      {   destination             => "/queue/$queue",
          'ack'                   => 'client',
          'activemq.prefetchSize' => 1
      }
  );
  while (1) {
    my $frame = $stomp->receive_frame;
    if (!defined $frame) {
      next; # will reconnect automatically
    }
    print $frame->body . "\n"; # do something here
    $stomp->ack( { frame => $frame } );
  }
  $stomp->disconnect;
