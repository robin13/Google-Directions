#!/usr/bin/env perl
use strict;
use warnings;

use Test::More;
use Test::Mock::LWP::Dispatch;
use Google::Directions::Client;

open( my $fh, '<', 'samples/response.json' ) or die( $! );
my $response_content;
while( my $line = readline( $fh ) ){
    $response_content .= $line;
}
close( $fh );

$mock_ua->map(qr{.*}, sub {
    my $request = shift;
    my $response = HTTP::Response->new(200, 'OK');
    $response->add_content( $response_content );
    return $response;
});

my $goog = Google::Directions::Client->new();
my %params = (
    origin => "Theresienstr. 100, 80333 München, Germany",
    destination => "Nymphenburger Straße 31, 80335 München, Germany",
    );

my $response = $goog->directions( %params );

