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
*/

include <BOSL2/std.scad>

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
distance_between_rivets = 36.62; // [0:0.1:100]
//Initial rivet distance from the top of the backplate
initial_rivet_distance = 13.4; // [0:0.1:100]

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
        let(
            backHeight = max(backHeight, 25),
            initialRivetHeight = (-initial_rivet_distance - (rivet_head_height / 2)),
            distance_between_rivets_test = distance_between_rivets - rivet_head_diameter,
            rivetCount = floor((backHeight - abs(initialRivetHeight)) / (distance_between_rivets_test + (rivet_head_diameter/2)))) {
            echo ("backHeight: ", backHeight);
            echo ("rivetCount: ", rivetCount);
            echo ("initialRivetHeight: ", initialRivetHeight);

            for (i = [0:1:rivetCount]) {
            rotate([-90, 0, 0]) {
                translate([
                backWidth / 2, // Adjust rivet position based on offset
                initialRivetHeight + i * -(distance_between_rivets_test + rivet_head_diameter), // adjust the rivets position vertically along the bracket
                (total_rivet_height - 2) / 2 // Position rivets away from the backplate
                ])
                round_rivet();
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
}

rotate([180, 0, 0]) {
    makeBracket();
}

// Imported Modules and Functions //

//Slotted back Module
module makebackPlate(backWidth, backHeight, distanceBetweenSlots = 25, backThickness = 0, slotStopFromBack = 13, onRampEveryXSlots = 1, Connection_Type = "Multiconnect")
{
    //slot count calculates how many slots can fit on the back. Based on internal width for buffer. 
    //slot width needs to be at least the distance between slot for at least 1 slot to generate
    let (
            backWidth = max(backWidth,distanceBetweenSlots), 
            backHeight = max(backHeight, 25),
            slotCount = floor(backWidth/distanceBetweenSlots)- subtractedSlots,
            backThickness = backThicknessCalc(backThicknessRequested = backThickness, Connection_Type)
        ){
        if(Connection_Type != "GOEWS"){
            difference() {
                translate(v = [0,-backThickness,0]) 
                cuboid(size = [backWidth,backThickness,backHeight], rounding=edgeRounding, except_edges=BACK, anchor=FRONT+LEFT+BOT);
                //Loop through slots and center on the item
                //Note: I kept doing math until it looked right. It's possible this can be simplified.
                for (slotNum = [0:1:slotCount-1]) {
                    translate(v = [distanceBetweenSlots/2+(backWidth/distanceBetweenSlots-slotCount)*distanceBetweenSlots/2+slotNum*distanceBetweenSlots,-2.35+slotDepthMicroadjustment,backHeight-Multiconnect_Stop_Distance_From_Back]) {
                        if(Connection_Type == "Multipoint"){
                            multiPointSlotTool(backHeight, onRampEveryXSlots);
                        }
                        if(Connection_Type == "Multiconnect"){
                            multiConnectSlotTool(backHeight, onRampEveryXSlots);
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
                            cylinder(h = 4.1, r = 10, $fn = 256);
                    }
                }
            }
        }
    }   
}


function backThicknessCalc(backThicknessRequested, mountingType) = 
    backThicknessRequested != 0 ? backThicknessRequested : 
    mountingType == "GOEWS" ? 7 :
    mountingType == "Multipoint" ? 4.8 :
    mountingType == "Multiconnect" ? 6.5 : 
    backThicknessRequested;

// GOEWS

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

// MulitiConnect

//Create Slot Tool
module multiConnectSlotTool(totalHeight, onRampEveryXSlots = 1) {
    //In slotTool, added a new variable distanceOffset which is set by the option:
    distanceOffset = onRampHalfOffset ? distanceBetweenSlots / 2 : 0;
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
                linear_extrude(height = totalHeight+1) 
                    union(){
                        polygon(points = slotProfile);
                        mirror([1,0,0])
                            polygon(points = slotProfile);
                    }
            //on-ramp
            if(onRampEnabled)
                for(y = [1:onRampEveryXSlots:totalHeight/distanceBetweenSlots])
                    //then modify the translate within the on-ramp code to include the offset
                    translate(v = [0,-5,(-y*distanceBetweenSlots)+distanceOffset])
                        rotate(a = [-90,0,0]) 
                            cylinder(h = 5, r1 = 12, r2 = 10.15);
        }
        //dimple
        if (slotQuickRelease == false)
            scale(v = dimpleScale) 
            rotate(a = [90,0,0,]) 
                rotate_extrude($fn=50) 
                    polygon(points = [[0,0],[0,1.5],[1.5,0]]);
    }
}

// Multipoint

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