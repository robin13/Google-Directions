package Google::Directions::Response::Coordinates;
use Moose;
use MooseX::Aliases;

has 'lat'   => ( is => 'ro', isa => 'Num', required => 1, alias => 'latitude' );
has 'lng'   => ( is => 'ro', isa => 'Num', required => 1, alias => 'longitude' );

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

