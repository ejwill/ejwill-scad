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
- v1.1: Added customizable catch height and thickness options
- v1.2: Migrated to mounting_backers_v2.scad for improved slot handling and added Multiconnect - openGrid and Multiconnect - Custom Size options
*/

include <BOSL2/std.scad>

/*[Mounting]*/
Connection_Type = "Multiconnect - openGrid"; // [Multipoint, Multiconnect - Multiboard, Multiconnect - openGrid, Multiconnect - Custom Size, GOEWS]

/* [Backing Customizations] */
// Width of the backer
back_width = 25; // [0:0.1:500]
// Height of the backer
backHeight = 56.0; // [1:0.1:500]

/* [Catch Options] */
// How long the catch should be
catch_length = 5; // [0:0.1:50]
// Catch Back wall thickness
catch_back_thickness = 1.7; // [0:0.1:10]
catch_floor_thickness = 1; // [0:0.1:20]
// Catch Opening Height
catch_opening_height = 2; // [0:0.1:50]
// Catch rounding
catch_rounding = 2; // [0:0.1:10]

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

/* [GOEWS Customization] */
GOEWS_Cleat_position = "normal"; // [normal, top, bottom, custom]
GOEWS_Cleat_custom_height_from_top_of_back = 11.24;

/* [Hidden] */
adj_backThickness = backThicknessCalc(backThicknessRequested = 0, Connection_Type);
distanceBetweenSlots = distanceBetweenSlotsCalc(Connection_Type, customDistanceBetweenSlots);
backWidth = max(back_width,distanceBetweenSlots);
edgeRounding = 0;
catch_height = catch_floor_thickness + catch_opening_height;

BACKING_POS = [backHeight/2,-backWidth/2,-0];

end_pos = (backHeight-catch_length)/2;

// create vectors for defining the catch and catch position
CATCH_DEF = [catch_length,backWidth,catch_height];
CATCH_POS = [-end_pos,0,-catch_height/2];
CATCH_CUT_POS = [-end_pos + (catch_back_thickness/2), 0, 0];

INVERT_X =[[-1,0,0],[0,1,0],[0,0,1]];
INVERT_Y =[[1,0,0],[0,-1,0],[0,0,1]];

debug = false;

$dl= 0.01;

module handle() {
    difference(){
        union(){
            translate(CATCH_POS)
            cuboid(CATCH_DEF, anchor = CENTER, rounding=catch_rounding,
                edges=[BOTTOM],$fn=24){};
        
            translate(INVERT_X * CATCH_POS)
            cuboid(CATCH_DEF, anchor = CENTER, rounding=catch_rounding,
                edges=[BOTTOM],$fn=24){};

            translate(BACKING_POS)
                rotate([-90,0,90])
                makebackPlate(backWidth = backWidth, backHeight = backHeight, backThickness = 0, distanceBetweenSlots = distanceBetweenSlots, Connection_Type = Connection_Type);
        }

        // make cutout for the catches
        translate(CATCH_CUT_POS)
        cuboid([catch_length - catch_back_thickness, backWidth, catch_opening_height], anchor = TOP+CENTER, except_edges=[TOP+FRONT, TOP+BACK], $fn=20);

        translate(INVERT_X * CATCH_CUT_POS)
        cuboid([catch_length - catch_back_thickness, backWidth, catch_opening_height], anchor = TOP+CENTER, except_edges=[TOP+FRONT, TOP+BACK], $fn=20);
    }
}

handle();

