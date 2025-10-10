/* 
OpenGrid Snap
Design by David D
OpenSCAD by metasyntactic

This code is Licensed Creative Commons 4.0 Attribution Non-Commercial Share-Alike (CC-BY)
Derived parts are licensed Creative Commons 4.0 Attribution (CC-BY)

Change Log:
- 2025- 
    - Initial release

Credit to 
    @David D on Printables for openGrid
    Katie and her community at Hands on Katie on Youtube, Patreon, and Discord
*/

include <BOSL2/std.scad>

/*[Base Parameters]*/
studsWide = 3;
studsDeep = 5;
//Diameter of each stud (in mm). Standard is 4.8mm
studDiameter = 4.85;
baseThickness = 2.0; //[-10:0.1:10]
/*[Scanp]*/
snap_type = "lite"; // [lite, full]
directional = true; // [true, false]
/* [Stud] */
// How many studs should be rounded at the corners?
round_radius = 3;
// Should the rounded edges be notched to accept studs below?
round_stud_notches = "yes";
// What stud type do you want? Hollow studs allow rods to be pushed into the stud.
stud_type = "solid"; // [solid:Solid, hollow:Hollow]
stud_rescale = 1.00; // [0.51:0.01:1.49]
stud_top_roundness = 0; // [0:0.01:1]
// What brand of block should this be? LEGO for regular LEGO bricks, Duplo for the toddler-focused larger bricks.
block_brand = "lego"; // [lego:LEGO, duplo:DUPLO]
/*[Hidden]*/
studHeight = 1.8;
distanceBetweenStuds = 8;
studToSide = 7.9;
brand = block_brand;
post_wall_thickness = (brand == "lego" ? 0.85 : 1);
wall_thickness=(brand == "lego" ? 1.45 : 1.5);
stud_diameter=(brand == "lego" ? 4.85 : 9.40);
hollow_stud_inner_diameter = (brand == "lego" ? 3.1 : 6.7);
pin_diameter=(brand == "lego" ? 3 : 3 * 2);
post_diameter=(brand == "lego" ? 6.5 : 13.2);
cylinder_precision=(brand == "lego" ? 0.1 : 0.05);
reinforcing_width = (brand == "lego" ? 0.7 : 1);
stud_height=(brand == "lego" ? 1.8 : 4.4);
stud_spacing=(brand == "lego" ? 8 : 8 * 2);

adjStudDiameter = studDiameter * stud_rescale;

$fn = 100;

baseX = (studsWide-2)*distanceBetweenStuds+studToSide*2;
baseY = (studsDeep-2)*distanceBetweenStuds+studToSide*2;

module openGridSnap(lite=false, directional=false, orient, anchor, spin){
	module openGridSnapNub(w, nub_h, nub_w, nub_d, b_y, top_wedge_h, bot_wedge_h, r_x, r_r, r_s){
		move([w/2, 0, 0]) 
		intersection(){
			difference(){
				//bounding box
				zmove(nub_h) cuboid([nub_d,nub_w,2-nub_h], anchor=CENTER+LEFT+BOTTOM) ;
				//top part
				zmove(2) rotate([0,180,90]) wedge([nub_w,nub_d,top_wedge_h], anchor=CENTER+BOTTOM+BACK);
				//bottom part
				zmove(nub_h) rotate([0,0,90]) ymove(b_y) wedge([nub_w,0.4,bot_wedge_h], anchor=CENTER+BOTTOM+BACK);
			};
			//rounding
			xmove(r_x) yscale(r_s) cyl($fn=600, r=r_r, h=2, anchor=BOTTOM);
		};
	}

