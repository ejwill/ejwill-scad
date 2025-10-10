/* 
OpenGrid Brick Snap (OpenSCAD)

Adds a studded top to an OpenGrid snap so models can connect to 
common interlocking brick systems. Not affiliated with or endorsed 
by the LEGO Group. “LEGO” is a trademark of the LEGO Group.

Change Log:
v1.0  - Initial release

Credits:
- David D (OpenGrid concept)
- metasyntactic (OpenSCAD implementation of OpenGrid snap)
- Katie + community at Hands on Katie
- cfinke (LEGO.scad dimensions reference)

Links:
- OpenGrid SCAD: https://github.com/AndyLevesque/QuackWorks/blob/main/openGrid/opengrid-snap.scad
- LEGO.scad reference: https://github.com/cfinke/LEGO.scad

License:
- This script: CC BY-NC-SA 4.0
- Third-party code retains its original licenses.
*/

include <BOSL2/std.scad>

/* [Grid Layout] */
// Number of studs wide
studsWide = 3;
// Number of studs deep
studsDeep = 3;

/* [OpenGrid Snap Settings] */
// Type of snap connector to use
snap_type = "lite"; // [lite, full]
// Enable directional locking for the snap
directional = true; // [true, false]

/* [Brick Compatibility] */
// What type of stud to create
stud_type = "solid"; // [solid:Solid, hollow:Hollow]
// Scale factor for stud size (use to adjust fit)
stud_rescale = 1.00; // [0.51:0.01:1.49]
// Amount of rounding on stud top (0 for flat top)
stud_top_roundness = 0; // [0:0.01:1]
/*[Hidden]*/
stud_diameter= 4.85;
hollow_stud_inner_diameter = 3.1;
cylinder_precision= 0.1;
stud_height=1.8;

$fn = 100;

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

openGridSnap(lite=(snap_type == "lite" ? true : false), directional=directional)
    attach(TOP) {
        grid_copies(n=[studsWide,studsDeep], spacing = 8) 
            stud();
    }