//Slotted back Module
module makebackPlate(backWidth, backHeight, distanceBetweenSlots = 25, backThickness = 0, slotStopFromBack = 13, onRampEveryXSlots = 1, Connection_Type = "Multiconnect")
{
    //slot count calculates how many slots can fit on the back. Based on internal width for buffer. 
    //slot width needs to be at least the distance between slot for at least 1 slot to generate
    let (
            backWidth = max(backWidth,distanceBetweenSlots), 
            backHeight = max(backHeight, 25),
            distanceBetweenSlots = distanceBetweenSlotsCalc(Connection_Type, customDistanceBetweenSlots),
            slotCount = floor(backWidth/distanceBetweenSlots)- subtractedSlots,
            backThickness = backThicknessCalc(backThicknessRequested = backThickness, Connection_Type),
            normalized_connection_type = normalizeConnectionType(Connection_Type)
        ){
        echo("connection type 1: ", normalized_connection_type);
        if(normalized_connection_type != "GOEWS"){
            difference() {
                echo("making back plate with connection type: ", normalized_connection_type);
                translate(v = [0,-backThickness,0]) 
                cuboid(size = [backWidth,backThickness,backHeight], rounding=edgeRounding, except_edges=BACK, anchor=FRONT+LEFT+BOT);
                //Loop through slots and center on the item
                //Note: I kept doing math until it looked right. It's possible this can be simplified.
                for (slotNum = [0:1:slotCount-1]) {
                    translate(v = [distanceBetweenSlots/2+(backWidth/distanceBetweenSlots-slotCount)*distanceBetweenSlots/2+slotNum*distanceBetweenSlots,-2.35+slotDepthMicroadjustment,backHeight-Multiconnect_Stop_Distance_From_Back]) {
                        if(normalized_connection_type == "Multipoint"){
                            echo("Multipoint Slot Tool");
                            multiPointSlotTool(backHeight, onRampEveryXSlots);
                        }
                        if(normalized_connection_type == "Multiconnect"){
                            echo("Multiconnect Slot Tool");
                            multiConnectSlotToolv2(backHeight, onRampEveryXSlots, distanceBetweenSlots);
                        }
                    }
                }
            }
        } else {
            // GOEWS
            GOEWS_Cleat_custom_height_from_top_of_back = (GOEWS_Cleat_position == "normal") ? 11.24 : (GOEWS_Cleat_position == "top") ? 0 :  (GOEWS_Cleat_position == "bottom") ? backHeight - 13.15 : GOEWS_Cleat_custom_height_from_top_of_back;
            
            difference() {
                union() {
                    // Back plate
                    translate(v = [0,-backThickness,0]) 
                    cuboid(size = [backWidth,backThickness,backHeight], rounding=edgeRounding, except_edges=BACK, anchor=FRONT+LEFT+BOT);
                    //Loop through slots and center on the item
                    //Note: I kept doing math until it looked right. It's possible this can be simplified.
                    // Add cleats
                    for (slotNum = [0:1:slotCount-1]) {
                        translate(v = [distanceBetweenSlots/2+(backWidth/distanceBetweenSlots-slotCount)*distanceBetweenSlots/2+slotNum*distanceBetweenSlots,-1 * backThickness,backHeight-GOEWS_Cleat_custom_height_from_top_of_back]) {
                            GOEWSCleatTool(backHeight);
                        }
                    }
                };
                // Remove back plate cut outs for screw threads
                for (slotNum = [0:1:slotCount-1]) {
                    translate(v = [distanceBetweenSlots/2+(backWidth/distanceBetweenSlots-slotCount)*distanceBetweenSlots/2+slotNum*distanceBetweenSlots, 0, backHeight + 0.46 - GOEWS_Cleat_custom_height_from_top_of_back + 11.24]) {
                        rotate([90, 0, 0])
                            cylinder(h = backThickness + 0.1, r = 7, $fn = 256);
                    }
                }
                // Remove back plate cut outs for screw heads
                for (slotNum = [0:1:slotCount-1]) {
                    translate(v = [distanceBetweenSlots/2+(backWidth/distanceBetweenSlots-slotCount)*distanceBetweenSlots/2+slotNum*distanceBetweenSlots, -4, backHeight + 0.46 - GOEWS_Cleat_custom_height_from_top_of_back + 11.24]) {
                        rotate([-90, 0, 0])
                            color("red") cube([5,5,5], center=true);
                            cylinder(h = 4.1, r = 10, $fn = 256);
                    }
                }
            }
        }
    }   
}


function backThicknessCalc(backThicknessRequested, mountingType) = 
    let(normalizedType = normalizeConnectionType(mountingType))
    backThicknessRequested != 0 ? backThicknessRequested : 
    normalizedType == "GOEWS" ? 7 :
    normalizedType == "Multipoint" ? 4.8 :
    normalizedType == "Multiconnect" ? 6.5 : 
    normalizedType == "Command Strip" ? 3.5 : // Command Strip is thinner
    backThicknessRequested;

