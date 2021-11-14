include <../lib/bearing.scad>

$fn=256;


od = get_bearing_outer_diameter(
    inner_diameter=30,
    roller_diameter1=6,
    roller_diameter2=4.4,
    wall_width=3,
    tolerance=0.2
);

union() {
    bearing(
        inner_diameter=30,
        height=6,
        roller_diameter1=6,
        roller_diameter2=4.4,
        wall_width=3,
        rim_height=1.6,
        tolerance=0.2,
        roller_hole=2
    );

    for(i = [0:3])
    rotate([0,0, 90*i])
    translate([16,0,0]) difference() {
        cylinder(r=6, h=6, center=true);
        cylinder(r=4, h=10, center=true);
        translate([0,-15,-15]) cube(30);
    }

    for(i = [0:3])
    rotate([0,0, 90*i])
    difference() {
        translate([od/2,0,0]) cylinder(r=10, h=6, center=true);
        translate([od/2,0,0]) cylinder(r=8, h=6.1, center=true);
        cylinder(r=od/2-0.1, h=10, center=true);
    }
}
