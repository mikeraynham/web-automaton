#!/usr/bin/env perl

use strict;
use warnings FATAL => qw(all);

use FindBin;
use lib "$FindBin::Bin";
use TestResource;

use Digest::MD5 qw(md5_hex);
use HTTP::Request;
use HTTP::Request::Common qw(GET HEAD PUT POST DELETE);
use HTTP::Response;
use HTTP::Config;
use List::Util 1.33 qw(pairs);
use Test::More;
use Test::Deep;
use Data::Dumper;

use Web::Automaton::V3::States;
use Web::Automaton::V3::Resource;

my @tests = tests();
my $paths = create_paths();

for my $test (pairs @tests) {
    my ($desc, $init) = @$test;

    my $callback_responses = exists $init->{callback_responses}
        ? $init->{callback_responses} : {};

    my $request = ref($init->{request}) eq 'ARRAY'
        ? HTTP::Request->new(@{$init->{request}})
        : $init->{request};

    my $response = HTTP::Response->new;
    my $resource = TestResource->new(
        callback_responses => $callback_responses,
    );

    my $metadata = HTTP::Config->new;

    my $states = Web::Automaton::V3::States->new(
        request  => $request,
        response => $response,
        resource => $resource,
        metadata => $metadata,
    );

    $init->{pre_run}->($request) if $init->{pre_run};

    my ($code, $trace) = $states->run;

    my $path = $init->{expected_trace};
    for ($path) {
        s/^path_to_//;
        s/_via_/ via /;
        s/_/,/g;
    }

    subtest "$code, $desc ($path)" => sub {

        is( $code,
            $init->{expected_code},
            'HTTP code is ' . $init->{expected_code}
        );
        
        is_deeply(
            $trace,
            $paths->{$init->{expected_trace}},
            'state trace is correct'
        );

        if (exists $init->{expected_response_headers}) {

            my %headers = %{$init->{expected_response_headers}};

            my @keys = sort keys %headers;
            for my $key (@keys) {
                is( $response->header($key),
                    $headers{$key},
                    "header $key = $headers{$key}"
                );
            }
        }
        else {
            ok( !$response->header_field_names,
                'no response headers have been added'
            ) or diag $response->headers->as_string;
        }

        if (exists $init->{excpected_callback_args}) {
            cmp_deeply(
                $resource->callback_args,
                superhashof($init->{excpected_callback_args}),
                'the resource callback(s) received the expected arguments'
            ) or diag Dumper($resource->callback_args);
        }

        if (exists $init->{expected_metadata}) {
            cmp_deeply(
                [$metadata->entries],
                $init->{expected_metadata},
                'metadata is as expected'
            ) or diag Dumper([$metadata->entries]);
        }
    };
}

