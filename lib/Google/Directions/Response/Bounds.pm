package Google::Directions::Response::Bounds;
use Moose;
use Moose::Util::TypeConstraints;
use Google::Directions::Response::Coordinates;

coerce 'Google::Directions::Response::Coordinates',
    from 'HashRef',
    via { Google::Directions::Response::Coordinates->new( $_ ) };


has 'northeast'     => ( is => 'ro', isa => 'Google::Directions::Response::Coordinates',
    required => 1, coerce => 1 );
has 'southwest'     => ( is => 'ro', isa => 'Google::Directions::Response::Coordinates',
    required => 1, coerce => 1 );

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