	w=24.80;
	fulldiff=3.4;
	h=lite ? 3.4 : fulldiff*2;
	attachable(orient=orient, anchor=anchor, spin=spin, size=[w,w,h]){
		zmove(-h/2) difference(){
			core=3 + (lite ? 0 : fulldiff);
			top_h=0.4; 
			top_nub_h=1.1;

			union() {
				//top
				zmove(h-top_h) cuboid([w,w,top_h], rounding=3.262743, edges="Z", $fn=2, anchor=BOTTOM);
				// core
				cuboid([w,w,core], rounding=4.81837, edges="Z", $fn=2, anchor=BOTTOM);
				//top nub
				offs=2.02;
				intersection(){
					zmove(core-top_nub_h) cuboid([w,w,top_nub_h], rounding=3.262743, edges="Z", $fn=2, anchor=BOTTOM);
					zrot_copies(n=4) move([w/2-offs,w/2-offs,core]) rotate([180, 0, 135]) wedge(size=[6.817,top_nub_h,top_nub_h], anchor=CENTER+BOTTOM);
				};
				//bottom nub
				zmove(lite ? 0 : fulldiff) zrot_copies(n=4)
					if (!directional || ($idx==1 || $idx==3))
					openGridSnapNub(
						w=w,
						nub_h=0.2,
						nub_w=11,
						nub_d=0.4,
						top_wedge_h=0.6,
						bot_wedge_h=0.6,
						r_x=-12.36,
						r_s=1.36,
						r_r=13.025,
						b_y=-0
					);
				//directional nubs 
				 if (directional) {
					//front directional nub
					zmove(lite ? 0 : fulldiff) openGridSnapNub(
						w=w,
						nub_h=0,
						nub_w=14,
						nub_d=0.8,
						top_wedge_h=1.0,
						bot_wedge_h=0.4,
						r_x=-11.75,
						r_s=1.26,
						r_r=13.025,
						b_y=-0.4
					);
					 
					//rear directional nub
					zrot(180) zmove(lite ? 0 : fulldiff) openGridSnapNub(
						w=w,
						nub_h=0.65,
						nub_w=10.8,
						nub_d=0.4,
						top_wedge_h=0.6,
						bot_wedge_h=0.6,
						r_x=-12.41,
						r_s=1.37,
						r_r=13.025,
						b_y=0
					);
				};
			};
			//bottom click holes
			zrot_copies(n=4)
				move([w/2-1, 0, 0])
				if (!directional || $idx==1 || $idx==3)
					cuboid([0.6,12.4,2.8 + (lite ? 0 : fulldiff)], rounding=0.3, $fn=100, edges="Z", anchor=BOTTOM);
			//bottom click holes for rear directional
			if (directional) {
				zrot(180) move([w/2-1, 0, 0.599]) cuboid([0.6, 12.4, 2.2 + (lite ? 0 : fulldiff) ], rounding=0.3, $fn=100, edges="Z", anchor=BOTTOM);
				zrot(180) move([w/2-1.2, 0, 0]) prismoid(size1=[0.6, 12.4], size2=[0.6, 12.4], h=0.6, shift=[0.2,0], rounding=0.3, $fn=100);
				zrot(180) move([w/2-0.1, 0, 0]) rotate([0,0,0]) prismoid(size1=[0.2, 20], size2=[0, 20], shift=[0.1,0], h=0.6, anchor=BOTTOM);
			};

			//bottom wall click holes
			zrot_copies(n=4)
				move([w/2, 0, 2.2 + (lite ? 0 : fulldiff)])
				if (!directional || ($idx>0))
					cuboid([1.4,12,0.4], anchor=BOTTOM);

			//directional indicator
			if (directional) move([9.5,0,0]) cylinder(r1=2, r2=1.5, h=0.4, $fn=2);
		};
		children();
	};
};

module stud() {
    stud_top_height=1;
    stud_body_height=(stud_top_roundness != 0) ? (stud_height - stud_top_height) : stud_height;
    difference() {
        union() {
            cylinder(r=(stud_diameter*stud_rescale)/2,h=stud_body_height,$fs=cylinder_precision);
            if (stud_top_roundness != 0) {
                translate([0,0,stud_body_height])
                rounded_stud_top(height=stud_top_height, radius=(stud_diameter*stud_rescale)/2,curve_height=stud_top_roundness);
            }
        }

        if (stud_type == "hollow") {
            // 0.5 is for cleaner preview; doesn't affect functionality.
            cylinder(r=(hollow_stud_inner_diameter*stud_rescale)/2,h=stud_height+0.5,$fs=cylinder_precision);
        }
    }
}

module rounded_stud_top(
    height,
    radius,
    curve_height
    ) {
    assert(curve_height < (radius/2), "Curve height must be less than half the radius");
    assert(height >= curve_height, "Curve height must be greater than or equal to height");
    base_height=height-curve_height;
    union() {
        cylinder(h=base_height, r=radius, $fs=cylinder_precision);
        translate([0,0,base_height])
        difference() {
            union() {
                rotate_extrude($fs=cylinder_precision)
                hull() {
                    translate([radius-curve_height, 0, 0])
                    circle(curve_height, $fs=cylinder_precision);
                };
                cylinder(h=curve_height, r=(radius-curve_height), $fs=cylinder_precision);
            }
            translate([0,0,-curve_height])
            cylinder(h=curve_height, r=(radius), $fs=cylinder_precision);
        }

    };
}

// cube([baseX,baseY,baseThickness]){
//     position(TOP) grid_copies(n=[studsWide,studsDeep], spacing = 8) cylinder(h = studHeight, r = studDiameter/2, $fn=50);
// attach(BOTTOM, TOP) 
//         openGridSnap(lite=true, directional=true);
// }

// openGridSnap(lite=true, directional=true); 

// zmove(studHeight) grid_copies(n=[studsWide,studsDeep], spacing = 8) cylinder(h = studHeight, r = studDiameter/2, $fn=50);
// openGridSnap(lite=(snap_type == "lite" ? true : false), directional=directional);

openGridSnap(lite=(snap_type == "lite" ? true : false), directional=directional)
    attach(TOP) {
        grid_copies(n=[studsWide,studsDeep], spacing = 8) 
            cylinder(h = studHeight, r = adjStudDiameter/2, $fn=50);
    }

// stud();

// openGridSnap(lite=(snap_type == "lite" ? true : false), directional=directional)
//     attach(TOP) {
//         grid_copies(n=[studsWide,studsDeep], spacing = stud_spacing) 
//             stud();
//     }