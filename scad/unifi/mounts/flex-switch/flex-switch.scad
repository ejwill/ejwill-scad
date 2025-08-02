include <BOSL2/std.scad>
include <BOSL2/threading.scad>
include <BOSL2/screws.scad>
include <../../../lib/mounting_backers_v2.scad>

$fn = 72;

/*[Mounting]*/
Connection_Type = "Multiconnect - Multiboard"; // [Multipoint, Multiconnect - Multiboard, Multiconnect - openGrid, Multiconnect - Custom Size, GOEWS, Command Strip, Screw]

/* [Backing Customizations] */
// Width of the backer
backWidth = 40.3; // [0:0.5:500]
// Height of the backer
backHeight = 125.66; // [1:0.5:500]
backThicknessRequested = 4.5; // [0:0.1:20]

/* [Slot Customization] */
multiConnectVersion = "v2"; // [v1, v2]
onRampHalfOffset = true;
//Distance between Multiconnect slots on the back (25mm is standard for MultiBoard)
customDistanceBetweenSlots = 25;
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
GOEWS_Cleat_Direction = "vertical"; // [horizontal, vertical]

/* [Multiconnect Customization] */
Multiconnect_Slot_Direction = "vertical"; // [vertical, horizontal]

/* [Mulitpoint Customization] */
Multipoint_Slot_Direction = "vertical"; // [vertical, horizontal]

/* [Screw Customization] */
// Specification for the screw used in the mounting plate
Screw_Specification = "M3,5"; // [M3,5, M4,8, M5,10]
// Type of the screw head
Screw_Head_Type = "flat"; // [flat, pan, round]
// Whether to use a counterbore for the screw hole
Screw_Counterbore = true; // [true, false] 


/* [Hidden] */
normalized_connection_type = normalizeConnectionType(Connection_Type); // Normalize the connection type
adj_backThickness = backThicknessCalc(backThicknessRequested = backThicknessRequested, normalized_connection_type);
edgeRounding = 0.5;
distanceBetweenSlots = distanceBetweenSlotsCalc(Connection_Type, customDistanceBetweenSlots = customDistanceBetweenSlots); // Distance between slots

//backThickness = backThicknessCalc(backThicknessRequested = 4.5, Connection_Type);

// mounting plate for the swtich
module plate(includeTabs = true) {
    // Base Plate
    width = 40.3; // Width of the plate
    length = 125.66; // Length of the plate
    thickness = 4.5; // Thickness of the plate

    // screw hole
    head_type = "flat"; // Type of the screw head
    counterbore = true; // Counterbore depth for the screw hole
    scew_spec = "M3,5"; // "1/4-20,.5"; // Screw specification

    scecond_tab_position = length-26.5-51.68-8.3; // Length of the second tab
    union() {
        // Main plate body
        translate([0, length/2, 0]) // Move down to place the plate on the ground
            if (normalized_connection_type == "Screw") {
                difference() {
                // The base plate
                    cuboid([width, length, adj_backThickness], anchor=BOTTOM, rounding=edgeRounding);
                    // The screw hole, attached to the TOP of the plate
                    translate([0, 42.5, adj_backThickness])
                        screw_hole(Screw_Specification, head=Screw_Head_Type, counterbore=Screw_Counterbore, anchor=TOP);
                    translate([0, -42.5, adj_backThickness])
                        screw_hole(Screw_Specification, head=Screw_Head_Type, counterbore=Screw_Counterbore, anchor=TOP);
                }
            }
            else if (normalized_connection_type == "Multiconnect"){
                if (Multiconnect_Slot_Direction == "vertical") {
                    rotate([90, 0, 0])  translate([-backWidth/2, adj_backThickness, -backHeight/2]) {
                        makebackPlate(backWidth = backWidth, backHeight = backHeight, backThickness = adj_backThickness, distanceBetweenSlots = distanceBetweenSlots, Connection_Type = Connection_Type);
                    }
                } 
                else if (Multiconnect_Slot_Direction == "horizontal") {
                    rotate([90, 0, 90])  translate([-backHeight/2, adj_backThickness, -backWidth/2]) {
                        makebackPlate(backWidth = backHeight, backHeight = backWidth, backThickness = adj_backThickness, distanceBetweenSlots = distanceBetweenSlots, Connection_Type = Connection_Type);
                    }
                }
            }
            else if (normalized_connection_type == "Multipoint") {
                if (Multipoint_Slot_Direction == "vertical") {
                    rotate([90, 0, 0])  translate([-backWidth/2, adj_backThickness, -backHeight/2]) {
                        makebackPlate(backWidth = backWidth, backHeight = backHeight, backThickness = adj_backThickness, distanceBetweenSlots = distanceBetweenSlots, Connection_Type = Connection_Type);
                    }
                } 
                else if (Multipoint_Slot_Direction == "horizontal") {
                    rotate([90, 0, 90])  translate([-backHeight/2, adj_backThickness, -backWidth/2]) {
                        makebackPlate(backWidth = backHeight, backHeight = backWidth, backThickness = adj_backThickness, distanceBetweenSlots = distanceBetweenSlots, Connection_Type = Connection_Type);
                    }
                }
            }
            else if (Connection_Type == "GOEWS") {
                // difference() {
                //     // The base plate
                //     rotate([90, 0, 0])  translate([-backWidth/2, adj_backThickness, -backHeight/2]) {
                //         makebackPlate(backWidth = backWidth, backHeight = backHeight, backThickness = adj_backThickness, distanceBetweenSlots = distanceBetweenSlots, Connection_Type = Connection_Type);
                //     }
                // }

                if(GOEWS_Cleat_Direction == "vertical") {
                    rotate([-90, 180, 0])  translate([-backWidth/2, adj_backThickness, -backHeight/2]) {
                        makebackPlate(backWidth = backWidth, backHeight = backHeight, backThickness = adj_backThickness, distanceBetweenSlots = distanceBetweenSlots, Connection_Type = Connection_Type);
                    }
                } else if (GOEWS_Cleat_Direction == "horizontal") {
                    rotate([90, 0, 90])  translate([-backHeight/2, adj_backThickness, -backWidth/2]) {
                        makebackPlate(backWidth = backHeight, backHeight = backWidth, backThickness = adj_backThickness, distanceBetweenSlots = distanceBetweenSlots, Connection_Type = Connection_Type);
                    }
                }
            }
            // difference() {
            //     // The base plate
            //     cuboid([width, length, thickness], anchor=BOTTOM, rounding=edgeRounding);
            //     // The screw hole, attached to the TOP of the plate
            //     translate([0, 42.5, thickness])
            //         screw_hole(scew_spec, head=head_type, counterbore=counterbore, anchor=TOP);
            //     translate([0, -42.5, thickness])
            //         screw_hole(scew_spec, head=head_type, counterbore=counterbore, anchor=TOP);
            // }
        
