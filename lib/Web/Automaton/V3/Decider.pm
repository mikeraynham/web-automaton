package Web::Automaton::V3::Decider;

use strict;
use warnings FATAL => qw(all);

use Data::Dumper;

use Digest::MD5 qw(md5_hex);
use List::Util 1.33 qw(any);
use Scalar::Util qw(looks_like_number);
use Web::Automaton::StatusCode qw(:mnemonics);

use Moo 2;
use namespace::clean;

sub initial_state {
    \&b13;
}

sub b13 {
    my ($resource, $request, $response) = @_;

    $resource->service_available
        ? \&b12
        : HTTP_SERVICE_UNAVAILABLE;
}

sub b12 {
    my ($resource, $request, $response) = @_;
    my $method = $request->method;

    (any {$_ eq $method} @{ $resource->known_methods })
        ? \&b11
        : HTTP_NOT_IMPLEMENTED;
}

sub b11 {
    my ($resource, $request, $response) = @_;

    $resource->uri_too_long
        ? HTTP_REQUEST_URI_TOO_LARGE
        : \&b10;
}

sub b10 {
    my ($resource, $request, $response) = @_;
    my $method = $request->method;
    my @allowed_methods = @{$resource->allowed_methods};

    return \&b9a if any {$_ eq $method} @allowed_methods;

    $response->headers('Allow' => join ', ' => @allowed_methods);
    return HTTP_METHOD_NOT_ALLOWED;
}

sub b9a {
    my ($resource, $request, $response) = @_;

    defined $request->header('Content-MD5')
        ? \&b9b
        : \&b9e;
}

sub b9b {
    my ($resource, $request, $response) = @_;

    defined $resource->validate_content_checksum
        ? \&b9c
        : \&b9d;
}

sub b9c {
    my ($resource, $request, $response) = @_;

    $resource->validate_content_checksum
        ? \&b8
        : HTTP_BAD_REQUEST;
}

sub b9d {
    my ($resource, $request, $response) = @_;

    my $header_md5  = $request->header('Content-MD5');
    my $content_md5 = md5_hex($request->content);

    $content_md5 eq $header_md5
        ? \&b8
        : HTTP_BAD_REQUEST;
}

sub b9e {
    my ($resource, $request, $response) = @_;

    $resource->malformed_request
        ? HTTP_BAD_REQUEST
        : \&b8;
}

sub b8 {
    my ($resource, $request, $response) = @_;
    my $authenticated = $resource->is_authorized(
        $request->header('Authorization')
    );

    return \&b7 if $authenticated && looks_like_number($authenticated);

    $authenticated
        && $response->header('WWW-Authenticate' => $authenticated);

    HTTP_UNAUTHORIZED;
}

sub b7 {
    my ($resource, $request, $response) = @_;

    $resource->forbidden
        ? HTTP_FORBIDDEN
        : \&b6;
}

sub b6 {
    my ($resource, $request, $response) = @_;

    my $headers = $request->headers->clone;
    my @remove  = grep { !/^content-/ } $headers->header_field_names;

    $headers->remove_content_headers(@remove);

    $resource->valid_content_headers($headers)
        ? HTTP_NOT_IMPLEMENTED
        : \&b5;
}




1;
