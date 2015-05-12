# B13-B3 -- All decision-trace-paths start at B13. There is a linear path
# crossing the B nodes if you ignore substates.
#-define(PATH_TO_B13, [b13]).

{
    my $paths = {path_to_b13 => ['b13']};
    sub merge {
        my ($new, $old, @states) = @_;
        $paths->{$new} = [@{$paths->{$old}}, @states];
    }

    sub paths {$paths}
}

merge('path_to_b12', 'path_to_b13', qw(b12));
merge('path_to_b11', 'path_to_b12', qw(b11));
merge('path_to_b10', 'path_to_b11', qw(b10));
merge('path_to_b9', 'path_to_b10', qw(b9));
merge('path_to_b8', 'path_to_b9', qw(b8));
merge('path_to_b7', 'path_to_b8', qw(b7));
merge('path_to_b6', 'path_to_b7', qw(b6));
merge('path_to_b5', 'path_to_b6', qw(b5));
merge('path_to_b4', 'path_to_b5', qw(b4));
merge('path_to_b3', 'path_to_b4', qw(b3));

# C3 - There is one path to state C3
merge('path_to_c3', 'path_to_b3', qw(c3));

# C4 - There is one path to state C4
merge('path_to_c4', 'path_to_c3', qw(c4));

# D4 - There are two paths to D4: via C3 or via C4
merge('path_to_d4_via_c3', 'path_to_c3', qw(d4));
merge('path_to_d4_via_c4', 'path_to_c4', qw(d4));

# D5 - There are two paths to D5: via C3 or via C4
merge('path_to_d5_via_c3', 'path_to_d4_via_c3', qw(d5));
merge('path_to_d5_via_c4', 'path_to_d4_via_c4', qw(d5));

# E5 - There are four paths to E5: via D5 (via C3 or via C4) or via D4 (via C3
# or via C4). Only some of these paths are tested.
merge('path_to_e5_via_d5_c3', 'path_to_d5_via_c3', qw(e5));
merge('path_to_e5_via_d5_c4', 'path_to_d5_via_c4', qw(e5));
merge('path_to_e5_via_d4_c3', 'path_to_d4_via_c3', qw(e5));

# E6 - There are four paths to E6: via D5 (via C3 or via C4) or via D4 (via C3
#  or via C4). Only two of these paths to E6 are tested
merge('path_to_e6_via_d5_c3', 'path_to_e5_via_d5_c3', qw(e6));
merge('path_to_e6_via_d5_c4', 'path_to_e5_via_d5_c4', qw(e6));

# F6 - Selection of the paths to F6
merge('path_to_f6_via_e6_d5_c4', 'path_to_e6_via_d5_c4', qw(f6));
merge('path_to_f6_via_e5_d4_c3', 'path_to_e5_via_d4_c3', qw(f6));

# F7 - A path to F7
merge('path_to_f7_via_e6_d5_c4', 'path_to_f6_via_e6_d5_c4', qw(f7));

# G7 - The path to G7, without accept headers in the request
merge('path_to_g7_via_f6_e6_d5_c4', 'path_to_f6_via_e5_d4_c3', qw(g7));
merge('path_to_g7_no_acpthead', 'path_to_g7_via_f6_e6_d5_c4');

# G9 - The path to G9, without accept headers in the request
merge('path_to_g9_via_f6_e6_d5_c4', 'path_to_g7_via_f6_e6_d5_c4', qw(g8 g9));

# G11 - The path to G11, without accept headers in the request
merge('path_to_g11_via_f6_e6_d5_c4', 'path_to_g7_via_f6_e6_d5_c4', qw(g8 g9 g11));
merge('path_to_g11_no_acpthead', 'path_to_g11_via_f6_e6_d5_c4');

# H7 - The path to H7 without accept headers
merge('path_to_h7_no_acpthead', 'path_to_g7_no_acpthead', qw(h7));

# I7 - The path to I7 without accept headers
merge('path_to_i7_no_acpthead', 'path_to_h7_no_acpthead', qw(i7));

# I4 - The path to I4 without accept headers
merge('path_to_i4_no_acpthead', 'path_to_i7_no_acpthead', qw(i4));

# K7 - The path to K7 without accept headers
merge('path_to_k7_no_acpthead', 'path_to_i7_no_acpthead', qw(k7));

# L7 - The path to L7 without accept headers
merge('path_to_l7_no_acpthead', 'path_to_k7_no_acpthead', qw(l7));

# M7 - The path to M7 without accept headers
merge('path_to_m7_no_acpthead', 'path_to_l7_no_acpthead', qw(m7));

# N11 - Two paths to N11 without accept headers
merge('path_to_n11_via_m7_no_acpthead', 'path_to_m7_no_acpthead', qw(n11));
merge('path_to_n11_via_n5_no_acpthead', 'path_to_n5_no_acpthead', qw(n11));

# P3 - The path to P3 without accept headers
merge('path_to_p3_no_acpthead', 'path_to_i4_no_acpthead', qw(p3));

# K5 - The path to K5 without accept headers
merge('path_to_k5_no_acpthead', 'path_to_k7_no_acpthead', qw(k5));

