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
This module is designed to create customizable mounting brackets compatible with popular mounting systems such as Multiconnect, Multipoint (Multiboard), and GOEWS for the rails of shelving.

Features:
- These brackets are intended for use on walls or shelving systems, such as Muscle Rack shelving, and are connected to the rails.
- Extensive customization options for backplate size and slot configurations.
- Supports features like quick-release slots, on-ramps for easier mounting, and adjustments for printer tolerances.
- Modular and adaptable design, making it suitable for a wide range of applications.

Changelog:
- v1.0: Initial version
*/

include <BOSL2/std.scad>
include <../../lib/mounting_backers.scad>

/*[Mounting]*/
Connection_Type = "Multiconnect"; // [Multipoint, Multiconnect, GOEWS]

/* [Backing Customizations] */
// Width of the backer
backWidth = 25; // [0:0.5:500]
// Height of the backer
backHeight = 56.3; // [1:0.1:500]

/* [Catch Options] */
// How wide the catch should be
catch_length = 5; // [0:0.1:50]
// How hight the catch should be
catch_height = 4; // [0:0.1:50]

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

/* [GOEWS Customization] */
GOEWS_Cleat_position = "normal"; // [normal, top, bottom, custom]
GOEWS_Cleat_custom_height_from_top_of_back = 11.24;

/* [Hidden] */
adj_backThickness = backThicknessCalc(backThicknessRequested = 0, Connection_Type);
edgeRounding = 0;

BACKING_POS = [backHeight/2,-backWidth/2,-0];

end_pos = (backHeight-catch_length)/2;

// create vectors for defining the catch and catch position
CATCH_DEF = [catch_length,backWidth,catch_height];
CATCH_POS = [-end_pos,0,-catch_height/2];
CATCH_CUT_POS = [(-backHeight+catch_length)/2+1,0,-1];

INVERT_X =[[-1,0,0],[0,1,0],[0,0,1]];
INVERT_Y =[[1,0,0],[0,-1,0],[0,0,1]];

$dl= 0.01;

module handle() {
    difference(){
        union(){
            translate(CATCH_POS)
            cuboid(CATCH_DEF, anchor = CENTER, rounding=2,
                edges=[BOTTOM],$fn=24){};
        
            translate(INVERT_X * CATCH_POS)
            cuboid(CATCH_DEF, anchor = CENTER, rounding=2,
                edges=[BOTTOM],$fn=24){};

            translate(BACKING_POS)
                rotate([-90,0,90])
                makebackPlate(backWidth = backWidth, backHeight = backHeight, backThickness = 0, distanceBetweenSlots = distanceBetweenSlots, Connection_Type = Connection_Type);
        }

        // make cutout for the catches
        translate(CATCH_CUT_POS)
        rotate([90,0,0])
        cuboid([catch_length-2, 2, backWidth], anchor = CENTER, except_edges=[TOP+FRONT, TOP+BACK], $fn=20);

        translate(INVERT_X * CATCH_CUT_POS)
        rotate([90,0,0])
        cuboid([catch_length-2, 2, backWidth], anchor = CENTER, except_edges=[TOP+FRONT, TOP+BACK], $fn=20);
    }
}

handle();