/*
 * Bearing module
 * ==============
 *
 * This module provides geometry and utility functions related
 * to generating bearing geometry
 */

function get_inner_rail_offset(
    inner_diameter=60,
    wall_width=3,
    roller_diameter1=6,
    roller_diameter2=3
) = inner_diameter / 2 +
    wall_width +
    ((roller_diameter1 - roller_diameter2) / 2);

function get_roller_perimeter(inner_rail_offset = 0, tolerance = 0.15, roller_diameter2) =
    inner_rail_offset + (roller_diameter2 / 2) + tolerance;

function get_rolls_num(small_radius, big_radius, tolerance) = 
    floor(PI / asin(((small_radius + (tolerance / 2)) / big_radius) * (PI / 180)));

function get_rail_thickness(wall_width=1, roller_diameter1=2, roller_diameter2=1) =
    wall_width + ((roller_diameter1 - roller_diameter2) / 2);

function get_bearing_outer_diameter(
    inner_diameter = 60,
    roller_diameter1=6,
    roller_diameter2=3,
    wall_width=3,
    tolerance = 0.15
) =
    get_rail_thickness(
        wall_width=wall_width,
        roller_diameter1=roller_diameter1,
        roller_diameter2=roller_diameter2
    ) * 4
    + (tolerance * 4)
    + (roller_diameter2 * 2)
    + inner_diameter;

module rail_2d_poly(
    roller_diameter1=6,
    roller_diameter2=3,
    wall_width=3,
    height=6,
    rim_height=0.8
) {
    section_height = height / 2;
    rim_thickness = get_rail_thickness(
        wall_width=wall_width,
        roller_diameter1=roller_diameter1,
        roller_diameter2=roller_diameter2
    );
    rim_offset = rim_height / 2;

    base_points = [
        [0, section_height],
        [wall_width, section_height],
        [rim_thickness, rim_offset],
        [rim_thickness, -rim_offset],
        [wall_width, -section_height],
        [0, -section_height],
    ];

    translate([-rim_thickness,0,0]) polygon(points=base_points);
}

module roller_2d_poly(
    roller_diameter1=6,
    roller_diameter2=3,
    hole=0,
    height=6,
    rim_height=0.8
) {
    section_height = height / 2;
    roller_perimeter1 = roller_diameter1 / 2;
    rim_thickness = roller_diameter2 / 2;
    rim_offset = rim_height / 2;
    x_offset = hole / 2;

    base_points = [
        [x_offset, section_height],
        [roller_perimeter1, section_height],
        [rim_thickness, rim_offset],
        [rim_thickness, -rim_offset],
        [roller_perimeter1, -section_height],
        [x_offset, -section_height]
    ];

    polygon(points=base_points);
}

module rails(
    inner_diameter = 60,
    roller_diameter1=6,
    roller_diameter2=3,
    wall_width=3,
    height=6,
    rim_height=0.8,
    tolerance = 0.15
) {
    inner_rail_offset = get_inner_rail_offset(
        inner_diameter=inner_diameter,
        roller_diameter1=roller_diameter1,
        roller_diameter2=roller_diameter2,
        wall_width=wall_width
    );

   roller_perimeter = get_roller_perimeter(
        inner_rail_offset=inner_rail_offset,
        roller_diameter2=roller_diameter2,
        tolerance=tolerance
    );

    outer_rail_x_offset = 
        roller_perimeter + 
        (roller_diameter2 / 2) + 
        tolerance;

    union() {
        rotate_extrude(angle=360)
            translate([inner_rail_offset, 0, 0])
            rail_2d_poly(
                roller_diameter1=roller_diameter1,
                roller_diameter2=roller_diameter2,
                wall_width=wall_width,
                height=height,
                rim_height=rim_height
            );

        rotate_extrude(angle=360)
            translate([outer_rail_x_offset, 0, 0])
            rotate([0,180,0])
            rail_2d_poly(
                roller_diameter1=roller_diameter1,
                roller_diameter2=roller_diameter2,
                wall_width=wall_width,
                height=height,
                rim_height=rim_height
            );
    }
}

module roller(
    roller_diameter1=6,
    roller_diameter2=3,
    height=6,
    roller_hole=0,
    rim_height=0.8
) {
    rotate_extrude(angle=360) roller_2d_poly(
        roller_diameter1=roller_diameter1,
        roller_diameter2=roller_diameter2,
        height=height,
        hole=roller_hole,
        rim_height=rim_height
    );
}

module bearing(
    inner_diameter = 60,
    roller_diameter1=6,
    roller_diameter2=3,
    wall_width=3,
    height=6,
    rim_height=0.8,
    roller_hole=0,
    tolerance = 0.15
) {
    inner_rail_offset = get_inner_rail_offset(
        inner_diameter=inner_diameter,
        roller_diameter1=roller_diameter1,
        roller_diameter2=roller_diameter2,
        wall_width=wall_width
    );

    roller_perimeter = get_roller_perimeter(
        inner_rail_offset=inner_rail_offset,
        roller_diameter2=roller_diameter2,
        tolerance=tolerance
    );

    number_of_rolls = get_rolls_num(
        roller_diameter1 / 2,
        roller_perimeter,
        tolerance
    );

    rotate_angle = 360/number_of_rolls;

    echo(str("roller_perimeter: ", roller_perimeter));
    echo(str("Number of rollers: ", number_of_rolls));

    union() {
        rails(
            inner_diameter=inner_diameter,
            roller_diameter1=roller_diameter1,
            roller_diameter2=roller_diameter2,
            wall_width=wall_width,
            height=height,
            rim_height=rim_height,
            tolerance=tolerance
        );
        for(i = [0:number_of_rolls])
        rotate([0,0, i * rotate_angle])
        translate([roller_perimeter,0,0]) roller(
            roller_diameter1=roller_diameter1,
            roller_diameter2=roller_diameter2,
            height=height,
            roller_hole=roller_hole,
            rim_height=rim_height
        ); 
    }
}

module bearing_cross_section(
    inner_diameter = 60,
    roller_diameter1=6,
    roller_diameter2=3,
    wall_width=3,
    height=6,
    rim_height=0.8,
    roller_hole=0,
    tolerance = 0.15
) {
    intersection() {
        bearing(
            inner_diameter = inner_diameter,
            roller_diameter1 = roller_diameter1,
            roller_diameter2 = roller_diameter2,
            wall_width = wall_width,
            height = height,
            rim_height = rim_height,
            roller_hole = roller_hole,
            tolerance = tolerance
        );

        translate([250,250,0]) cube(500, center=true);
    }
}
