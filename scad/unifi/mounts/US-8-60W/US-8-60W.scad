/************** Mount for Ubiquiti UniFi US-8-60W Switch *******************
*
* Updated By ejwill https://github.com/ejwill/ejwill-scad
* 
* Description:
* This is a customizable mount for the Ubiquiti UniFi US-8-60W Switch.
*
* Licesnse: Creative Commons - Attribution - Share Alike
*           https://creativecommons.org/licenses/by-sa/4.0/
*
* Version: 1.0.0
*******************************************************************************/

include <BOSL2/std.scad>
include <BOSL2/screws.scad>
include <BOSL2/threading.scad>
include <../../../lib/mounting_backers_v2.scad>

/* [Customizations] */
// Thickness of the backer
Back_Thickness = 4.5; // [0:0.1:20]
// Rounding of the edges
// Edge_Rounding = 0.5; // [0:0.1:5]
// Width of the plate
Width = 99.5; // [0:0.1:150]
// Length of the plate
Length = 148; // [0:0.1:200]
// Orientation of the mount
orientation = "vertical"; // [vertical, horizontal]

/* [Slot Customization] */
multiConnectVersion = "v2"; // [v1, v2]
onRampHalfOffset = true;
//Distance between Multiconnect slots on the back (25mm is standard for MultiBoard)
// customDistanceBetweenSlots = 25;
//Reduce the number of slots
subtractedSlots = 0;
//QuickRelease removes the small indent in the top of the slots that lock the part into place
slotQuickRelease = false;
//Dimple scale tweaks the size of the dimple in the slot for printers that need a larger dimple to print correctly
dimpleScale = 1; //[0.5:.05:1.5]
//Scale the size of slots in the back (1.015 scale is default for a tight fit. Increase if your finding poor fit. )
slotTolerance = 1.00; //[0.925:0.005:1.075]
//Move the slot in (positive) or out (negative)
slotDepthMicroadjustment = 0; //[-.5:0.05:.5]
//enable a slot on-ramp for easy mounting of tall items
onRampEnabled = true;
//frequency of slots for on-ramp. 1 = every slot; 2 = every 2 slots; etc.
On_Ramp_Every_X_Slots = 1;
//Distance from the back of the item holder to where the multiconnect stops (i.e., where the dimple is) (by mm)
Multiconnect_Stop_Distance_From_Back = 13;

/* [Mounting] */
Connection_Type = "Multiconnect - Multiboard"; // [Multipoint, Multiconnect - Multiboard, Multiconnect - openGrid, Multiconnect - Custom Size, GOEWS, Command Strip]

/* [Keyhole Peg] */
// Head diameter (fits into keyhole round part)
head_diameter=7.5; // [0:0.1:20]
// Head height (length of the head)
head_height=2.6; // [0:0.1:10]
// Neck diameter (fits into slot)
neck_diameter=4; // [0:0.1:10]
// Neck height (length of the neck)
neck_height=3; // [0:0.1:10]
//Distance to place the peg from the edge of the mount. Y Axis
distance_from_edge=37.5; // [0:0.1:150]
//Distance to place the peg from the edge of the mount. X Axis
distance_from_edge_x=35; // [0:0.1:150]
//Number of pegs to use for the mount
number_of_pegs=2; // [1:1:20]
// Distance between pegs (for multi-peg mounts)
distance_between_pegs=73.5; //[0:0.1:150]
// Size of chamfer on the neck. Top and bottom
chamfer_percent = 0.25; // [0:0.01:1]

/* [Hidden] */
$fn = 72;
chamfer_size = neck_diameter * 0.25;

module mount(orientation = "vertical"){
    let(
        back_width = (orientation == "vertical") ? Width : Length,
        back_height = (orientation == "vertical") ? Length : Width
    ){
        makebackPlate(backWidth = back_width, backHeight = back_height, backThickness = Back_Thickness, Connection_Type = Connection_Type);
    }
}

module keyhole_peg(head_d=10, neck_d=5, neck_h=8, head_h=3, flange_d=12, flange_t=2) {
    union() {
        // Flange/stop (at base)
        cylinder(d=flange_d, h=flange_t, $fn=48);
        // Neck (on top of flange)
        translate([0, 0, flange_t])
            cylinder(d=neck_d, h=neck_h, $fn=32);
        // Head (on top of neck)
        translate([0, 0, flange_t + neck_h])
            cylinder(d=head_d, h=head_h, $fn=48);
    }
}

module keyhole_peg_chamfer(head_d=10, neck_d=5, neck_h=8, head_h=3, chamfer_size=1) {
// Neck with outward flare at both ends
// Neck geometry
    cyl(d=neck_d, h=neck_h,
        chamfer1=-chamfer_size,   // flare into mount
        chamfer2=-chamfer_size,   // flare into head
        $fn=32, anchor=BOTTOM){
            position(TOP) {
                cyl(d=head_d, h=head_h,
                    $fn=48, anchor=BOTTOM);
                }
    }
}

for(i = [0:number_of_pegs-1]) {
    translate([
        distance_from_edge_x + i * distance_between_pegs,
        -Width + distance_from_edge,
        0
    ])
        // keyhole_peg(
        //     head_d=head_diameter,
        //     head_h=head_height,
        //     neck_d=neck_diameter,
        //     neck_h=neck_height,
        //     flange_d=flange_diameter,
        //     flange_t=flange_thickness
        // );
        keyhole_peg_chamfer(
            head_d=head_diameter,
            head_h=head_height,
            neck_d=neck_diameter,
            neck_h=neck_height,
            chamfer_size=chamfer_size
        );
}


backRotation = (orientation == "vertical") ? [90, 0, 90] : [90, 0, 0];
backPosition = (orientation == "vertical") ? [-Width, 0, 0] : [0, 0, 0];

// rotate the mount flat against the ground
rotate(a = backRotation)
    // translate(v = [0,0,-Back_Thickness]) // move it down to
    translate(v = backPosition) // move it down to avoid z-fightingå -Back_Thickness+0.1
        // call the mount module
        mount(orientation);