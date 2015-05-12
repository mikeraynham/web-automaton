package Web::Automaton::V3::Decider;

use strict;
use warnings FATAL => qw(all);

use List::Util 1.33 qw(any);
use Moo 2;
use namespace::clean;

sub b13 {
    my ($self, $resource, $request, $response) = @_;
    $resource->resource_exists;
}

sub b12 {
    my ($self, $resource, $request, $response) = @_;
    my $method = $request->method;
    any {$_ eq $method} @{ $resource->known_methods };
}

1;
