# B13-B3 -- All decision-trace-paths start at B13. There is a linear path
# crossing the B nodes if you ignore substates.

sub merge {
    my ($paths, $new, $existing, @states) = @_;
    $paths->{$new} = [
        $existing ? @{$paths->{$existing}} : (),
        @states
    ];
}

my $paths = {};

merge($paths, 'b13', undef, qw(b13));
merge($paths, 'b12', 'b13', qw(b12));
merge($paths, 'b11', 'b12', qw(b11));
merge($paths, 'b10', 'b11', qw(b10));
merge($paths, 'b9',  'b10',  qw(b9));
merge($paths, 'b8',   'b9',  qw(b8));
merge($paths, 'b7',   'b8',  qw(b7));
merge($paths, 'b6',   'b7',  qw(b6));
merge($paths, 'b5',   'b6',  qw(b5));
merge($paths, 'b4',   'b5',  qw(b4));
merge($paths, 'b3',   'b4',  qw(b3));

# C3 - There is one path to state C3
merge($paths, 'c3', 'b3', qw(c3));

# C4 - There is one path to state C4
merge($paths, 'c4', 'c3', qw(c4));

# D4 - There are two paths to D4: via C3 or via C4
merge($paths, 'd4_via_c3', 'c3', qw(d4));
merge($paths, 'd4_via_c4', 'c4', qw(d4));

# D5 - There are two paths to D5: via C3 or via C4
merge($paths, 'd5_via_c3', 'd4_via_c3', qw(d5));
merge($paths, 'd5_via_c4', 'd4_via_c4', qw(d5));

# E5 - There are four paths to E5: via D5 (via C3 or via C4) or via D4 (via C3
# or via C4). Only some of these paths are tested.
merge($paths, 'e5_via_d5_c3', 'd5_via_c3', qw(e5));
merge($paths, 'e5_via_d5_c4', 'd5_via_c4', qw(e5));
merge($paths, 'e5_via_d4_c3', 'd4_via_c3', qw(e5));

# E6 - There are four paths to E6: via D5 (via C3 or via C4) or via D4 (via C3
#  or via C4). Only two of these paths to E6 are tested
merge($paths, 'e6_via_d5_c3', 'e5_via_d5_c3', qw(e6));
merge($paths, 'e6_via_d5_c4', 'e5_via_d5_c4', qw(e6));

# F6 - Selection of the paths to F6
merge($paths, 'f6_via_e6_d5_c4', 'e6_via_d5_c4', qw(f6));
merge($paths, 'f6_via_e5_d4_c3', 'e5_via_d4_c3', qw(f6));

# F7 - A path to F7
merge($paths, 'f7_via_e6_d5_c4', 'f6_via_e6_d5_c4', qw(f7));

# G7 - The path to G7, without accept headers in the request
merge($paths, 'g7_via_f6_e6_d5_c4', 'f6_via_e5_d4_c3', qw(g7));
merge($paths, 'g7_no_acpthead', 'g7_via_f6_e6_d5_c4');

# G9 - The path to G9, without accept headers in the request
merge($paths, 'g9_via_f6_e6_d5_c4', 'g7_via_f6_e6_d5_c4', qw(g8 g9));

# G11 - The path to G11, without accept headers in the request
merge($paths, 'g11_via_f6_e6_d5_c4', 'g7_via_f6_e6_d5_c4', qw(g8 g9 g11));
merge($paths, 'g11_no_acpthead', 'g11_via_f6_e6_d5_c4');

# H7 - The path to H7 without accept headers
merge($paths, 'h7_no_acpthead', 'g7_no_acpthead', qw(h7));

# I7 - The path to I7 without accept headers
merge($paths, 'i7_no_acpthead', 'h7_no_acpthead', qw(i7));

# I4 - The path to I4 without accept headers
merge($paths, 'i4_no_acpthead', 'i7_no_acpthead', qw(i4));

# K7 - The path to K7 without accept headers
merge($paths, 'k7_no_acpthead', 'i7_no_acpthead', qw(k7));

# L7 - The path to L7 without accept headers
merge($paths, 'l7_no_acpthead', 'k7_no_acpthead', qw(l7));

# M7 - The path to M7 without accept headers
merge($paths, 'm7_no_acpthead', 'l7_no_acpthead', qw(m7));

# N11 - Two paths to N11 without accept headers
merge($paths, 'n11_via_m7_no_acpthead', 'm7_no_acpthead', qw(n11));
merge($paths, 'n11_via_n5_no_acpthead', 'n5_no_acpthead', qw(n11));

# P3 - The path to P3 without accept headers
merge($paths, 'p3_no_acpthead', 'i4_no_acpthead', qw(p3));

# K5 - The path to K5 without accept headers
merge($paths, 'k5_no_acpthead', 'k7_no_acpthead', qw(k5));

