#!/usr/bin/env perl

use strict;
use warnings FATAL => qw(all);

use Test::More;

use Web::Automaton::StatusCode qw(:codes :mnemonics);

is( ${status_code_500()},
    500,
    'status_code_500 is \500'
);

is( ${HTTP_INTERNAL_SERVER_ERROR()},
    500,
    'HTTP_INTERNAL_SERVER_ERROR \500'
);

done_testing;