function normalizeConnectionType(connectionType) = 
    connectionType == "Multipoint" ? "Multipoint" :
    connectionType == "Multiconnect - Multiboard" ? "Multiconnect" :
    connectionType == "Multiconnect - openGrid" ? "Multiconnect" :
    connectionType == "Multiconnect - Custom Size" ? "Multiconnect" :
    connectionType == "Multiconnect" ? "Multiconnect" :
    connectionType == "GOEWS" ? "GOEWS" : 
    connectionType == "Command Strip" ? "Command Strip" : 
    "Unknown";

// Function to calculate the distance between slots based on the connection type.
// Primarily used for Multiconnect and Multipoint systems.
function distanceBetweenSlotsCalc(connectionType, customDistanceBetweenSlots) = 
    connectionType == "Multiconnect - openGrid" ? 28 :
    connectionType == "Multiconnect - Custom Size" ? customDistanceBetweenSlots :
    customDistanceBetweenSlots; //default for multipoint

//Create GOEWS cleats
module GOEWSCleatTool(totalHeight) {
    difference() {
        // main profile
        rotate(a = [180,0,0]) 
            linear_extrude(height = 13.15) 
                let (cleatProfile = [[0,0],[15.1,0],[17.6,2.5],[15.1,5],[0,5]])
                union(){
                    polygon(points = cleatProfile);
                    mirror([1,0,0])
                        polygon(points = cleatProfile);
                };
        // angled slice off bottom
        translate([-17.6, -8, -26.3])
            rotate([45, 0, 0])
                translate([0, 5, 0])
                    cube([35.2, 10, 15]);
        // cutout
        translate([0, -0.005, 2.964])
            rotate([90, 0, 0])
                cylinder(h = 6, r = 9.5, $fn = 256);
    }
}

//Create Slot Tool
module multiConnectSlotToolv2(totalHeight, onRampEveryXSlots = 1, distanceBetweenSlots=25) {
    scale(v = slotTolerance)
    //slot minus optional dimple with optional on-ramp
    let (slotProfile = [[0,0],[10.15,0],[10.15,1.2121],[7.65,3.712],[7.65,5],[0,5]])
    difference() {
        union() {
            //round top
            rotate(a = [90,0,0,]) 
                rotate_extrude($fn=50) 
                    polygon(points = slotProfile);
            //long slot
            translate(v = [0,0,0]) 
                rotate(a = [180,0,0]) 
                union(){
                    difference() {
                        // Main half slot
                        linear_extrude(height = totalHeight+1) 
                            polygon(points = slotProfile);
                        
                        // Snap cutout
                        if (slotQuickRelease == false && multiConnectVersion == "v2")
                            translate(v= [10.15,0,0])
                            rotate(a= [-90,0,0])
                            linear_extrude(height = 5)  // match slot height (5mm)
                                polygon(points = [[0,0],[-0.4,0],[0,-8]]);  // triangle polygon with multiconnect v2 specs
                        }

                    mirror([1,0,0])
                        difference() {
                            // Main half slot
                            linear_extrude(height = totalHeight+1) 
                                polygon(points = slotProfile);
                            
                            // Snap cutout
                            if (slotQuickRelease == false && multiConnectVersion == "v2")
                                translate(v= [10.15,0,0])
                                rotate(a= [-90,0,0])
                                linear_extrude(height = 5)  // match slot height (5mm)
                                    polygon(points = [[0,0],[-0.4,0],[0,-8]]);  // triangle polygon with multiconnect v2 spec
                        }
                }
            //on-ramp
            if(onRampEnabled)
                for(y = [1:onRampEveryXSlots:totalHeight/distanceBetweenSlots])
                    translate(v = [0,-5,-y*distanceBetweenSlots]) 
                        rotate(a = [-90,0,0]) 
                            if (debug)
                                color(c = "orange") cylinder(h = 5, r1 = 12, r2 = 10.15);
                            else
                                cylinder(h = 5, r1 = 12, r2 = 10.15);
        }
        //dimple
        if (slotQuickRelease == false && multiConnectVersion == "v1")
            scale(v = dimpleScale) 
            rotate(a = [90,0,0,]) 
                rotate_extrude($fn=50) 
                    polygon(points = [[0,0],[0,1.5],[1.5,0]]);
    }
}

