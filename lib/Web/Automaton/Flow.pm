package Web::Automaton::Flow;

use strict;
use warnings FATAL => qw(all);

use B ();
use HTTP::Response;
use Web::Automaton::StatusCode qw(is_status_code);

use Moo 2;
use namespace::clean;

has decider     => (is => 'ro', required => 1);
has resource    => (is => 'ro', required => 1);
has request     => (is => 'ro', required => 1);
has response    => (is => 'lazy');

sub _build_response { HTTP::Response->new }

sub _state_name { B::svref_2object( shift )->GV->NAME }

sub run {
    my $self        = shift;
    my $decider     = $self->decider;
    my $resource    = $self->resource;
    my $request     = $self->request;
    my $response    = $self->response;
    my $state       = $decider->initial_state;
    my @trace;
    my $status_code;
    my $prev_state;
    
    for (1..100) {
        my $state_name = _state_name($state);
        $prev_state && $state == $prev_state
            && die "$state_name is calling itself";
        push @trace, $state_name;
        print "Transitioning to $state_name\n";
        
        $prev_state = $state;
        $state = $state->($resource, $request, $response);

        last if is_status_code($state);
    }

    return $$state, \@trace;
}

1;
