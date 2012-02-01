package Google::Directions::Response::Leg;
use Moose;
use Moose::Util::TypeConstraints;
use Google::Directions::Response::Coordinates;
use Google::Directions::Response::Step;

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

=head1 NAME


=head1 DESCRIPTION


=head1 METHODS

=over 4


=back

=head1 COPYRIGHT

Copyright 2011, Robin Clarke, Munich, Germany

=head1 AUTHOR

Robin Clarke <perl@robinclarke.net>

