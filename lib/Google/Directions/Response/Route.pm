package Google::Directions::Response::Route;
use Moose;
use Moose::Util::TypeConstraints;
use Google::Directions::Response::Coordinates;
use Google::Directions::Response::Bounds;
use Google::Directions::Response::Leg;
use Google::Directions::Response::Polyline;

=head1 NAME

Google::Directions::Response::Route - An individual route suggestion

=head1 SYNOPSIS

    my $first_route = shift( @{ $response->routes } );
    ...

=cut

subtype 'StatusCode',
      as 'Str',
      where { $_ =~ m/^(OK|NOT_FOUND|ZERO_RESULTS|MAX_WAYPOINTS_EXCEEDED|INVALID_REQUEST|
          OVER_QUERY_LIMIT|REQUEST_DENIED|UNKNOWN_ERROR)/x };

subtype 'Google::Directions::Response::Coordinates',
    as class_type( 'Google::Directions::Response::Coordinates' );

subtype 'Google::Directions::Response::Bounds',
    as class_type( 'Google::Directions::Response::Bounds' );

subtype 'Google::Directions::Response::Polyline',
    as class_type( 'Google::Directions::Response::Polyline' );


subtype 'ArrayRefOfLegs',
    as 'ArrayRef',
    where { 
        my $arrayref = $_;
        foreach( @{ $arrayref } ){
            if( not ref( $_ ) or ref( $_ ) ne 'Google::Directions::Response::Leg' ){
                return 0;
            }
        }
        return 1;
    },
    message { "Not all elements of the ArrayRef are Google::Direction::Response::Leg objects" };


coerce 'Google::Directions::Response::Bounds',
    from 'HashRef',
    via { Google::Directions::Response::Bounds->new( $_ ) };


coerce 'ArrayRefOfLegs',
    from 'ArrayRef[HashRef]',
    via { [ map{ Google::Directions::Response::Leg->new( $_ ) } @{ $_ } ] };

coerce 'Google::Directions::Response::Polyline',
    from 'HashRef',
    via { Google::Directions::Response::Polyline->new( $_ ) };


=head1 ATTRIBUTES

See API documentation L<here|http://code.google.com/apis/maps/documentation/directions/#Routes> for details.

=over 4

=item I<copyrights> String defining copyright details

=item I<legs> ArrayRef of L<Google::Directions::Response::Leg>

=item I<bounds> L<Google::Directions::Response::Bounds>

=item I<summary> A String summary of the route

=item I<warnings> An ArrayRef of any warnings which occurred

=item I<waypoint_order> ArrayRef

=item I<overview_polyline> L<Google::Directions::Response::Polyline>

=back

=cut

has 'copyrights'        => ( is => 'ro', isa => 'Str',
    required    => 1,
    );

has 'legs'              => ( is => 'ro', isa => 'ArrayRefOfLegs',
    required    => 1,
    coerce      => 1,
    );

has 'bounds'            => ( is => 'ro', isa => 'Google::Directions::Response::Bounds',
    required    => 1, 
    coerce      => 1,
    );

has 'summary'           => ( is => 'ro', isa => 'Str' );
has 'warnings'          => ( is => 'ro', isa => 'ArrayRef' );
has 'waypoint_order'    => ( is => 'ro', isa => 'ArrayRef' );

has 'overview_polyline' => ( is => 'ro', isa => 'Google::Directions::Response::Polyline',
    coerce  => 1,
    );

1;

=head1 AUTHOR

Robin Clarke, C<< <perl at robinclarke.net> >>

=head1 LICENSE AND COPYRIGHT

Copyright 2012 Robin Clarke.

This program is free software; you can redistribute it and/or modify it
under the terms of either: the GNU General Public License as published
by the Free Software Foundation; or the Artistic License.

See http://dev.perl.org/licenses/ for more information.

=cut
