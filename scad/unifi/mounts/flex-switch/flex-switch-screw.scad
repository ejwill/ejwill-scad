include <BOSL2/std.scad>
include <BOSL2/threading.scad>
include <BOSL2/screws.scad>

/* [Plate Customizations] */
// Width of the plate
Width = 40.3; // [0:0.1:100]
// Length of the plate
Length = 125.66; // [0:0.1:200]
// Thickness of the backer
Back_Thickness = 4.5; // [0:0.1:20]
// Rounding of the edges
Edge_Rounding = 0.5; // [0:0.1:5]

/* [Tab Customizations] */
// Width of the tab
Tab_Width = 13; // [0:0.1:20]
// Height of the tab
Tab_Height = 3.4; // [0:0.1:10]
// Length of the tab
Tab_Length = 8.5; // [0:0.1:20]
// Width of the tab stem
Tab_Stem_Width = 5.5; // [0:0.1:20]
// Thickness of the tab arm
Tab_Arm_Thickness = 1.66; // [0:0.01:10]
// Height of the tab arm bottom
Tab_Arm_Bottom_Height = 2.1; // [0:0.1:10]
// Include locking dot in the tab
Tab_Locking_Dot = true; // [false, true]

/* [Screw Customization] */
// Specification for the screw used in the mounting plate
Screw_Specification = "M3.5"; // [M2: M2, M2.5:M2.5, M3: M3, M3.5: M3.5, M4: M4, M5: M5, M6: M6, M7: M7 - Special Case, M8: M8,  #4: #4, #6: #6, #8: #8, #10: #10, #12: #12, 1/4: 1/4, 5/16: 5/16]
// Type of the screw head
Screw_Head_Type = "flat"; // [flat, pan, round]
// Whether to use a counterbore for the screw hole
Screw_Counterbore = true; // [true, false] 
// Shift the right screw hole position slightly
Shift_Right_Screw_Hole = 0.0; // [-5:0.1:5] // Shift the screw hole position slightly
// Shift the left screw hole position slightly
Shift_Left_Screw_Hole = 0.0; // [-5:0.1:5] // Shift the screw hole position slightly

/* [Hidden] */
$fn = 72;

// mounting plate for the swtich
module plate(includeTabs = true) {
    // Base Plate
    // width = 40.3; // Width of the plate
    // length = 125.66; // Length of the plate
    // thickness = 4.5; // Thickness of the plate

    // screw hole
    // head_type = "flat"; // Type of the screw head
    // counterbore = true; // Counterbore depth for the screw hole
    // scew_spec = "M3,5"; // "1/4-20,.5"; // Screw specification

    scecond_tab_position = Length-26.5-51.68-8.3; // Length of the second tab
    union() {
        // Main plate body
        translate([0, Length/2, 0]) // Move down to place the plate on the ground
            difference() {
            // The base plate
                cuboid([Width, Length, Back_Thickness], anchor=BOTTOM, rounding=Edge_Rounding);
                // The screw hole, attached to the TOP of the plate
                translate([0, (42.5 + Shift_Right_Screw_Hole), Back_Thickness])
                    screw_hole(Screw_Specification, head=Screw_Head_Type, counterbore=Screw_Counterbore, thread=false, l=Back_Thickness+0.2, anchor=TOP);
                translate([0, (-42.5 - Shift_Left_Screw_Hole), Back_Thickness])
                    screw_hole(Screw_Specification, head=Screw_Head_Type, counterbore=Screw_Counterbore, thread=false, l=Back_Thickness+0.2, anchor=TOP);
            }
        // Mounting tabs
        if (includeTabs) {
            translate([0, Length-26.5, Back_Thickness]) {
                rotate([0, 0, -90]) {
                    tab();
                }
            }
            translate([0, scecond_tab_position, Back_Thickness]) {
                rotate([0, 0, -90]) {
                    tab();
                }
            }
        }
    }
}

// mounting tab for the switch.
// look like a L shape with a tab on the end
module tab(){
    // tab_height = 3.4; // Height of the tab
    // tab_length = 8.5; // Length of the tab
    // tab_width = 13;
    // tab_stem_width = 5.5; // this is the with of the tab that isn't cut out
    // tab_arm_thickness = 1.66; // Thickness of the tab arm
    // tab_arm_bottom_height = 2.1;

    union(){
        difference() {
            // Main tab body
            translate([Tab_Length/2, 0, 0]) {
                cuboid([Tab_Length, Tab_Width, Tab_Height], anchor=BOTTOM);
            }
            // Tab arm
            translate([(Tab_Length-Tab_Stem_Width)/2, 0, 0]) {
                cuboid([(Tab_Length-Tab_Stem_Width), Tab_Width, Tab_Arm_Bottom_Height], anchor=BOTTOM);
            }
        }

        if (Tab_Locking_Dot) {
            // locking dot - centered in the tab body
            translate([Tab_Length-1.8, 0, Tab_Height]) {
                cylinder(h = 0.8, d = 1.4, $fn = 100);
            }
        }
    }
}

plate(true);