# L5 - The path to L5 without accept headers
merge($paths, 'l5_no_acpthead', 'k5_no_acpthead', qw(l5));

# M5 - The path to M5 without accept headers
merge($paths, 'm5_no_acpthead', 'l5_no_acpthead', qw(m5));

# N5 - The path to N5 without accept headers
merge($paths, 'n5_no_acpthead', 'm5_no_acpthead', qw(n5));

# H10 - The path to H10 without accept headers
merge($paths, 'h10_via_g8_f6_e6_d5_c4', 'g7_via_f6_e6_d5_c4', qw(g8 h10));

# H11 - The path to H11 without accept headers, via G11
merge($paths, 'h11_via_g11_f6_e6_d5_c4', 'g11_no_acpthead', qw(h10 h11));

# H12 - Two paths to H12 without accept headers
merge($paths, 'h12_via_g8_f6_e6_d5_c4', 'h10_via_g8_f6_e6_d5_c4', qw(h11 h12));
merge($paths, 'h12_via_g9_f6_e6_d5_c4', 'g9_via_f6_e6_d5_c4', qw(h10 h11 h12));
merge($paths, 'h12_no_acpthead', 'h12_via_g8_f6_e6_d5_c4');
merge($paths, 'h12_no_acpthead_2', 'h12_via_g9_f6_e6_d5_c4');

# I12 - Two paths to I12 without accept headers
merge($paths, 'i12_via_h10_g8_f6_e6_d5_c4', 'h10_via_g8_f6_e6_d5_c4', qw(i12));
merge($paths, 'i12_via_h11_g11_f6_e6_d5_c4', 'h11_via_g11_f6_e6_d5_c4', qw(i12));

# L13 - A path to L13 without accept headers
merge($paths, 'l13_no_acpthead', 'i12_via_h10_g8_f6_e6_d5_c4', qw(l13));

# M16 - A path to M16 without accept headers
merge($paths, 'm16_no_acpthead', 'l13_no_acpthead', qw(m16));

# M20 - A path to M20 without accept headers
merge($paths, 'm20_no_acpthead', 'm16_no_acpthead', qw(m20));

# N16 - A path to N16 without accept headers
merge($paths, 'n16_no_acpthead', 'm16_no_acpthead', qw(n16));

# O16 - A path to O16 without accept headers
merge($paths, 'o16_no_acpthead', 'n16_no_acpthead', qw(o16));

# O14 - A path to O14 without accept headers
merge($paths, 'o14_no_acpthead', 'o16_no_acpthead', qw(o14));

# O18 - A path to O18 without accept headers
merge($paths, 'o18_no_acpthead', 'o16_no_acpthead', qw(o18));

# O20 - A path to O20 without accept headers
#merge($paths, 'o20_no_acpthead', 'p11');

# L17 - A path to L17 without accept headers
merge($paths, 'l17_no_acpthead', 'l13_no_acpthead', qw(l14 l15 l17));

# I13 - Two paths to I13 without accept headers
merge($paths, 'i13_via_h10_g8_f6_e6_d5_c4', 'i12_via_h10_g8_f6_e6_d5_c4', qw(i13));
merge($paths, 'i13_via_h11_g11_f6_e6_d5_c4', 'i12_via_h11_g11_f6_e6_d5_c4', qw(i13));

# K13 - The path to K13 without accept headers, via I13, I12, H11, G11
merge($paths, 'k13_via_h11_g11_f6_e6_d5_c4', 'i13_via_h11_g11_f6_e6_d5_c4', qw(k13));

# J18 - Three paths to J18 without accept headers (one via H10; one via H11
# and K13; one via H12);
merge($paths, 'j18_via_i13_h10_g8_f6_e6_d5_c4', 'i13_via_h10_g8_f6_e6_d5_c4', qw(j18));
merge($paths, 'j18_via_k13_h11_g11_f6_e6_d5_c4', 'k13_via_h11_g11_f6_e6_d5_c4', qw(j18));
merge($paths, 'j18_no_acpthead', 'j18_via_i13_h10_g8_f6_e6_d5_c4');
merge($paths, 'j18_no_acpthead_2', 'j18_via_k13_h11_g11_f6_e6_d5_c4');
merge($paths, 'j18_no_acpthead_3', 'h12_no_acpthead_2', qw(i12 i13 j18));

# P11 - Three paths to P11 without accept headers, via N11, P3, or O14
merge($paths, 'p11_via_n11_no_acpthead', 'n11_via_m7_no_acpthead', qw(p11));
merge($paths, 'p11_via_p3_no_acpthead', 'p3_no_acpthead', qw(p11));
merge($paths, 'p11_via_o14_no_acpthead', 'o14_no_acpthead', qw(p11));

# O20 - The path to O20 via P11 via O14
merge($paths, 'o20_via_p11_via_o14_no_acpthead', 'p11_via_o14_no_acpthead', qw(o20));

use Data::Dumper;
print Dumper($paths);
