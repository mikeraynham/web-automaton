package Web::Automaton::Flow;

use strict;
use warnings FATAL => qw(all);

use HTTP::Response;
use Moo 2;
use namespace::clean;

has decider     => (is => 'ro', required => 1);
has state_chart => (is => 'ro', required => 1);
has resource    => (is => 'ro', required => 1);
has request     => (is => 'ro', required => 1);
has response    => (is => 'lazy');

sub _build_response { HTTP::Response->new }

sub run {
    my $self        = shift;
    my $state_chart = $self->state_chart; 
    my $decider     = $self->decider;
    my $resource    = $self->resource;
    my $request     = $self->request;
    my $response    = $self->response;
    my $state       = $state_chart->initial_state;
    my %transitions = $state_chart->transitions;
    my @trace;
    
    while ($state =~ /^[a-p]/) {
        push @trace, $state;
        $state = $decider->$state($resource, $request, $response)
            ? $transitions{$state}[0]
            : $transitions{$state}[1];
    }

    return $state, \@trace;
}

1;
