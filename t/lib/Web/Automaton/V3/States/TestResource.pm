package TestResource;

use strict;
use warnings FATAL => qw(all);

use Moo 2;
use namespace::clean;

extends 'Web::Automaton::V3::Resource';

has callback_responses => (is => 'ro');
has callback_args     => (is => 'rw', default => sub {{}});

my @methods = qw(
    resource_exists
    service_available
    is_authorized
    forbidden
    allow_missing_post
    malformed_request
    validate_content_checksum
    uri_too_long
    known_content_type
    valid_content_headers
    valid_entity_length
    options
    allowed_methods
    known_methods
    delete_resource
    delete_completed
    post_is_create
    create_path
    base_uri
    process_post
    content_types_provided
    content_types_accepted
    charsets_provided
    default_charset
    languages_provided
    encodings_provided
    variances
    is_conflict
    multiple_choices
    previously_existed
    moved_permanently
    moved_temporarily
    last_modified
    expires
    generate_etag
    finish_request
);

for my $method (@methods) {
    eval join("\n",
        qq|sub $method {|,
         q|    my $self = shift;|,
        qq|    \$self->callback_args->{$method} = [\@_];|,
        qq|    exists \$self->callback_responses->{$method}|,
        qq|        ? \$self->callback_responses->{$method}|,
        qq|        : \$self->SUPER::$method;|,
         q|}|,
    );
}

1;
