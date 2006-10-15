#!perl

use strict;
use warnings;
use Test::More tests => 3;

BEGIN {
    use_ok('Audio::XMMSClient');
}

ok( exists $Audio::{'XMMSClient::'}, 'Audio::XMMSClient loaded correctly' );
ok( exists $Audio::XMMSClient::{'Result::'}, ' ... and bootstrapped Audio::XMMSCLient::Result' );
