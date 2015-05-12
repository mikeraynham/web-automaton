package Web::Automaton::V3::Decider;

use strict;
use warnings FATAL => qw(all);

use Digest::MD5 qw(md5_hex);
use List::Util 1.33 qw(any);
use Moo 2;
use namespace::clean;

sub b13 {
    my ($self, $resource, $request, $response) = @_;
    $resource->service_available;
}

sub b12 {
    my ($self, $resource, $request, $response) = @_;
    my $method = $request->method;
    any {$_ eq $method} @{ $resource->known_methods };
}

sub b11 {
    my ($self, $resource, $request, $response) = @_;
    $resource->uri_too_long;
}

sub b10 {
    my ($self, $resource, $request, $response) = @_;
    my $method = $request->method;
    my @allowed_methods = @{$resource->allowed_methods};
    return 1 if any {$_ eq $method} @allowed_methods;
    $response->headers('Allow' => join ', ' => @allowed_methods);
    return;
}

sub b9 {
    my ($self, $resource, $request, $response) = @_;

    return $resource->malformed_request
        if not defined $request->header('Content-MD5');

    return $resource->validate_content_checksum
        if defined $resource->validate_content_checksum;

    my $header_md5  = $request->header('Content-MD5');
    my $content_md5 = md5_hex($request->content);

    return $content_md5 eq $header_md5;
}

sub b8 {
    my ($self, $resource, $request, $response) = @_;
    
}

sub b7 {
    my ($self, $resource, $request, $response) = @_;
}

1;
