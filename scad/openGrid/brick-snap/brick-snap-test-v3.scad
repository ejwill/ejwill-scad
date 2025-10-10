include <BOSL2/std.scad>
// include <tile_deck_midseam_halves_indexed-v2.scad>;
// include <tile_deck_midseam_halves_indexed_chamfer.scad>;

/* [OpenGrid] */
tile_type       = "lite"; // [lite, full]
snap_directional= false; // [true, false]

/* [Stud] */
// What type of stud to create
stud_type = "solid"; // [solid:Solid, hollow:Hollow]
// Scale factor for stud size (use to adjust fit)
stud_rescale = 1.00; // [0.51:0.01:1.49]
// Amount of rounding on stud top (0 for flat top)
stud_top_roundness = 0; // [0:0.01:1]

/* [Stud Deck Options] */
// Clearance deck seams
seam_clear_total = 0.20; // [0.00:0.01:1.00]
// How thick the deck on top of the tile is
deck_thickness = 2.6; // [1.00:0.1:10.0]

/* [Options] */
show_demo_pattern = false; // [true, false]

/*[Hidden]*/
stud_diameter= 4.85;
hollow_stud_inner_diameter = 3.1;
cylinder_precision= 0.1;
stud_height=1.8;
stud_spacing=8;

$fn = 100;
snap_lite       = (tile_type == "lite") ? true : false;
//Tile
tile_top        = 24.8;
pitch_board     = 28.0;
seam_total 		= pitch_board - tile_top;
overhang   		= max(0, seam_total/2 - seam_clear_total/2);
edge_pos   		= tile_top/2 + overhang;
deck_w     		= tile_top + 2*overhang;
deck_h     		= tile_top + 2*overhang;
corner_r        = 3.0;
// micro chamfer
chamfer_z       = 0.12;
chamfer_xy      = 0.20;

adj_stud_diameter = stud_diameter * stud_rescale;

base_off = mod_pos(edge_pos, stud_spacing);

/* OpenGrid Modules */

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

/* Stud Modules */

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

module clipped_stud_field(tile_w, tile_h, pitch, offx, offy){
  r=adj_stud_diameter/2;
  min_x=-tile_w/2 - r; max_x=tile_w/2 + r;
  min_y=-tile_h/2 - r; max_y=tile_h/2 + r;
  i0=floor((min_x-offx)/pitch); i1=ceil((max_x-offx)/pitch);
  j0=floor((min_y-offy)/pitch); j1=ceil((max_y-offy)/pitch);

  intersection(){
    union(){
      for(i=[i0:i1]) for(j=[j0:j1])
        translate([i*pitch + offx, j*pitch + offy, 0])
			stud();
    }
    translate([0,0,stud_height/2]) cube([tile_w, tile_h, stud_height+0.3], center=true);
  }
}

/* Tile Deck Module */

module deck_with_chamfer(w,h,t,r, chamfer_z=0.12, chamfer_xy=0.20){
  difference(){
    linear_extrude(height=t)
      rounded_rect(w,h, min(r, min(w,h)/2));
    translate([0,0,-chamfer_z])
      linear_extrude(height=chamfer_z+0.02)
        offset(delta=chamfer_xy)
          rounded_rect(w,h, min(r, min(w,h)/2));
  }
}

module tile_deck_midseam_halves_indexed(col=0,row=0){
  offx = (col % 2 == 0) ? base_off : (stud_spacing - base_off) % stud_spacing;
  offy = (row % 2 == 0) ? base_off : (stud_spacing - base_off) % stud_spacing;

  deck_with_chamfer(deck_w, deck_h, deck_thickness, corner_r, chamfer_z, chamfer_xy);

  translate([0,0,deck_thickness])
    clipped_stud_field(deck_w, deck_h, stud_spacing, offx, offy);
}

/* Helpers */

function mod_pos(a,b) = a - floor(a/b)*b;

module rounded_rect(w,h,r){
  if (r<=0) square([w,h],center=true);
  else hull(){
    translate([ w/2 - r,  h/2 - r]) circle(r);
    translate([-w/2 + r,  h/2 - r]) circle(r);
    translate([ w/2 - r, -h/2 + r]) circle(r);
    translate([-w/2 + r, -h/2 + r]) circle(r);
  }
}

/* Main */

if (show_demo_pattern){
	r = 2;
	c = 2;
	for (r=[0:1]) for (c=[0:1])
		translate([ (c*2-1)*(pitch_board/2), (r*2-1)*(pitch_board/2), 0 ])
			openGridSnap(lite=snap_lite, directional=snap_directional, orient=UP, anchor=TOP, spin=0)
			attach(TOP) {
				tile_deck_midseam_halves_indexed(col=c,row=r);
			};
} else{
	openGridSnap(lite=snap_lite, directional=snap_directional, orient=UP, anchor=TOP, spin=0)
    attach(TOP) {
        tile_deck_midseam_halves_indexed(col=0,row=0);
    };
}