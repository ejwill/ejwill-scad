/*
Created by ejwill https://github.com/ejwill

This code is licensed Creative Commons 4.0 Attribution Non-Commercial Sharable with Attribution
References to Multipoint are for the Multiboard ecosystem by Jonathan at Keep Making. The Multipoint mount system is licensed under https://www.multiboard.io/license.

Credit to 
    @David D on Printables for Multiconnect
    Jonathan at Keep Making for Multiboard
    @SnazzyGreenWarrior on GitHub for their contributions on the Multipoint-compatible mount
    MrExo3D on Printables for the GOEWS system

Using this module:
This module is designed to create customizable mounting brackets compatible with popular mounting systems such as Multiconnect, Multipoint (Multiboard), and GOEWS.

Features:
- These brackets are intended for use on walls or shelving systems, such as Muscle Rack shelving, and are secured using rivets.
- Extensive customization options for rivet dimensions, backplate size, slot configurations, and offsets to suit various mounting needs.
- Supports features like quick-release slots, on-ramps for easier mounting, and adjustments for printer tolerances.
- Modular and adaptable design, making it suitable for a wide range of applications.

Changelog:
- v1.0: Initial version
- v1.1: 
    - Added support for rivets on the same side as the bracket
    - refactored rivet loop
    - code cleanup, optimization, and bug fixes
*/

include <BOSL2/std.scad>
include <../../lib/mounting_backers.scad>

/*[Mounting]*/
Connection_Type = "Multiconnect"; // [Multipoint, Multiconnect, GOEWS]

/* [Rivet Customiztions] */
// Diameter of the rivet head
rivet_head_diameter =11.5; // [0:0.1:50]
// Height of the rivet head
rivet_head_height = 3; // [0:0.1:50]
// Diameter of the rivet shaft
rivet_shaft_diameter = 7.5; // [0:0.1:50]
// Height of the rivet shaft
rivet_shaft_height = 3; // [0:0.1:50]
//Distance between rivet heads. This is the distance between the middle of the rivet heads
distance_between_rivets = 36.62; // [0:0.1:500]
//Initial rivet distance from the top of the backplate
initial_rivet_distance = 13.4; // [0:0.1:500]
//Place rivets on the same side as the bracket
rivet_on_same_side = false; // [true, false]

/* [Backing Customizations] */
// Width of the backer
backWidth = 25; // [0:0.5:500]
// Height of the backer
backHeight = 62.5; // [1:0.5:500]
// Offset backer a side
isOffset = "No"; // [No, Right, Left]
// Offset distance from the backer to the item holder
offsetDistance = 0; // [0:0.1:500]

/* [Slot Customization] */
onRampHalfOffset = true;
//Distance between Multiconnect slots on the back (25mm is standard for MultiBoard)
distanceBetweenSlots = 25;
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

/* [Style Customizations] */
//Edge rounding (in mm)
// edgeRounding = 0.5; // [0:0.1:2]

/* [GOEWS Customization] */
GOEWS_Cleat_position = "normal"; // [normal, top, bottom, custom]
GOEWS_Cleat_custom_height_from_top_of_back = 11.24;

/* [Hidden] */
adj_backThickness = backThicknessCalc(backThicknessRequested = 0, Connection_Type);
edgeRounding = 0;
total_rivet_height = rivet_head_height + rivet_shaft_height;


// Function to create a rivet
module round_rivet() {
    // Create the rivet head
    cyl(h = rivet_head_height, d = rivet_head_diameter, $fn = 100, anchor = FRONT+TOP){
        attach(BOTTOM, TOP)
            cyl(h = rivet_shaft_height, d = rivet_shaft_diameter, $fn = 100,);
    };
}

module offsetBacking(offsetDirection = "Right"){
    if(offsetDirection == "Right")
        translate([0, -adj_backThickness / 2, 0])
            rotate([90, 0, 0])
                cuboid([(offsetDistance), backHeight, adj_backThickness], rounding=edgeRounding, except_edges=[BOTTOM,RIGHT], anchor=FRONT+LEFT);
    else if(offsetDirection == "Left")
        translate([backWidth, -adj_backThickness / 2, 0])
            rotate([90, 0, 0])
                cuboid([(offsetDistance+1), backHeight, adj_backThickness], rounding=edgeRounding, except_edges=[BOTTOM,LEFT], anchor=FRONT+RIGHT);
}

module makeBracket() {
    union() {
        let(backHeight = max(backHeight, 25)) 
        {
            echo ("backHeight: ", backHeight);
            adj_rivet_y = rivet_on_same_side ? (total_rivet_height + adj_backThickness) : (total_rivet_height);

            if (!rivet_on_same_side) {
                for (rivetHeight = [ initial_rivet_distance : (distance_between_rivets + rivet_head_diameter) : backHeight ]) {
                    translate([
                        backWidth/2,  // X: outside edge of backplate
                        -(adj_backThickness + total_rivet_height),  // Y: behind the backplate
                        rivetHeight - rivet_head_diameter  // Z: vertical position
                    ])
                    rotate([90, 0, 0])  // Make rivet face into backplate (shaft points in -Y)
                        round_rivet();
                }
            }
            else {
                for (rivetHeight = [ initial_rivet_distance : (distance_between_rivets + rivet_head_diameter): backHeight ]){
                    rotate([ -90, 0, 0]) {
                        translate([
                            backWidth/2, // Adjust rivet position based on offset
                            rivetHeight * ( -1), // adjust the rivets position vertically along the bracket
                            total_rivet_height // adj_rivet_y // Position rivets away from the backplate
                        ])
                        round_rivet();
                    }
                }
            }

            // Adjust the backplate position based on the offset
            translate([(isOffset == "Right" ? offsetDistance : (isOffset == "Left" ? (-offsetDistance) : 0)),0,0])
                makebackPlate(backWidth = backWidth, backHeight = backHeight, distanceBetweenSlots = distanceBetweenSlots, Connection_Type = Connection_Type);

            // Add offset backings if needed
            if (isOffset == "Right") {
                offsetBacking(isOffset);
            } else if (isOffset == "Left") {
                offsetBacking(isOffset);
            }
        }
    }
}

makeBracket();