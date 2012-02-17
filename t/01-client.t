#!/usr/bin/env perl
use strict;
use warnings;
use Test::More tests => 7;
use Test::Mock::LWP::Dispatch;

BEGIN {
    use_ok( 'Google::Directions::Client' ) || print "Bail out!\n";
}


# Get the sample response
open( my $fh, '<', 'samples/response.json' ) or die( $! );
my $response_content;
while( my $line = readline( $fh ) ){
    $response_content .= $line;
}
close( $fh );

# Set the mock useragent to always respond with the response
$mock_ua->map(qr{.*}, sub {
    my $request = shift;
    my $response = HTTP::Response->new(200, 'OK');
    $response->add_content( $response_content );
    return $response;
});

my $goog = Google::Directions::Client->new();
my %params = (
    origin      => "Theresienstr. 100, 80333 München, Germany",
    destination => "Nymphenburger Straße 31, 80335 München, Germany",
    );

my $response = $goog->directions( %params );
my $first_route = $response->routes->[0];
ok( $first_route, 'has first route' );

my $first_leg = $first_route->legs->[0];
ok( $first_leg, 'has first leg' );
ok( $first_leg->duration == 258, 'duration matches expected' );
ok( $first_leg->distance == 1301, 'distance matches expected' );
ok( $first_leg->start_address eq 'Theresienstraße 100, 80333 Munich, Germany', 
    'start address transformed correctly' );
ok( $first_leg->end_address eq 'Nymphenburger Straße 31, 80335 Munich, Germany',
    'end address transformed correctly' );