module multiconnectBack(backWidth, backHeight, distanceBetweenSlots, onRampEveryXSlots = 1)
{
    //slot count calculates how many slots can fit on the back. Based on internal width for buffer. 
    //slot width needs to be at least the distance between slot for at least 1 slot to generate
    let (
        backWidth = max(backWidth,distanceBetweenSlots),
        backHeight = max(backHeight, 25),
        slotCount = floor(backWidth/distanceBetweenSlots),
        backThickness = 6.5
    ){
        difference() {
            translate(v = [0,-backThickness,0]) 
            cube(size = [backWidth,backThickness,backHeight]);
            //Loop through slots and center on the item
            //Note: I kept doing math until it looked right. It's possible this can be simplified.
            for (slotNum = [0:1:slotCount-1]) {
                translate(v = [distanceBetweenSlots/2+(backWidth/distanceBetweenSlots-slotCount)*distanceBetweenSlots/2+slotNum*distanceBetweenSlots,-2.35+slotDepthMicroadjustment,backHeight-13]) {
                    if (debug)
                        color(c = "red") slotTool(backHeight);
                    else
                        slotTool(backHeight);
                }
            }
        }
    }
    //Create Slot Tool
    module slotTool(totalHeight) {
        scale(v = slotTolerance)
        //slot minus optional dimple with optional on-ramp
        let (slotProfile = [[0,0],[10.15,0],[10.15,1.2121],[7.65,3.712],[7.65,5],[0,5]])
        difference() {
            union() {
                //round top
                rotate(a = [90,0,0,]) 
                    rotate_extrude($fn=50) 
                        polygon(points = slotProfile);
                //long slot
                translate(v = [0,0,0]) 
                    rotate(a = [180,0,0]) 
                    union(){
                        difference() {
                            // Main half slot
                            linear_extrude(height = totalHeight+1) 
                                polygon(points = slotProfile);
                            
                            // Snap cutout
                            if (slotQuickRelease == false && multiConnectVersion == "v2")
                                translate(v= [10.15,0,0])
                                rotate(a= [-90,0,0])
                                linear_extrude(height = 5)  // match slot height (5mm)
                                    polygon(points = [[0,0],[-0.4,0],[0,-8]]);  // triangle polygon with multiconnect v2 specs
                            }

                        mirror([1,0,0])
                            difference() {
                                // Main half slot
                                linear_extrude(height = totalHeight+1) 
                                    polygon(points = slotProfile);
                                
                                // Snap cutout
                                if (slotQuickRelease == false && multiConnectVersion == "v2")
                                    translate(v= [10.15,0,0])
                                    rotate(a= [-90,0,0])
                                    linear_extrude(height = 5)  // match slot height (5mm)
                                        polygon(points = [[0,0],[-0.4,0],[0,-8]]);  // triangle polygon with multiconnect v2 spec
                            }
                    }
                //on-ramp
                if(onRampEnabled)
                    for(y = [1:onRampEveryXSlots:totalHeight/distanceBetweenSlots])
                        translate(v = [0,-5,-y*distanceBetweenSlots]) 
                            rotate(a = [-90,0,0]) 
                                color(c = "orange") cylinder(h = 5, r1 = 12, r2 = 10.15);
            }
            //dimple
            if (slotQuickRelease == false && multiConnectVersion == "v1")
                scale(v = dimpleScale) 
                rotate(a = [90,0,0,]) 
                    rotate_extrude($fn=50) 
                        polygon(points = [[0,0],[0,1.5],[1.5,0]]);
        }
    }
}

