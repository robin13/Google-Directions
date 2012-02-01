package Google::Directions::Client;
use Moose;
use Moose::Util::TypeConstraints;
use MooseX::Params::Validate;
use JSON qw/decode_json/;
use URL::Encode qw/url_encode/;
use LWP::UserAgent;
use YAML;
use Carp;
use Try::Tiny;
use Encode qw/encode_utf8/;
use Google::Directions::Response;

=head1 NAME

Google::Directions - Query directions from the google maps directions API

=head1 VERSION

Version 0.01

=cut

our $VERSION = '0.01';


=head1 SYNOPSIS

Quick summary of what the module does.

Perhaps a little code snippet.

    use Google::Directions;

    my $foo = Google::Directions->new();
    ...

=cut
has 'keep_alive'            => ( is => 'ro', isa => 'Int',  required => 1, default => 0              );
has 'user_agent'            => ( 
    is          => 'ro', 
    isa         => 'LWP::UserAgent',
    writer      => '_set_user_agent',
    predicate   => '_has_user_agent',
    );
has 'cache'                 => ( is => 'ro', isa => 'Cache::FileCache' );


# Create a LWP::UserAgent if necessary
around 'user_agent' => sub {
    my $orig = shift;
    my $self = shift;
    unless( $self->_has_user_agent ){
	if( $self->keep_alive ){
	    carp( "Warning - keep_alive gives unreliable results - partial JSON returned\n" );
	}
	my $ua = LWP::UserAgent->new(
	    'keep_alive' => $self->keep_alive,
	    );
        $self->_set_user_agent( $ua );
    }
    return $self->$orig;
};

=head1 METHODS

=head2 directions 

=cut

sub directions {
    my ( $self, %params ) = validated_hash(
        \@_,
        origin              => { isa => 'Str' },
        destination         => { isa => 'Str' },
        mode                => { isa => 'Str', default => 'driving' },
        waypoints           => { isa => 'ArrayRef[Str]', optional => 1 },
        alternatives        => { isa => 'Bool', optional => 1 },
        avoid               => { isa => 'ArrayRef[Str]', optional => 1 },
        #units               => { isa => 'Str', default => 'metric' }, # value is always in meters, only affects text, so irrelevant for exact computation
        region              => { isa => 'Str', optional => 1 },
        sensor              => { isa => 'Bool', default => 0 },
    );
    my @query_params;
    foreach( qw/origin destination mode units region/ ){
        if( defined( $params{$_} ) ){
            push( @query_params, sprintf( "%s=%s",
                $_, url_encode( $params{$_} ) ) );
        }
    }
    foreach( qw/alternatives sensor/ ){
        if( $params{$_} ){
            push( @query_params, sprintf( "%s=true", $_ ) );
        }else{
            push( @query_params, sprintf( "%s=false", $_ ) );
        }
    }
    foreach my $key( qw/waypoints avoid/ ){
        if( defined( $params{$key} ) ){
            push( @query_params, 
                sprintf( "%s=%s",
                    $key,
                    join( '|', map{ url_encode{$_} } @{ $params{$key} } ),
                    )
                );
        }
    }

    my $url = sprintf( 'https://maps.googleapis.com/maps/api/directions/json?%s',
                join( '&', @query_params ) );

    my $response;
    if( $self->cache ){
        $response = $self->cache->get( $url );
    }

    if( not $response ){
        $response = $self->user_agent->get( $url );
    }

    if( not $response->is_success ){
        croak( "Query failed: " . $response->status_line );
    }
    if( $self->cache ){
        $self->cache->set( $url, $response );
    }

    open( my $fh, '>', '/tmp/google_data.txt' ) or die( $! );
    print $fh Dump( $response->decoded_content );
    close $fh;

    my $data = try{
	return decode_json( encode_utf8( $response->decoded_content ) );
    }catch{
	#open( my $fh, '>', '/tmp/google_response.txt' ) or die( $! );
	#print $fh Dump( $response );
	#close $fh;
	croak( $_ );
    };

    my $google_response = Google::Directions::Response->new( $data );
    return $google_response;
}


=head1 AUTHOR

Robin Clarke, C<< <perl at robinclarke.net> >>

=head1 BUGS

Please report any bugs or feature requests to C<bug-google-directions at rt.cpan.org>, or through
the web interface at L<http://rt.cpan.org/NoAuth/ReportBug.html?Queue=Google-Directions>.  I will be notified, and then you'll
automatically be notified of progress on your bug as I make changes.




=head1 SUPPORT

You can find documentation for this module with the perldoc command.

    perldoc Google::Directions


You can also look for information at:

=over 4

=item * RT: CPAN's request tracker (report bugs here)

L<http://rt.cpan.org/NoAuth/Bugs.html?Dist=Google-Directions>

=item * AnnoCPAN: Annotated CPAN documentation

L<http://annocpan.org/dist/Google-Directions>

=item * CPAN Ratings

L<http://cpanratings.perl.org/d/Google-Directions>

=item * Search CPAN

L<http://search.cpan.org/dist/Google-Directions/>

=back


=head1 ACKNOWLEDGEMENTS


=head1 LICENSE AND COPYRIGHT

Copyright 2012 Robin Clarke.

This program is free software; you can redistribute it and/or modify it
under the terms of either: the GNU General Public License as published
by the Free Software Foundation; or the Artistic License.

See http://dev.perl.org/licenses/ for more information.


=cut

1; # End of Google::Directions