sub tests {
    my $http_1_0_methods = [qw(GET HEAD POST)];
    my $http_1_1_methods = [qw(GET HEAD POST PUT DELETE TRACE CONNECT OPTIONS)];

    'service unavailable'  => {
        expected_code      => 503,
        expected_trace     => 'path_to_b13',
        request            => HEAD('/foo'),
        callback_responses => {
            service_available => 0,
        },
    },
    'DELETE not implemented' => {
        expected_code      => 501,
        expected_trace     => 'path_to_b12',
        request            => DELETE('/foo'),
        callback_responses => {
            allowed_methods => $http_1_0_methods,
            known_methods   => $http_1_0_methods,
        },
    },
    'non-standard FOO not implemented' => {
        expected_code      => 501,
        expected_trace     => 'path_to_b12',
        request            => [FOO => '/foo'],
        callback_responses => {
            allowed_methods => $http_1_0_methods,
            known_methods   => $http_1_0_methods,
        },
    },
    'URI too long' => {
        expected_code      => 414,
        expected_trace     => 'path_to_b11',
        request            => GET('/foo'),
        callback_responses => {
            uri_too_long => 1,
        },
    },
    'HEAD method not allowed' => {
        expected_code      => 405,
        expected_trace     => 'path_to_b10',
        request            => HEAD('/foo'),
        callback_responses => {
            allowed_methods => [qw(GET POST PUT)],
        },
    },
    'invalid content checksum' => {
        expected_code  => 400,
        expected_trace => 'path_to_b9c',
        request        => GET('/foo',
            'Content-Type' => 'text/plain',
            'Content-MD5'  => 'foo',
        ),
        callback_responses => {
            validate_content_checksum => 0,
        },
    },
    'Content-MD5 checksum invalid' => {
        expected_code  => 400,
        expected_trace => 'path_to_b9d',
        request        => POST('/foo',
            'Content-Type' => 'text/plain',
            'Content-MD5'  => 'foo',
            'Content'      => 'foo',
        ),
        callback_responses => {
            allowed_methods => $http_1_0_methods,
            known_methods   => $http_1_0_methods,
        },

    },
    'malformed request' => {
        expected_code      => 400,
        expected_trace     => 'path_to_b9e',
        request            => GET('/foo'),
        callback_responses => {
            malformed_request => 1,
        },
    },
    'unauthorized with valid Content-MD5 check' => {
        expected_code  => 401,
        expected_trace => 'path_to_b8_via_b9a_b9b_b9d',
        request        => POST('/foo',
            'Content-Type' => 'text/plain',
            'Content-MD5'  => md5_hex('foo'),
            'Accept'       => 'text/plain',
            'Content'      => 'foo',
        ),
        callback_responses => {
            allowed_methods => $http_1_0_methods,
            known_methods   => $http_1_0_methods,
            is_authorized   => 0,
        },
    },
    'unauthorized with WWW-Authenticate header' => {
        expected_code           => 401,
        expected_trace          => 'path_to_b8_via_b9a_b9e',
        excpected_callback_args => {
            is_authorized => ['foo'],
        },
        expected_response_headers => {
            'WWW-Authenticate' => 'Test Realm',
        },
        request => GET('/foo',
            'Content-Type' => 'text/plain',
        ),
        callback_responses => {
            is_authorized => 'Test Realm',
        },
        pre_run => sub {
            shift->header('Authorization' => 'foo');
        },
    },
    'forbidden' => {
        expected_code  => 403,
        expected_trace => 'path_to_b7',
        request        => GET('/foo'),
        callback_responses => {
            forbidden => 1,
        },
    },
    'invalid content headers' => {
        expected_code           => 501,
        expected_trace          => 'path_to_b6',
        excpected_callback_args => {
            valid_content_headers => [
                HTTP::Headers->new('Content-Type' => 'text/plain'),
            ],
        },
        request => GET('/foo',
            'Content-Type' => 'text/plain',
            'Accept'       => 'text/plain',
        ),
        callback_responses => {
            valid_content_headers => 0,
        },
    },
    'unknown content type' => {
        expected_code           => 415,
        expected_trace          => 'path_to_b5',
        excpected_callback_args => {
            known_content_type => ['text/plain'],
        },
        request => GET('/foo',
            'Content-Type' => 'text/plain',
        ),
        callback_responses => {
            known_content_type => 0,
        },
    },
    'request entity too large' => {
        expected_code           => 413,
        expected_trace          => 'path_to_b4',
        excpected_callback_args => {
            valid_entity_length => [3],
        },
        request => POST('/foo', Content => 'foo'),
        callback_responses => {
            allowed_methods     => [qw(POST)],
            valid_entity_length => 0,
        },
    },
    'OPTIONS request' => {
        expected_code      => 200,
        expected_trace     => 'path_to_b3',
        request            => [OPTIONS => '/foo'],
        callback_responses => {
            allowed_methods => [qw(OPTIONS)],
        },
    },
    'accept exists, media type unavailable' => {
        expected_code  => 406,
        expected_trace => 'path_to_c4',
        request => GET(
            '/foo',
            # C3: true
            'Accept' => 'text/plain',
        ),
        callback_responses => {
            # C4: false
            content_types_provided => ['text/html' => 'to_html'],
        },
    },
    'accept does not exist' => {
        expected_code  => 406,
        expected_trace => 'path_to_d5_via_c3',
        request => GET(
            '/foo',
            # D4: true
            'Accept-Language' => 'en',
        ),
        callback_responses => {
            # C3: default content type
            content_types_provided => ['text/plain' => 'to_text'],
            # D5: false
            languages_provided => ['es'],
        },
    },
    'accept-language exists, language unavailable' => {
        expected_code     => 406,
        expected_trace    => 'path_to_d5_via_c4',
        expected_metadata => [{
            'Content-Type' => HTTP::Headers::ActionPack->new->create(
                MediaType => 'text/plain',
            )
        }],
        request => GET(
            '/foo',
            # C3: true 
            'Accept' => 'text/plain',
            # D4: true
            'Accept-Language' => 'en',
        ),
        callback_responses => {
            # C4: true
            content_types_provided => ['text/plain' => 'to_text'],
            # D5: false
            languages_provided => ['es'],
        },
    },
    'accept-language exists, language available' => {
        expected_code     => 406,
        expected_trace    => 'path_to_e6_via_d5_c3',
        expected_metadata => [{
            'Content-Type' => HTTP::Headers::ActionPack->new->create(
                MediaType => 'text/plain',
            )
        }, {
            'Language' => 'en',
        }],
        expected_response_headers => {
            'Content-Language' => 'en',
        },
        request => GET(
            '/foo',
            # D4: true
            'Accept-Language' => 'en',
            # E5: true
            'Accept-Charset' => 'UTF-8',
        ),
        callback_responses => {
            # C3: default content type
            content_types_provided => ['text/plain' => 'to_text'],
            # D5: true
            languages_provided => ['en'],
            charsets_provided => ['US-ASCII'],
        },
    },

}

