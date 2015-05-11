package Web::FSM::Flow;

use strict;
use warnings FATAL => qw(all);

use Plack::Response;
use Moo 2;
use namespace::clean;

has decider     => (is => 'ro', required => 1);
has state_chart => (is => 'ro', required => 1);
has resource    => (is => 'ro', required => 1);
has request     => (is => 'ro', required => 1);
has response    => (is => 'lazy');

sub _build_response { Plack::Response->new }

sub run {
    my $self        = shift;
    my $state_chart = $self->state_chart; 
    my $decider     = $self->decider;
    my $resource    = $self->resource;
    my $request     = $self->request;
    my $response    = $self->response;
    my $state       = $state_chart->initial_state;
    my %transitions = $state_chart->transitions;
    
    while ($state =~ /^[a-p]/) {
        $state = $decider->$state($resource, $request, $response)
            ? $transitions{$state}[0]
            : $transitions{$state}[1];
    }

    return $state;
}

1;
