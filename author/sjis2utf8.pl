#!/usr/bin/env perl

use strict;
use warnings;
use Encode qw//;

local $_ = do { local $/; <> };
$_ = Encode::decode('cp932', $_, Encode::FB_WARN);
print Encode::encode('utf-8', $_, Encode::FB_WARN);
