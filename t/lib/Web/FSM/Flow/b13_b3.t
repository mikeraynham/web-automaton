#!/usr/bin/env perl

use strict;
use warnings FATAL => qw(all);

{
    package Decider;
    sub new {bless {}}

    sub b13 {1}
    sub b12 {1}
    sub b11 {0}
    sub b10 {1}
    sub b9  {0}
    sub b8  {1}
    sub b7  {0}
    sub b6  {0}
    sub b5  {0}
    sub b4  {0}
    sub b3  {0}
    sub c3  {1}
    sub c4  {1}
    sub d4  {1}
    sub d5  {1}
    sub e5  {1}
    sub e6  {1}
    sub f6  {1}
    sub f7  {1}
    sub g7  {1}
    sub g8  {1}
    sub g9  {0}
    sub g11 {1}
    sub h10 {1}
    sub h11 {1}
    sub h12 {0}
    sub i12 {1}
    sub i13 {0}
    sub k13 {0}
    sub l13 {1}
    sub l14 {1}
    sub l15 {0}
    sub l17 {1}
    sub m16 {1}
    sub m20 {1}
    sub o20 {1}
    sub o18 {1}
}

use Test::More;

use Web::FSM::Flow;

my $decider = Decider->new;
my $flow    = Web::FSM::Flow->new(decider => $decider);
my $code    = $flow->run;

is($code,    300, 'path b13 to o18 returned code 300');

1;