sub merge {
    my ($paths, $new, $existing, @states) = @_;
    $paths->{$new} = [
        $existing ? @{$paths->{$existing}} : (),
        @states
    ];
}

sub create_paths {
    my $paths = {};

    merge($paths,
        'path_to_b13',
        undef,
        'b13'
    );

    merge($paths, qw(
        path_to_b12
        path_to_b13
        b12
    ));

    merge($paths, qw(
        path_to_b11
        path_to_b12
        b11
    ));

    merge($paths, qw(
        path_to_b10
        path_to_b11
        b10
    ));

    merge($paths, qw(
        path_to_b9a
        path_to_b10
        b9a
    ));

    merge($paths, qw(
        path_to_b9b
        path_to_b9a
        b9b
    ));

    merge($paths, qw(
        path_to_b9c
        path_to_b9b
        b9c
    ));

    merge($paths, qw(
        path_to_b9d
        path_to_b9b
        b9d
    ));

    merge($paths, qw(
        path_to_b9e
        path_to_b9a
        b9e
    ));

    merge($paths, qw(
        path_to_b8_via_b9a_b9e
        path_to_b9e
        b8
    ));

    merge($paths, qw(
        path_to_b8_via_b9a_b9b_b9d
        path_to_b9b
        b9d
        b8
    ));

    merge($paths, qw(
        path_to_b7
        path_to_b8_via_b9a_b9e
        b7
    ));

    merge($paths, qw(
        path_to_b6
        path_to_b7
        b6
    ));
    merge($paths, qw(
        path_to_b5
        path_to_b6
        b5
    ));

    merge($paths, qw(
        path_to_b4
        path_to_b5
        b4
    ));

    merge($paths, qw(
        path_to_b3
        path_to_b4
        b3
    ));

    # C3 - There is one path to state C3
    merge($paths, qw(
        path_to_c3
        path_to_b3
        c3
    ));

    # C4 - There is one path to state C4
    merge($paths, qw(
        path_to_c4
        path_to_c3
        c4
    ));

    # D4 - There are two paths to D4: via C3 or via C4
    merge($paths, qw(
        path_to_d4_via_c3
        path_to_c3
        d4
    ));

    merge($paths, qw(
        path_to_d4_via_c4
        path_to_c4
        d4
    ));

    # D5 - There are two paths to D5: via C3 or via C4
    merge($paths, qw(
        path_to_d5_via_c3
        path_to_d4_via_c3
        d5
    ));

    merge($paths, qw(
        path_to_d5_via_c4
        path_to_d4_via_c4
        d5
    ));

    # E5 - There are four paths to E5: via D5 (via C3 or via C4) or via D4
    # (via C3 or via C4). Only some of these paths are tested.
    merge($paths, qw(
        path_to_e5_via_d5_c3
        path_to_d5_via_c3
        e5
    ));

    merge($paths, qw(
        path_to_e5_via_d5_c4
        path_to_d5_via_c4
        e5
    ));

    merge($paths, qw(
        path_to_e5_via_d4_c3
        path_to_d4_via_c3
        e5
    ));

    # E6 - There are four paths to E6: via D5 (via C3 or via C4) or via D4
    # (via C3 or via C4). Only two of these paths to E6 are tested
    merge($paths, qw(
        path_to_e6_via_d5_c3
        path_to_e5_via_d5_c3
        e6
    ));

    merge($paths, qw(
        path_to_e6_via_d5_c4
        path_to_e5_via_d5_c4
        e6
    ));

    # F6 - Selection of the paths to F6
    merge($paths, qw(
        path_to_f6_via_e6_d5_c4
        path_to_e6_via_d5_c4
        f6
    ));

    merge($paths, qw(
        path_to_f6_via_e5_d4_c3
        path_to_e5_via_d4_c3
        f6
    ));

    # F7 - A path to F7
    merge($paths, qw(
        path_to_f7_via_e6_d5_c4
        path_to_f6_via_e6_d5_c4
        f7
    ));

    # G7 - The path to G7, without accept headers in the request
    merge($paths, qw(
        path_to_g7_via_f6_e6_d5_c4
        path_to_f6_via_e5_d4_c3
        g7
    ));

    merge($paths, qw(
        path_to_g7_no_acpthead
        path_to_g7_via_f6_e6_d5_c4
    ));

    # G9 - The path to G9, without accept headers in the request
    merge($paths, qw(
        path_to_g9_via_f6_e6_d5_c4
        path_to_g7_via_f6_e6_d5_c4
        g8 g9
    ));

    # G11 - The path to G11, without accept headers in the request
    merge($paths, qw(
        path_to_g11_via_f6_e6_d5_c4
        path_to_g7_via_f6_e6_d5_c4
        g8 g9 g11
    ));

    merge($paths, qw(
        path_to_g11_no_acpthead
        path_to_g11_via_f6_e6_d5_c4
    ));

    # H7 - The path to H7 without accept headers
    merge($paths, qw(
        path_to_h7_no_acpthead
        path_to_g7_no_acpthead
        h7
    ));

    # I7 - The path to I7 without accept headers
    merge($paths, qw(
        path_to_i7_no_acpthead
        path_to_h7_no_acpthead
        i7
    ));

    # I4 - The path to I4 without accept headers
    merge($paths, qw(
        path_to_i4_no_acpthead
        path_to_i7_no_acpthead
        i4
    ));

    # K7 - The path to K7 without accept headers
    merge($paths, qw(
        path_to_k7_no_acpthead
        path_to_i7_no_acpthead
        k7
    ));

    # L7 - The path to L7 without accept headers
    merge($paths, qw(
        path_to_l7_no_acpthead
        path_to_k7_no_acpthead
        l7
    ));

    # M7 - The path to M7 without accept headers
    merge($paths, qw(
        path_to_m7_no_acpthead
        path_to_l7_no_acpthead
        m7
    ));

    # P3 - The path to P3 without accept headers
    merge($paths, qw(
        path_to_p3_no_acpthead
        path_to_i4_no_acpthead
        p3
    ));

    # K5 - The path to K5 without accept headers
    merge($paths, qw(
        path_to_k5_no_acpthead
        path_to_k7_no_acpthead
        k5
    ));

    # L5 - The path to L5 without accept headers
    merge($paths, qw(
        path_to_l5_no_acpthead
        path_to_k5_no_acpthead
        l5
    ));

    # M5 - The path to M5 without accept headers
    merge($paths, qw(
        path_to_m5_no_acpthead
        path_to_l5_no_acpthead
        m5
    ));

    # N5 - The path to N5 without accept headers
    merge($paths, qw(
        path_to_n5_no_acpthead
        path_to_m5_no_acpthead
        n5
    ));
#
    # N11 - Two paths to N11 without accept headers
    merge($paths, qw(
        path_to_n11_via_m7_no_acpthead
        path_to_m7_no_acpthead
        n11
    ));

    merge($paths, qw(
        path_to_n11_via_n5_no_acpthead
        path_to_n5_no_acpthead
        n11
    ));

    # H10 - The path to H10 without accept headers
    merge($paths, qw(
        path_to_h10_via_g8_f6_e6_d5_c4
        path_to_g7_via_f6_e6_d5_c4
        g8 h10
    ));

    # H11 - The path to H11 without accept headers, via G11
    merge($paths, qw(
        path_to_h11_via_g11_f6_e6_d5_c4
        path_to_g11_no_acpthead
        h10 h11
    ));

    # H12 - Two paths to H12 without accept headers
    merge($paths, qw(
        path_to_h12_via_g8_f6_e6_d5_c4
        path_to_h10_via_g8_f6_e6_d5_c4
        h11 h12
    ));

    merge($paths, qw(
        path_to_h12_via_g9_f6_e6_d5_c4
        path_to_g9_via_f6_e6_d5_c4
        h10 h11 h12
    ));

    merge($paths, qw(
        path_to_h12_no_acpthead
        path_to_h12_via_g8_f6_e6_d5_c4
    ));

    merge($paths, qw(
        path_to_h12_no_acpthead_2
        path_to_h12_via_g9_f6_e6_d5_c4
    ));

    # I12 - Two paths to I12 without accept headers
    merge($paths, qw(
        path_to_i12_via_h10_g8_f6_e6_d5_c4
        path_to_h10_via_g8_f6_e6_d5_c4
        i12
    ));

    merge($paths, qw(
        path_to_i12_via_h11_g11_f6_e6_d5_c4
        path_to_h11_via_g11_f6_e6_d5_c4
        i12
    ));

    # L13 - A path to L13 without accept headers
    merge($paths, qw(
        path_to_l13_no_acpthead
        path_to_i12_via_h10_g8_f6_e6_d5_c4
        l13
    ));

    # M16 - A path to M16 without accept headers
    merge($paths, qw(
        path_to_m16_no_acpthead
        path_to_l13_no_acpthead
        m16
    ));

    # M20 - A path to M20 without accept headers
    merge($paths, qw(
        path_to_m20_no_acpthead
        path_to_m16_no_acpthead
        m20
    ));

    # N16 - A path to N16 without accept headers
    merge($paths, qw(
        path_to_n16_no_acpthead
        path_to_m16_no_acpthead
        n16
    ));

    # O16 - A path to O16 without accept headers
    merge($paths, qw(
        path_to_o16_no_acpthead
        path_to_n16_no_acpthead
        o16
    ));

    # O14 - A path to O14 without accept headers
    merge($paths, qw(
        path_to_o14_no_acpthead
        path_to_o16_no_acpthead
        o14
    ));

    # O18 - A path to O18 without accept headers
    merge($paths, qw(
        path_to_o18_no_acpthead
        path_to_o16_no_acpthead
        o18
    ));

    # O20 - A path to O20 without accept headers
    # merge($paths, qw(
    #     o20_no_acpthead
    #     p11
    # ));

    # L17 - A path to L17 without accept headers
    merge($paths, qw(
        path_to_l17_no_acpthead
        path_to_l13_no_acpthead
        l14 l15 l17
    ));

    # I13 - Two paths to I13 without accept headers
    merge($paths, qw(
        path_to_i13_via_h10_g8_f6_e6_d5_c4
        path_to_i12_via_h10_g8_f6_e6_d5_c4
        i13
    ));
    merge($paths, qw(
        path_to_i13_via_h11_g11_f6_e6_d5_c4
        path_to_i12_via_h11_g11_f6_e6_d5_c4
        i13
    ));

    # K13 - The path to K13 without accept headers, via I13, I12, H11, G11
    merge($paths, qw(
        path_to_k13_via_h11_g11_f6_e6_d5_c4
        path_to_i13_via_h11_g11_f6_e6_d5_c4
        k13
    ));

    # J18 - Three paths to J18 without accept headers (one via H10; one via H11
    # and K13; one via H12);
    merge($paths, qw(
        path_to_j18_via_i13_h10_g8_f6_e6_d5_c4
        path_to_i13_via_h10_g8_f6_e6_d5_c4
        j18
    ));
    merge($paths, qw(
        path_to_j18_via_k13_h11_g11_f6_e6_d5_c4
        path_to_k13_via_h11_g11_f6_e6_d5_c4
        j18
    ));
    merge($paths, qw(
        path_to_j18_no_acpthead
        path_to_j18_via_i13_h10_g8_f6_e6_d5_c4
    ));

    merge($paths, qw(
        path_to_j18_no_acpthead_2
        path_to_j18_via_k13_h11_g11_f6_e6_d5_c4
    ));

    merge($paths, qw(
        path_to_j18_no_acpthead_3
        path_to_h12_no_acpthead_2
        i12 i13 j18
    ));

    # P11 - Three paths to P11 without accept headers, via N11, P3, or O14
    merge($paths, qw(
        path_to_p11_via_n11_no_acpthead
        path_to_n11_via_m7_no_acpthead
        p11
    ));

    merge($paths, qw(
        path_to_p11_via_p3_no_acpthead
        path_to_p3_no_acpthead
        p11
    ));

    merge($paths, qw(
        path_to_p11_via_o14_no_acpthead
        path_to_o14_no_acpthead
        p11
    ));

    # O20 - The path to O20 via P11 via O14
    merge($paths, qw(
        path_to_o20_via_p11_via_o14_no_acpthead
        path_to_p11_via_o14_no_acpthead
        o20
    ));

    return $paths;
}

done_testing;
