package Web::Automaton::V3::States;

use strict;
use warnings FATAL => qw(all);

use Data::Dumper;

use Digest::MD5 qw(md5_hex);
use List::Util 1.33 qw(any);
use Scalar::Util qw(looks_like_number);
use Web::Automaton::StatusCode qw(:mnemonics);

use Moo 2;
use namespace::clean;

with 'Web::Automaton::Runner';

# [*] --> B13
sub initial_state {
    'b13';
}

# B13 : Available?
# B13 --> B12 : true
# B13 --> 503_Service_Unavailable : false
sub b13 {
    my ($self, $resource, $request, $response) = @_;

    $resource->service_available
        ? 'b12'
        : HTTP_SERVICE_UNAVAILABLE;
}

# B12 : Known method?
# B12 --> B11 : true
# B12 --> 501_Not_Implemented : false
sub b12 {
    my ($self, $resource, $request, $response) = @_;
    my $method = $request->method;

    (any {$_ eq $method} @{ $resource->known_methods })
        ? 'b11'
        : HTTP_NOT_IMPLEMENTED;
}

# B11 : URI too long?
# B11 --> 424_Request_URI_Too_Long : true
# B11 --> B10 : false
sub b11 {
    my ($self, $resource, $request, $response) = @_;

    $resource->uri_too_long
        ? HTTP_REQUEST_URI_TOO_LARGE
        : 'b10';
}

# B10 : Is method allowed?
# B10 --> 405_Method_Not_Allowed : true
# B10 --> B9 : false
sub b10 {
    my ($self, $resource, $request, $response) = @_;
    my $method = $request->method;
    my @allowed_methods = @{$resource->allowed_methods};

    return 'b9a' if any {$_ eq $method} @allowed_methods;

    $response->headers('Allow' => join ', ' => @allowed_methods);
    return HTTP_METHOD_NOT_ALLOWED;
}

# B9 : Malformed?
# B9 --> 400_Bad_Request : true
# B9 --> B8 : false
sub b9a {
    my ($self, $resource, $request, $response) = @_;

    defined $request->header('Content-MD5')
        ? 'b9b'
        : 'b9e';
}

sub b9b {
    my ($self, $resource, $request, $response) = @_;

    defined $resource->validate_content_checksum
        ? 'b9c'
        : 'b9d';
}

sub b9c {
    my ($self, $resource, $request, $response) = @_;

    $resource->validate_content_checksum
        ? 'b8'
        : HTTP_BAD_REQUEST;
}

sub b9d {
    my ($self, $resource, $request, $response) = @_;

    my $header_md5  = $request->header('Content-MD5');
    my $content_md5 = md5_hex($request->content);

    $content_md5 eq $header_md5
        ? 'b8'
        : HTTP_BAD_REQUEST;
}

sub b9e {
    my ($self, $resource, $request, $response) = @_;

    $resource->malformed_request
        ? HTTP_BAD_REQUEST
        : 'b8';
}

# B8 : Authorized?
# B8 --> 401_Unauthorized
# B8 --> B7
sub b8 {
    my ($self, $resource, $request, $response) = @_;
    my $authenticated = $resource->is_authorized(
        $request->header('Authorization')
    );

    return 'b7' if $authenticated && looks_like_number($authenticated);

    $authenticated
        && $response->header('WWW-Authenticate' => $authenticated);

    HTTP_UNAUTHORIZED;
}

# B7 : Forbidden?
# B7 --> 403_Forbidden : true
# B7 --> B6 : false
sub b7 {
    my ($self, $resource, $request, $response) = @_;

    $resource->forbidden
        ? HTTP_FORBIDDEN
        : 'b6';
}

# B6 : Unknown or unsupported Content-* header?
# B6 --> 501_Not_Implemented : true
# B6 --> B5 : false
sub b6 {
    my ($self, $resource, $request, $response) = @_;

    my $headers = $request->headers->clone;
    my @remove  = grep { !/^content-/ } $headers->header_field_names;

    $headers->remove_content_headers(@remove);

    $resource->valid_content_headers($headers)
        ? HTTP_NOT_IMPLEMENTED
        : 'b5';
}

# B5 : Unknown Content-Type?
# B5 --> 415_Unsupported_Method : true
# B5 --> B4 : false

sub b5 {
    my ($self, $resource, $request, $response) = @_;

}

# B4 : Request entity too large?
# B4 --> 413_Request_Entity_Too_Large : true
# B4 --> B3 : false

sub b4 {
    my ($self, $resource, $request, $response) = @_;

}

# B3 : OPTIONS?
# B3 --> 200_OK : true
# B3 --> C3 : false

sub b3 {
    my ($self, $resource, $request, $response) = @_;

}

# C3 : Accept exists?
# C3 --> C4 : true
# C3 --> D4 : false

sub  {
    my ($self, $resource, $request, $response) = @_;

}

# C4 : Acceptable media type available?
# C4 --> D4 : true
# C4 --> 406_Not_Acceptable : false

sub  {
    my ($self, $resource, $request, $response) = @_;

}

# D4 : Accept-Language exists?
# D4 --> D5 : true
# D4 --> 406_Not_Acceptable : false

sub  {
    my ($self, $resource, $request, $response) = @_;

}

# E5 : Accept-Charset exists?
# E5 --> E6 : true
# E5 --> F6 : false

sub  {
    my ($self, $resource, $request, $response) = @_;

}

# E6 : Acceptable charset available?
# E6 --> F6 : true
# E6 --> 406_Not_Acceptable : false

sub  {
    my ($self, $resource, $request, $response) = @_;

}

1;

__END__

perl -ne 'm/( : | --> )/ && s/^# // && print' lib/Web/Automaton/V3/States.pm \
    | /usr/bin/java -jar /usr/local/bin/plantuml.jar -pipe \
    > diagram/v3.png && open diagram/v3.png