# L5 - The path to L5 without accept headers
merge('path_to_l5_no_acpthead', 'path_to_k5_no_acpthead', qw(l5));

# M5 - The path to M5 without accept headers
merge('path_to_m5_no_acpthead', 'path_to_l5_no_acpthead', qw(m5));

# N5 - The path to N5 without accept headers
merge('path_to_n5_no_acpthead', 'path_to_m5_no_acpthead', qw(n5));

# H10 - The path to H10 without accept headers
merge('path_to_h10_via_g8_f6_e6_d5_c4', 'path_to_g7_via_f6_e6_d5_c4', qw(g8 h10));

# H11 - The path to H11 without accept headers, via G11
merge('path_to_h11_via_g11_f6_e6_d5_c4', 'path_to_g11_no_acpthead', qw(h10 h11));

# H12 - Two paths to H12 without accept headers
merge('path_to_h12_via_g8_f6_e6_d5_c4', 'path_to_h10_via_g8_f6_e6_d5_c4', qw(h11 h12));
merge('path_to_h12_via_g9_f6_e6_d5_c4', 'path_to_g9_via_f6_e6_d5_c4', qw(h10 h11 h12));
merge('path_to_h12_no_acpthead', 'path_to_h12_via_g8_f6_e6_d5_c4');
merge('path_to_h12_no_acpthead_2', 'path_to_h12_via_g9_f6_e6_d5_c4');

# I12 - Two paths to I12 without accept headers
merge('path_to_i12_via_h10_g8_f6_e6_d5_c4', 'path_to_h10_via_g8_f6_e6_d5_c4', qw(i12));
merge('path_to_i12_via_h11_g11_f6_e6_d5_c4', 'path_to_h11_via_g11_f6_e6_d5_c4', qw(i12));

# L13 - A path to L13 without accept headers
merge('path_to_l13_no_acpthead', 'path_to_i12_via_h10_g8_f6_e6_d5_c4', qw(l13));

# M16 - A path to M16 without accept headers
merge('path_to_m16_no_acpthead', 'path_to_l13_no_acpthead', qw(m16));

# M20 - A path to M20 without accept headers
merge('path_to_m20_no_acpthead', 'path_to_m16_no_acpthead', qw(m20));

# N16 - A path to N16 without accept headers
merge('path_to_n16_no_acpthead', 'path_to_m16_no_acpthead', qw(n16));

# O16 - A path to O16 without accept headers
merge('path_to_o16_no_acpthead', 'path_to_n16_no_acpthead', qw(o16));

# O14 - A path to O14 without accept headers
merge('path_to_o14_no_acpthead', 'path_to_o16_no_acpthead', qw(o14));

# O18 - A path to O18 without accept headers
merge('path_to_o18_no_acpthead', 'path_to_o16_no_acpthead', qw(o18));

# O20 - A path to O20 without accept headers
#-define(PATH_TO_O20_NO_ACPTHEAD, PATH_TO_P11).

# L17 - A path to L17 without accept headers
merge('path_to_l17_no_acpthead', 'path_to_l13_no_acpthead', qw(l14 l15 l17));

# I13 - Two paths to I13 without accept headers
merge('path_to_i13_via_h10_g8_f6_e6_d5_c4', 'path_to_i12_via_h10_g8_f6_e6_d5_c4', qw(i13));
merge('path_to_i13_via_h11_g11_f6_e6_d5_c4', 'path_to_i12_via_h11_g11_f6_e6_d5_c4', qw(i13));

# K13 - The path to K13 without accept headers, via I13, I12, H11, G11
merge('path_to_k13_via_h11_g11_f6_e6_d5_c4', 'path_to_i13_via_h11_g11_f6_e6_d5_c4', qw(k13));

# J18 - Three paths to J18 without accept headers (one via H10; one via H11
# and K13; one via H12);
merge('path_to_j18_via_i13_h10_g8_f6_e6_d5_c4', 'path_to_i13_via_h10_g8_f6_e6_d5_c4', qw(j18));
merge('path_to_j18_via_k13_h11_g11_f6_e6_d5_c4', 'path_to_k13_via_h11_g11_f6_e6_d5_c4', qw(j18));
merge('path_to_j18_no_acpthead', 'path_to_j18_via_i13_h10_g8_f6_e6_d5_c4');
merge('path_to_j18_no_acpthead_2', 'path_to_j18_via_k13_h11_g11_f6_e6_d5_c4');
merge('path_to_j18_no_acpthead_3', 'path_to_h12_no_acpthead_2', qw(i12 i13 j18));

# P11 - Three paths to P11 without accept headers, via N11, P3, or O14
merge('path_to_p11_via_n11_no_acpthead', 'path_to_n11_via_m7_no_acpthead', qw(p11));
merge('path_to_p11_via_p3_no_acpthead', 'path_to_p3_no_acpthead', qw(p11));
merge('path_to_p11_via_o14_no_acpthead', 'path_to_o14_no_acpthead', qw(p11));

# O20 - The path to O20 via P11 via O14
merge('path_to_o20_via_p11_via_o14_no_acpthead', 'path_to_p11_via_o14_no_acpthead', qw(o20));

use Data::Dumper;
print Dumper(paths());
