#!/usr/bin/env perl

use strict;
use warnings FATAL => qw(all);

use Test::More;
use List::Util 1.33 qw(pairs);
use Plack::Request;
use Plack::Response;
use Web::Automaton::V3::Decider;
use Web::Automaton::V3::Resource;

my $resource    = Web::Automaton::V3::Resource->new;
my $request     = Plack::Request->new({});
my $response    = Plack::Response->new;
my $decider     = Web::Automaton::V3::Decider->new;
my $halt        = halt();

my @tests = (
    b13 => {
        resource_exists => [
            1     => 'resource exists',
            0     => 'resource does not exist',
            $halt => 'resource halted',
        ],
    },
);

subtest b13 => sub {
    

};

sub halt {
    bless {}, 'halt';
}
