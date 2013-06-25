package MapReduceUI;
use Mojo::Base 'Mojolicious';
use Mojo::JSON;
use Redis::hiredis;
use utf8;

# This method will run once at server start
sub startup {
    my ($self) = @_;
    
    $self->log->level('debug');

    # Router
    my $r = $self->routes;

    # Normal route to controller
    $r->get('/' => sub { shift->render_static('app/index.html') });
    
    my $json = Mojo::JSON->new;

    my $redis = Redis::hiredis->new(utf8 => 0);
    $redis->connect('127.0.0.1', 6379);
    $redis->select(9);
    
    my $send_mapreduce_info = sub {
        my ($self) = @_;
        
        my $keys = $redis->keys('mr-*');
        
        my %job_ids = map { $_ => 1 } map {
            $_ =~ m{ mr - ( [^-]+ - [^-]+ - [^-]+ - [^-]+ ) }xms
        } @$keys;
        
        my %input_counts   = map { $_ => $redis->get("mr-$_-input-count")   } keys %job_ids;
        my %input_totals   = map { $_ => $redis->get("mr-$_-input-total")   } keys %job_ids;
        my %mapped_counts  = map { $_ => $redis->get("mr-$_-mapped-count")  } keys %job_ids;
        my %reduced_counts = map { $_ => $redis->get("mr-$_-reduced-count") } keys %job_ids;
        my %result_counts  = map { $_ => $redis->get("mr-$_-result-count")  } keys %job_ids;
       
        my @response = map {{
            id => $_,
            
            input_count   => $input_counts{$_},
            input_total   => $input_totals{$_},
            mapped_count  => $mapped_counts{$_},
            reduced_count => $reduced_counts{$_},
            result_count  => $result_counts{$_},
            
            input_percent   => sprintf( '%d', 100 * $input_counts{$_}   / $input_totals{$_} ),
            mapped_percent  => sprintf( '%d', 100 * $mapped_counts{$_}  / $input_totals{$_} ),
            reduced_percent => sprintf( '%d', 100 * $reduced_counts{$_} / $input_totals{$_} ),
            result_percent  => sprintf( '%d', 100 * $result_counts{$_}  / $input_totals{$_} ),
            
            expires => $redis->ttl("mr-$_-result-count") . ' seconds',
        }} keys %job_ids;
        
        my $bytes = $json->encode(\@response);
        
        $self->send($bytes);
    };

    
    $r->websocket('/ws' => sub {
        my ($self, $msg) = @_;

        # Start recurring timer
        my $id = Mojo::IOLoop->recurring( 0.1 => sub { $self->$send_mapreduce_info } );
        
        # Stop recurring timer
        $self->on(finish => sub { Mojo::IOLoop->remove($id) });

        
        $self->$send_mapreduce_info();
    });
}

1;
