package Google::Directions::Response::Polyline;
use Moose;
use Google::Directions::Types 'ArrayRefOfPoints';
use Google::Directions::Response::Coordinates;
use Moose::Util::TypeConstraints;

=head1 NAME

Google::Directions::Response::Polyline - sequence of points making a polyline

=head1 SYNOPSIS

    my $poly = $route->overview_polyline();
    foreach( @{ $poly->points } ){
        # Do something with the coordinates...
    }

=cut

subtype ArrayRefOfPoints,
    as 'ArrayRef';

coerce ArrayRefOfPoints,
    from 'Str',
    via { _decode_points( $_ ) };


=head1 ATTRIBUTES

=over 4

=item I<points> ArrayRef of L<Google::Directions::Response::Coordinates>

=back

=cut

has 'points' => ( is => 'ro', isa => ArrayRefOfPoints, coerce => 1 );

# Credit goes to  Allen Day in Geo::Google for the original form of these methods
sub _decode_word {
    my $quintets = shift;
    my @quintets = split '', $quintets;
    my $num_chars = scalar(@quintets);
    my $i = 0;
    my $final_number = 0;
    my $ordinal_offset = 63;

    while ($i < $num_chars ) {
        if ( ord($quintets[$i]) < 95 ) { $ordinal_offset = 63; }
        else { 		             $ordinal_offset = 95; }
        my $quintet = ord( $quintets[$i] ) - $ordinal_offset;
        $final_number |= $quintet << ( $i * 5 );
        $i++;
    }
    if ($final_number % 2 > 0) { $final_number *= -1; $final_number --; }
    return $final_number / 2E5;
}

sub _decode_points {
    # Each letter in the polyline is a quintet (five bits in a row).
    # A grouping of quintets that makes up a number we'll use
    # to calculate lat and long will be called a "word".
    my $quintets = shift;
    return undef unless defined $quintets;
    my @quintets = split '', $quintets;
    my @coordinates = ();
    my $word = "";

    # Extract the first lat and long.
    # The initial latitude word is the first five quintets.
    for (my $i=0; $i<=4; $i++) { $word .= $quintets[$i]; }
    my $last_lat = _decode_word($word);
    
    # The initial longitude is the next five quintets.
    $word = "";
    for (my $i=5; $i<10; $i++) { $word .= $quintets[$i]; }
    my $last_lng = _decode_word($word);

    push( @coordinates, Google::Directions::Response::Coordinates->new(
            lat => $last_lat,
            lng => $last_lng,
            ) );

    # The remaining quintets form words that represent 
    # delta coordinates from the last coordinate.  The only
    # way to identify them is that they are at least one
    # character long and end in a ASCII character between
    # ordinal 63 and ordinal 95.  Latitude first, then
    # longitude.
    $word = "";
    my $i = 10;
    my $this_lat = undef;
    my $this_lng = undef;

    while ($i <= $#quintets) {
        $word .= $quintets[$i];
        if ( (length($word) >= 1) && ( ord($quintets[$i]) <= 95 ) ) {
            if( not $this_lat ){
                $this_lat = _decode_word( $word ) + $last_lat;
            }else{
                $this_lng = _decode_word( $word ) + $last_lng;
                push( @coordinates,
                    Google::Directions::Response::Coordinates->new(
                        lat => $this_lat,
                        lng => $this_lng,
                        ) );
                $last_lat = $this_lat;
                $last_lng = $this_lng;
                $this_lat = undef;
                $this_lng = undef;
            }
            $word = "";
        }
        $i++;
    }

    return \@coordinates;
}

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
