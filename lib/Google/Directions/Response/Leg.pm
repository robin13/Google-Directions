package Google::Directions::Response::Leg;
use Moose;
use Moose::Util::TypeConstraints;
use Google::Directions::Response::Coordinates;
use Google::Directions::Response::Step;

=head1 NAME

Google::Directions::Response::Leg - An leg of a journey within a route

=head1 SYNOPSIS

    my $first_route = shift( @{ $response->routes } );
    my @legs = @{ $first_route->legs };
    ...

=cut

subtype 'ArrayRefOfSteps',
    as 'ArrayRef',
    where { 
        my $arrayref = $_;
        foreach( @{ $arrayref } ){
            if( not ref( $_ ) or ref( $_ ) ne 'Google::Directions::Response::Step' ){
                return 0;
            }
        }
        return 1;
    },
    message { "Not all elements of the ArrayRef are Google::Direction::Response::Step objects" };

coerce 'ArrayRefOfSteps',
    from 'ArrayRef[HashRef]',
    via { [ map{ Google::Directions::Response::Step->new( $_ ) } @{ $_ } ] };

=head1 ATTRIBUTES

See API documentation L<here|http://code.google.com/apis/maps/documentation/directions/#Legs> for details.

=over 4

=item I<distance> $integer Distance is always in meters

=item I<duration> $integer Duration is always in seconds

=item I<end_address> $string

=item I<end_location> L<Google::Directions::Response::Coordinates>

=item I<start_address> $string

=item I<start_location> L<Google::Directions::Response::Coordinates>

=item I<steps> ArrayRef of L<Google::Directions::Response::Step>

=back

=cut

has 'distance'      => ( is => 'ro', isa => 'ValueFromHashRef',
    coerce      => 1, 
    required    => 1,
    );

has 'duration'      => ( is => 'ro', isa => 'ValueFromHashRef',
    coerce      => 1, 
    required    => 1,
    );
has 'end_address'   => ( is => 'ro', isa => 'Str' );
has 'end_location'  => ( is => 'ro', isa => 'Google::Directions::Response::Coordinates',
    coerce      => 1,
    required    => 1,
    );

has 'start_address'   => ( is => 'ro', isa => 'Str' );
has 'start_location'  => ( is => 'ro', isa => 'Google::Directions::Response::Coordinates',
    coerce      => 1,
    required    => 1,
    );

has 'steps' => ( is => 'ro', isa => 'ArrayRefOfSteps',
    coerce     => 1,
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
