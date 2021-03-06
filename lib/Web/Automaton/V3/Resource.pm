package Web::Automaton::V3::Resource;

use strict;
use warnings FATAL => qw(all);

use Moo 2;
use namespace::clean;

=head1 METHODS

=head2 is_authorized( $authorization_header )

Default: C<1>

C<$authorization_header> will be the value of the authorization header
sent by the client, if any.

A return value I<other than a true value that looks like a number> will
result in a B<401 Unauthorized> response.  If the return value is true
and does not look like a number, a C<WWW-Authenticate> header will be
created with the returned value.

=cut

sub resource_exists           { 1 }
sub service_available         { 1 }
sub is_authorized             { 1 }
sub forbidden                 { 0 }
sub allow_missing_post        { 0 }
sub malformed_request         { 0 }
sub validate_content_checksum { undef }
sub uri_too_long              { 0 }
sub known_content_type        { 1 }
sub valid_content_headers     { 1 }
sub valid_entity_length       { 1 }
sub options                   { +{} }
sub allowed_methods           { [qw[ GET HEAD ]] }
sub known_methods             { [qw[ GET HEAD POST PUT DELETE TRACE CONNECT OPTIONS ]] }
sub delete_resource           { 0 }
sub delete_completed          { 1 }
sub post_is_create            { 0 }
sub create_path               { undef }
sub base_uri                  { undef }
sub process_post              { 0 }
sub content_types_provided    { [] }
sub content_types_accepted    { [] }
sub charsets_provided         { [] }
sub default_charset           {}
sub languages_provided        { [] }
sub encodings_provided        { { 'identity' => sub { $_[1] } } }
sub variances                 { [] }
sub is_conflict               { 0 }
sub multiple_choices          { 0 }
sub previously_existed        { 0 }
sub moved_permanently         { 0 }
sub moved_temporarily         { 0 }
sub last_modified             { undef }
sub expires                   { undef }
sub generate_etag             { undef }
sub finish_request            {}

1;
