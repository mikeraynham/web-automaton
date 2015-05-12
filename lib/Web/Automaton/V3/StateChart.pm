package Web::Automaton::V3::StateChart;

use strict;
use warnings FATAL => qw(all);

use Moo 2;
use namespace::clean;

sub initial_state {
    'b13';
}

sub transitions {
    b3  => [qw( 200  c3 )],
    b4  => [qw( 413  b3 )],
    b5  => [qw( 415  b4 )],
    b6  => [qw( 501  b5 )],
    b7  => [qw( 403  b6 )],
    b8  => [qw(  b7 401 )],
    b9  => [qw( 400  b8 )],
    b10 => [qw(  b9 405 )],
    b11 => [qw( 414 b10 )],
    b12 => [qw( b11 501 )],
    b13 => [qw( b12 503 )],
    c3  => [qw(  c4  d4 )],
    c4  => [qw(  d4 406 )],
    d4  => [qw(  d5  e5 )],
    d5  => [qw(  e5 406 )],
    e5  => [qw(  e6  f6 )],
    e6  => [qw(  f6 406 )],
    f6  => [qw(  f7  g7 )],
    f7  => [qw(  g7 406 )],
    g7  => [qw(  g8  h7 )],
    g8  => [qw(  g9 h10 )],
    g9  => [qw( h10 g11 )],
    g11 => [qw( h10 412 )],
    h7  => [qw( 412  i7 )],
    h10 => [qw( h11 i12 )],
    h11 => [qw( h12 i12 )],
    h12 => [qw( 412 i12 )],
    i4  => [qw( 301  p3 )],
    i7  => [qw(  i4  k7 )],
    i12 => [qw( i13 l13 )],
    i13 => [qw( j18 k13 )],
    j18 => [qw( 304 412 )],
    k5  => [qw( 301  l5 )],
    k7  => [qw(  k5  l7 )],
    k13 => [qw( j18 l13 )],
    l5  => [qw( 307  m5 )],
    l7  => [qw(  m7 404 )],
    l13 => [qw( l14 m16 )],
    l14 => [qw( l15 m16 )],
    l15 => [qw( m16 l17 )],
    l17 => [qw( m16 304 )],
    m5  => [qw(  n5 410 )],
    m7  => [qw( n11 404 )],
    m16 => [qw( m20 n16 )],
    m20 => [qw( o20 202 )],
    n5  => [qw( n11 410 )],
    n11 => [qw( 303 p11 )],
    n16 => [qw( n11 o16 )],
    o14 => [qw( 409 p11 )],
    o16 => [qw( o14 o18 )],
    o18 => [qw( 300 200 )],
    o20 => [qw( o18 204 )],
    p3  => [qw( 409 p11 )],
    p11 => [qw( 201 o20 )],
}

1;
