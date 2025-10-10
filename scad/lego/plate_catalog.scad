// === Plate Catalog: all permutations that fit in a 3x3 ===
// Assumes the uploaded file is alongside this file or adjust the path:
include <brick-customizer.scad>;

/* [General] */
// studs (X)
max_w = 3;
// studs (Y)
max_l = 3;
// LEGO plate is 1/3 brick height
plate_ratio = 1; // [.33333333333:1/3, .5:1/2, 1:1, 1.5:1 1/2, 2:2, 3:3, 4:4, 5:5, 6:6, 7:7, 8:8, 9:9, 10:10]
// keep "lego" dimensions
brand = "lego";
// spacing (mm) between samples
pad = 12;
// LEGO stud pitch (mm); consistent with the file
pitch = 8;
// toggle text labels
show_labels = true;
// make all plates tiles (no studs on top)
block_type = "brick"; // [brick:Brick, tile:Tile, wing:Wing, slope:Slope, curve:Curve, baseplate:Baseplate, round:Round]
// omit studs on top (for faster rendering)
skip_studs = false;
wall_splines_rescale = 1.00; // [0.01:0.01:1.00]
include_wall_splines = true; // [true,false]
include_reinforcement = false; // [true,false]
stud_notches = true; // [true,false]
stud_rescale = 1.03; // [0.01:0.01:3.00]
stud_cut_rescale = 0.01; // [0.0:0.01:0.49]
wall_splines_rescale = 0.3; // [0.01:0.01:1.49]
$fn = 100;

// Render all permutations up to 3x3 at 1/3 height
module plate(w, l) {
    // minimal, sane defaults—everything else uses the library's computed dims
    block(
        width=w,
        length=l,
        height=plate_ratio,
        type=block_type,                 // studs on top (tile would be flat)
        brand=brand,
        stud_type="solid",
        include_wall_splines=include_wall_splines,    // helps small plates print sturdier
        // reinforcement=(plate_ratio < 1 ? true : false),
        stud_rescale=stud_rescale,
        stud_cut_rescale=stud_cut_rescale,
        stud_top_roundness=0,
        skip_studs = skip_studs,
        stud_notches = stud_notches,
        reinforcement = include_reinforcement,
        wall_splines_rescale = wall_splines_rescale
    );
}

// layout grid with consistent spacing
module catalog() {
    // Store all unique combinations
    combinations = [
        [1,1],  // 1x1
        [1,2],  // 1x2
        [1,3],  // 1x3
        [1,4],  // 1x4
        [2,1],  // 2x1
        [2,2],  // 2x2
        [2,3],  // 2x3
        [3,3],   // 3x3
        [4,1],  // 3x2
        [4,2],  // 3x3
        [4,3],   // 3x3
        [4,4]

    ];
    
    for (i = [0:len(combinations)-1]) {
        w = combinations[i][0];
        l = combinations[i][1];
        
        translate([
            (i % 3) * (30),   // 3 columns
            floor(i / 3) * (30),
            0
        ]) {
            plate(w,l);
            if (show_labels) {
                translate([-4, -6, plate_ratio * compute_block_height("tile", brand) + 0.1])
                    color("black")
                        linear_extrude(0.8)
                            text(str(w,"x",l), size=5, halign="left", valign="baseline");
            }
        }
    }
}

catalog();