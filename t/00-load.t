#!perl -T

use Test::More tests => 1;

BEGIN {
    use_ok( 'Google::Directions' ) || print "Bail out!\n";
}

diag( "Testing Google::Directions $Google::Directions::VERSION, Perl $], $^X" );
