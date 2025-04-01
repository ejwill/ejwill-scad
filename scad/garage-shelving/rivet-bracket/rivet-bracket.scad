include <BOSL2/std.scad>
include <../../lib/mounting_backers.scad>

/* [Rivet] */
// Diameter of the rivet head
rivet_head_diameter =11.5;
// Height of the rivet head
rivet_head_height = 3;
// Diameter of the rivet shaft
rivet_shaft_diameter = 7.5;
// Height of the rivet shaft
rivet_shaft_height = 3; // [0:0.1:100]
//Distance between rivet heads
rivet_distance = 36.62; // [0:0.1:100]

/* [Backing] */
// Width of the backer
backWidth = 25; // [0:0.5:100]
// Height of the backer
backHeight = 50; // [1:0.5:100]
// Offset backer a side
isOffset = "No"; // [No, Right, Left]
// Offset distance from the backer to the item holder
offsetDistance = 0; // [0:0.1:100]


/*[Mounting]*/
Connection_Type = "Multiconnect"; // [Multipoint, Multiconnect, GOEWS]

/*[Slot Customization]*/
//Distance between Multiconnect slots on the back (25mm is standard for MultiBoard)
distanceBetweenSlots = 25;
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
onRampEveryXSlots = 1;

/* [Style Customizations] */
//Edge rounding (in mm)
// edgeRounding = 0.5; // [0:0.1:2]

/* [GOEWS Customization] */
GOEWS_Cleat_position = "normal"; // [normal, top, bottom, custom]
GOEWS_Cleat_custom_height_from_top_of_back = 11.24;

/* [Hidden] */
// backer dimensions
// backWidth = 25;
// backHeight = 50;
//back thickness
adj_backThickness = backThicknessCalc(backThicknessRequested = 0, Connection_Type);
edgeRounding = 0;



total_rivet_height = rivet_head_height + rivet_shaft_height;


// Function to create a rivet
module rivet() {
    // Rivet head
    // translate([0, 0, rivet_head_height])
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

// union() {
//     // Create rivets along the height of the backplate, spaced 36.62mm apart
//     for (i = [0:floor((backHeight - 13.4) / 36.62)]) {
//         rotate([-90, 0, 0]) {
//             translate([
//                 backWidth / 2, // Adjust rivet position based on offset
//                 -13.4 + i * -36.62, // Adjust forward position to prevent overlap with the backplate
//                 (total_rivet_height-2) / 2// Position rivets along the height
//             ])
//                 rivet();
//         }
//     }
    
//     // Adjust the backplate position based on the offset
//     translate([
//         (isOffset == "Right" ? offsetDistance : (isOffset == "Left" ? -offsetDistance : 0)),
//         (-total_rivet_height) / 2,
//         0
//     ])
//         makebackPlate(backWidth = backWidth, backHeight = backHeight, distanceBetweenSlots = distanceBetweenSlots, Connection_Type = Connection_Type);

//     // Add offset backings if needed
//     if (isOffset == "Right") {
//         translate([0, (-total_rivet_height) / 2, 0])
//             offsetBacking(isOffset);
//     } else if (isOffset == "Left") {
//         translate([0, (-total_rivet_height) / 2, 0])
//             offsetBacking(isOffset);
//     }
// }

module makeBracket() {
    union() {
        // Create rivets along the height of the backplate, spaced 36.62mm apart
        for (i = [0:floor((backHeight - 13.4) / 36.62)]) {
            rotate([-90, 0, 0]) {
                translate([
                    backWidth / 2, // Adjust rivet position based on offset
                    -13.4 + i * -36.62, // Adjust forward position to prevent overlap with the backplate
                    (total_rivet_height-2) / 2// Position rivets along the height
                ])
                    rivet();
            }
        }
        
        // Adjust the backplate position based on the offset
        translate([
            (isOffset == "Right" ? offsetDistance : (isOffset == "Left" ? (-offsetDistance) : 0)),
            (-total_rivet_height) / 2,
            0
        ])
            makebackPlate(backWidth = backWidth, backHeight = backHeight, distanceBetweenSlots = distanceBetweenSlots, Connection_Type = Connection_Type);

        // Add offset backings if needed
        if (isOffset == "Right") {
            translate([0, (-total_rivet_height) / 2, 0])
                offsetBacking(isOffset);
        } else if (isOffset == "Left") {
            translate([0, (-total_rivet_height) / 2, 0])
                offsetBacking(isOffset);
        }
    }
}

makeBracket();
