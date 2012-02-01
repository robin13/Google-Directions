package Google::Directions::Response::Step;
use Moose;
use Moose::Util::TypeConstraints;
use Google::Directions::Response::Coordinates;
use Google::Directions::Response::Polyline;

subtype 'TravelMode',
      as 'Str',
      where { $_ =~ m/^(DRIVING|WALKING|BICYCLING)$/ };


subtype 'ValueFromHashRef',
    as 'Num';

coerce 'ValueFromHashRef',
    from 'HashRef',
    via { $_->{value} };


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

has 'html_instructions' => ( is => 'ro', isa => 'Str' );

has 'travel_mode'       => ( is => 'ro', isa => 'TravelMode' );

has 'polyline'          => ( is => 'ro', isa => 'Google::Directions::Response::Polyline',
    coerce  => 1,
    );

1;

=head1 NAME


=head1 DESCRIPTION


=head1 METHODS

=over 4


=back

=head1 COPYRIGHT

Copyright 2011, Robin Clarke, Munich, Germany

=head1 AUTHOR

Robin Clarke <perl@robinclarke.net>

