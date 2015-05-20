package Web::Automaton::V3::States;

use strict;
use warnings FATAL => qw(all);

use Digest::MD5 qw(md5_hex);
use List::Util 1.33 qw(any pairkeys);
use Scalar::Util qw(looks_like_number);
use Web::Automaton::StatusCode qw(:mnemonics);

use Moo 2;
use namespace::clean;

with 'Web::Automaton::Runner';

# [*] --> B13
sub initial_state {
    'b13';
}

# B13 : service_available?
# B13 --> B12 : true
# B13 --> 503_Service_Unavailable : false
sub b13 {
    my ($self, $resource, $request, $response) = @_;

    $resource->service_available
        ? 'b12'
        : HTTP_SERVICE_UNAVAILABLE;
}

# B12 : known_methods?
# B12 --> B11 : true
# B12 --> 501_Not_Implemented : false
sub b12 {
    my ($self, $resource, $request, $response) = @_;
    my $method = $request->method;

    (any {$_ eq $method} @{ $resource->known_methods })
        ? 'b11'
        : HTTP_NOT_IMPLEMENTED;
}

# B11 : uri_too_long?
# B11 --> 424_Request_URI_Too_Long : true
# B11 --> B10 : false
sub b11 {
    my ($self, $resource, $request, $response) = @_;

    $resource->uri_too_long
        ? HTTP_REQUEST_URI_TOO_LARGE
        : 'b10';
}

# B10 : [request method in] allowed_methods?
# B10 --> B9 : true
# B10 --> 405_Method_Not_Allowed : false
sub b10 {
    my ($self, $resource, $request, $response) = @_;
    my $method = $request->method;
    my @allowed_methods = @{$resource->allowed_methods};

    return 'b9a' if any {$_ eq $method} @allowed_methods;

    $response->headers('Allow' => join ', ' => @allowed_methods);
    return HTTP_METHOD_NOT_ALLOWED;
}

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

# B9 : malformed_request?
# B9 --> 400_Bad_Request : true
# B9 --> B8 : false
sub b9e {
    my ($self, $resource, $request, $response) = @_;

    $resource->malformed_request
        ? HTTP_BAD_REQUEST
        : 'b8';
}

# B8 : is_authorized?
# B8 --> B7 : true
# B8 --> 401_Unauthorized : false
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

# B7 : forbidden?
# B7 --> 403_Forbidden : true
# B7 --> B6 : false
sub b7 {
    my ($self, $resource, $request, $response) = @_;

    $resource->forbidden
        ? HTTP_FORBIDDEN
        : 'b6';
}

# B6 : valid_content_headers?
# B6 --> B5 : true
# B6 --> 501_Not_Implemented : false
sub b6 {
    my ($self, $resource, $request, $response) = @_;

    my $headers = $request->headers->clone;
    
    $headers->remove_header($_)
        for grep { !/^content-/i } $request->headers->header_field_names;

    $resource->valid_content_headers($headers)
        ? 'b5'
        : HTTP_NOT_IMPLEMENTED;
}

# B5 : known_content_type?
# B5 --> B4 : true
# B5 --> 415_Unsupported_Media_Type : false
sub b5 {
    my ($self, $resource, $request, $response) = @_;

    $resource->known_content_type($request->content_type)
        ? 'b4'
        : HTTP_UNSUPPORTED_MEDIA_TYPE;
}

# B4 : Request entity too large?
# B4 --> 413_Request_Entity_Too_Large : true
# B4 --> B3 : false
sub b4 {
    my ($self, $resource, $request, $response) = @_;

    $resource->valid_entity_length($request->content_length)
        ? 'b3'
        : HTTP_REQUEST_ENTITY_TOO_LARGE;
}

# B3 : OPTIONS?
# B3 --> 200_OK : true
# B3 --> C3 : false
sub b3 {
    my ($self, $resource, $request, $response) = @_;

    return 'c3' unless $request->method eq 'OPTIONS';

    $response->headers( $resource->options );

    return HTTP_OK;
}

# C3 : Accept exists?
# C3 --> C4 : true
# C3 --> D4 : false
sub c3 {
    my ($self, $resource, $request, $response) = @_;

    # If an Accept header has been provided, let C4 determine if the
    # resource can supply to requested media type.
    return 'c4' if defined $request->header('Accept');

    # If an Accept header has not been provided, default to the first
    # content type specified by content_types_provided.
    my @types = pairkeys @{$resource->content_types_provided};

    die "content_types_provided() must return a list of content types\n"
        unless @types;

    $self->metadata->add(
        'Content-Type' => $self->actionpack->create_media_type($types[0])
    );

    return 'd4';
}

# C4 : Acceptable media type available?
# C4 --> D4 : true
# C4 --> 406_Not_Acceptable : false
sub c4 {
    my ($self, $resource, $request, $response) = @_;

    my @types = pairkeys @{ $resource->content_types_provided };

    my $media_type = $self->actionpack->choose_media_type(
        \@types,
        $request->header('Accept')
    );

    if ($media_type) {
        $self->metadata->add('Content-Type' => $media_type);
        return 'd4';
    }
    
    HTTP_NOT_ACCEPTABLE;
}

# D4 : Accept-Language exists?
# D4 --> D5 : true
# D4 --> E5 : false
sub d4 {
    my ($self, $resource, $request, $response) = @_;

    # If no Accept-Language header is present in the request, the server
    # SHOULD assume that all languages are equally acceptable.
    defined $request->header('Accept-Language')
        ? 'd5'
        : 'e5a';
}

# D5 : Acceptable language available?
# D5 --> E5 : true
# D5 --> 406_Not_Acceptable : false
sub d5 {
    my ($self, $resource, $request, $response) = @_;

    my @languages = @{$resource->languages_provided};

    # The resource has not specified any languages, so jump to 
    # the next state.
    return 'e5a' if scalar @languages == 0;

    my $language = $self->actionpack->choose_language(
        \@languages,
        $request->header('Accept-Language')
    );

    if ($language) {
        $self->metadata->add('Language' => $language);
        $self->response->header('Content-Language' => $language);
        return 'e5a';
    }

    HTTP_NOT_ACCEPTABLE;
}

# E5 : Accept-Charset exists?
# E5 --> E6 : true
# E5 --> F6 : false
sub e5a {
    my ($self, $resource, $request, $response) = @_;

    defined $request->header('Accept-Charset')
        ? 'e6'
        : 'f6';
}

# E6 : Acceptable charset available?
# E6 --> F6 : true
# E6 --> 406_Not_Acceptable : false
sub e6 {
    my ($self, $resource, $request, $response) = @_;

    my @charsets = @{$resource->charsets_provided};

    # The resource has not specified any character sets, so jump to 
    # the next state.
    return 'f6' if scalar @charsets == 0;
    
    my $charset = $self->actionpack->choose_charset(
        \@charsets,
        $request->header('Accept-Charset')
    );

    if ($charset) {
        $self->metadata->add('Charset' => $charset);
        return 'f6';
    }

    HTTP_NOT_ACCEPTABLE;
}

sub f6 {
    my ($self, $resource, $request, $response) = @_;
}

1;

__END__

perl -ne 'm/( : | --> )/ && s/^# // && print' lib/Web/Automaton/V3/States.pm \
    | /usr/bin/java -jar /usr/local/bin/plantuml.jar -pipe \
    > diagram/v3.png && open diagram/v3.png
