package Web::Automaton::Runner;

use strict;
use warnings FATAL => qw(all);

use HTTP::Response;
use Web::Automaton::StatusCode qw(is_status_code);

use Moo::Role 2;
use namespace::clean;

has request  => (is => 'ro', required => 1);
has response => (is => 'ro', required => 1);
has resource => (is => 'ro', required => 1);

sub run {
    my $self     = shift;
    my $resource = $self->resource;
    my $request  = $self->request;
    my $response = $self->response;
    my $state    = $self->initial_state;
    my @trace;
    my $prev_state;
    
    while ($state =~ /^[a-z]/) {
        $prev_state && $state eq $prev_state
            && die "$state is calling itself";
        push @trace, $state;
        
        $prev_state = $state;
        $state = $self->$state($resource, $request, $response);

        print "STATE: $state\n";

        last if is_status_code($state);
    }

    return $$state, \@trace;
}

1;