module multiPointSlotTool(totalHeight, onRampEveryXSlots = 1) {
    slotBaseRadius = 17.0 / 2.0;  // wider width of the inner part of the channel
    slotSkinRadius = 13.75 / 2.0;  // narrower part of the channel near the skin of the model
    slotBaseCatchDepth = .2;  // innermost before the chamfer, base to chamfer height
    slotBaseToSkinChamferDepth = 2.2;  // middle part of the chamfer
    slotSkinDepth = .1;  // top or skinmost part of the channel
    distanceOffset = onRampHalfOffset ? distanceBetweenSlots / 2 : 0;
    octogonScale = 1/sin(67.5);  // math convenience function to convert an octogon hypotenuse to the short length
    let (slotProfile = [
        [0,0],
        [slotBaseRadius,0],
        [slotBaseRadius, slotBaseCatchDepth],
        [slotSkinRadius, slotBaseCatchDepth + slotBaseToSkinChamferDepth],
        [slotSkinRadius, slotBaseCatchDepth + slotBaseToSkinChamferDepth + slotSkinDepth],
        [0, slotBaseCatchDepth + slotBaseToSkinChamferDepth + slotSkinDepth]
    ])
    union() {
        //octagonal top. difference on union because we need to support the dimples cut in.
        difference(){
            //union of top and rail.
            union(){
                scale([octogonScale,1,octogonScale])
                rotate(a = [90,67.5,0,]) 
                    rotate_extrude($fn=8) 
                        polygon(points = slotProfile);
                //long slot
                translate(v = [0,0,0]) 
                    rotate(a = [180,0,0]) 
                    linear_extrude(height = totalHeight+1) 
                        union(){
                            polygon(points = slotProfile);
                            mirror([1,0,0])
                                polygon(points = slotProfile);
                        }
            }
            //dimples on each catch point
            if (!slotQuickRelease){
                for(z = [1:onRampEveryXSlots:totalHeight/distanceBetweenSlots ])
                {
                    echo("building on z", z);
                    yMultipointSlotDimples(z, slotBaseRadius, distanceBetweenSlots, distanceOffset);
                }
            }
        }
        //on-ramp
        if(onRampEnabled)
            union(){
                for(y = [1:On_Ramp_Every_X_Slots:totalHeight/distanceBetweenSlots])
                {
                    // create the main entry hexagons
                    translate(v = [0,-5,(-y*distanceBetweenSlots)+distanceOffset])
                    scale([octogonScale,1,octogonScale])
                        rotate(a = [-90,67.5,0]) 
                            cylinder(h=5, r=slotBaseRadius, $fn=8);
                    
                // make the required "pop-in" locking channel dimples.
                xSlotDimples(y, slotBaseRadius, distanceBetweenSlots, distanceOffset);
                mirror([1,0,0])
                     xSlotDimples(y, slotBaseRadius, distanceBetweenSlots, distanceOffset);
                }
            }
    }
}

module xSlotDimples(y, slotBaseRadius, distanceBetweenSlots, distanceOffset){
    //Multipoint dimples are truncated (on top and side) pyramids
    //this function makes one pair of them
    dimple_pitch = 4.5 / 2; //distance between locking dimples
    difference(){
        translate(v = [slotBaseRadius-0.01,0,(-y*distanceBetweenSlots)+distanceOffset+dimple_pitch])
            rotate(a = [90,45,90]) 
            rotate_extrude($fn=4) 
                polygon(points = [[0,0],[0,1.5],[1.7,0]]);
        translate(v = [slotBaseRadius+.75, -2, (-y*distanceBetweenSlots)+distanceOffset-1])
                cube(4);
        translate(v = [slotBaseRadius-2, 0.01, (-y*distanceBetweenSlots)+distanceOffset-1])
                cube(7);
        }
        difference(){
        translate(v = [slotBaseRadius-0.01,0,(-y*distanceBetweenSlots)+distanceOffset-dimple_pitch])
            rotate(a = [90,45,90]) 
            rotate_extrude($fn=4) 
                polygon(points = [[0,0],[0,1.5],[1.7,0]]);
        translate(v = [slotBaseRadius+.75, -2.01, (-y*distanceBetweenSlots)+distanceOffset-3])
                cube(4);
        translate(v = [slotBaseRadius-2, 0.01, (-y*distanceBetweenSlots)+distanceOffset-5])
                cube(10);
        }
}
module yMultipointSlotDimples(z, slotBaseRadius, distanceBetweenSlots, distanceOffset){
    //This creates the multipoint point out dimples within the channel.
    octogonScale = 1/sin(67.5);
    difference(){
        translate(v = [0,0.01,((-z+.5)*distanceBetweenSlots)+distanceOffset])
            scale([octogonScale,1,octogonScale])
                rotate(a = [-90,67.5,0]) 
                    rotate_extrude($fn=8) 
                        polygon(points = [[0,0],[0,-1.5],[5,0]]);
        translate(v = [0,0,((-z+.5)*distanceBetweenSlots)+distanceOffset])
            cube([10,3,3], center=true);
        translate(v = [0,0,((-z+.5)*distanceBetweenSlots)+distanceOffset])
           cube([3,3,10], center=true);
    }
}   