package Web::Automaton::V3::ResourceLazy;

use strict;
use warnings FATAL => qw(all);

use List::Util 1.33 qw(any);
use Moo 2;
use namespace::clean;

has resource => (is => 'ro', required => 1);

my @functions = qw(
    resource_exists
    service_available
    is_authorized
    forbidden
    allow_missing_post
    malformed_request
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
    process_post
    content_types_provided
    content_types_accepted
    charsets_provided
    encodings_provided
    variances
    is_conflict
    multiple_choices
    previously_existed
    moved_permanently
    moved_temporarily
    last_modified
    generate_etag
    finish_request
);

for my $function (@functions) {
    has "_$function" => (is => 'lazy', init_arg => undef);
    eval qq|sub _build__$function { \$_[0]->resource->$function }|;
}

1;