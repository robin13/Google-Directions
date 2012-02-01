package Google::Directions::Response;
use Moose;
use Moose::Util::TypeConstraints;
use Google::Directions::Response::Route;
use Google::Directions::Response::Leg;
use Google::Directions::Response::Step;
use Google::Directions::Response::Coordinates;

subtype 'ArrayRefOfRoutes',
    as 'ArrayRef',
    where { 
        my $arrayref = $_;
        foreach( @{ $arrayref } ){
            if( not ref( $_ ) or ref( $_ ) ne 'Google::Directions::Response::Route' ){
                return 0;
            }
        }
        return 1;
    },
    message { "Not all elements of the ArrayRef are Google::Direction::Response::Route objects" };

coerce 'ArrayRefOfRoutes'
    => from 'ArrayRef[HashRef]'
        => via { [ map{ Google::Directions::Response::Route->new( $_ ) } @{ $_ } ] };


has 'status'        => ( is => 'ro', isa => 'StatusCode', required => 1 );
has 'summary'       => ( is => 'ro', isa => 'Str' );
has 'routes'        => ( is => 'ro', isa => 'ArrayRefOfRoutes', coerce => 1 );

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

