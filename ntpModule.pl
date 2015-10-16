#!/usr/bin/perl
use strict;
use warnings;
use Net::NTP;
use Data::Dumper;

my %response = get_ntp_response("0.se.pool.ntp.org",123);

print Dumper \%response;

