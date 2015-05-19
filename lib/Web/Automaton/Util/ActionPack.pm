package Web::Automaton::Util::ActionPack;

use strict;
use warnings FATAL => qw(all);

use HTTP::Headers::ActionPack;
use HTTP::Headers::ActionPack::ContentNegotiation;

use Moo 2;
use namespace::clean;

has actionpack => (
    is      => 'lazy',
    handles => [qw(
        create
    )],
);

has negotiator => (
    is      => 'lazy',
    handles => [qw(
        choose_media_type
        choose_language
    )],
);

sub _build_actionpack {
    HTTP::Headers::ActionPack->new;
}

sub _build_negotiator {
    $_[0]->actionpack->get_content_negotiator;
}

sub create_media_type {
    my $self = shift;
    $self->actionpack->create(MediaType => shift);
}

1;