        // Mounting tabs
        if (includeTabs) {
            translate([0, length-26.5, adj_backThickness]) {
                rotate([0, 0, -90]) {
                    tab();
                }
            }
            translate([0, scecond_tab_position, adj_backThickness]) {
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
    tab_height = 3.4; // Height of the tab
    tab_length = 8.3; // Length of the tab
    tab_width = 13;
    tab_stem_width = 5.5; // this is the with of the tab that isn't cut out
    tab_arm_thickness = 1.66; // Thickness of the tab arm
    tab_arm_bottom_height = 2.1;

    union(){
        difference() {
            // Main tab body
            translate([tab_length/2, 0, 0]) {
                cuboid([tab_length, tab_width, tab_height], anchor=BOTTOM);
            }
            // Tab arm
            translate([(tab_length-tab_stem_width)/2, 0, 0]) {
                cuboid([(tab_length-tab_stem_width), tab_width, tab_arm_bottom_height], anchor=BOTTOM);
            }
        }
        // locking dot - centered in the tab body
        translate([tab_length-1.8, 0, tab_height]) {
            cylinder(h = 0.5, d = 1.4, $fn = 100);
        }
    }

    // Main tab body
    // cuboid([tab_length, tab_width, tab_height], anchor=BOTTOM);
    // // Tab arm
    // translate([tab_stem_width, 0, 0]) {
    //     cuboid([tab_arm_thickness, tab_width, tab_height], anchor=BOTTOM);
    // }
}

// tab();
plate(true);
// rotate([0, 0, 180]) {
// }
// rotate([90, 0, 0])  translate([-backWidth/2, 4.5, 0]) {
//     makebackPlate(backWidth = backWidth, backHeight = backHeight, distanceBetweenSlots = distanceBetweenSlots, Connection_Type = Connection_Type);
// }
// makebackPlate(backWidth = backWidth, backHeight = backHeight, distanceBetweenSlots = distanceBetweenSlots, Connection_Type = Connection_Type);

function backThicknessCalc(backThicknessRequested, mountingType) = 
    backThicknessRequested != 0 ? backThicknessRequested : 
    mountingType == "GOEWS" ? 7 :
    mountingType == "Multipoint" ? 4.8 :
    mountingType == "Multiconnect" ? 6.5 : 
    mountingType == "Screw" ? 4.5 :
    backThicknessRequested;

function normalizeConnectionType(connectionType) = 
    connectionType == "Multipoint" ? "Multipoint" :
    connectionType == "Multiconnect - Multiboard" ? "Multiconnect" :
    connectionType == "Multiconnect - openGrid" ? "Multiconnect" :
    connectionType == "Multiconnect - Custom Size" ? "Multiconnect" :
    connectionType == "GOEWS" ? "GOEWS" : 
    connectionType == "Command Strip" ? "Command Strip" : 
    "Unknown";

function distanceBetweenSlotsCalc(connectionType, customDistanceBetweenSlots) = 
    connectionType == "Multiconnect - openGrid" ? 28 :
    connectionType == "Multiconnect - Custom Size" ? customDistanceBetweenSlots :
    customDistanceBetweenSlots; //default for multipoint