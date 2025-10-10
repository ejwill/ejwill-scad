// og_2tile_bridge_from_snap.scad
// A 2-tile-wide bridge that snaps to two OpenGrid tiles and carries a centered,
// true 8 mm LEGO stud grid across the span. No half-stud offset is used/needed.
//
// Usage:
//   include <BOSL2/std.scad>               // if not already included by your snap
//   include <opengrid-brick-snap.scad>     // defines openGridSnap(...)
//   include <og_2tile_bridge_from_snap.scad>
//
//   og_2tile_bridge_from_snap(studs_x=7, studs_y=4);
//
// Notes:
// - OpenGrid tile pitch is 28 mm; two tiles = 56 mm = 7 LEGO studs.
// - This file always centers the deck and stud field on the seam (no 4 mm offset).
// - Overhangs are auto-clamped to share the 3.2 mm seams with neighbors.

$fn = 72;

// ---------------------------- MAIN MODULE ----------------------------
module og_2tile_bridge_from_snap(
    // Grid + spacing
    tile_pitch      = 28.0,     // OpenGrid center-to-center
    w_tile          = 24.8,     // visible tile top width
    stud_pitch      = 8.0,      // LEGO pitch
    studs_x         = 7,        // 2 tiles (56 mm) -> 7 studs across (keep 7)
    studs_y         = 4,        // rows front/back (edit as you like)

    // Top surface (studs or smooth tile)
    top_style       = "stud",   // ["stud","tile"]
    stud_d_nom      = 4.80,
    stud_h_nom      = 1.80,
    stud_rescale    = 1.03,     // printer calibration
    tile_thick      = 3.20,     // used when top_style="tile"

    // Deck + vertical spacing
    standoff_h      = 1.0,      // small lift above snap TOP (snap TOP is flush with board)
    deck_thick      = 3.0,      // deck thickness
    corner_radius   = 3.0,      // deck corner rounding (0 = square)
    edge_margin     = 0.6,      // extra material past stud edge so studs never look flush

    // Tessellation (share seams with neighbors)
    overhang_x      = 1.8,      // lip beyond the 2*tile_pitch span (each side)
    overhang_y      = 1.8,      // lip beyond the stud field in Y (each side)

    // Snap options (forwarded to your snap)
    snap_lite       = true,
    snap_directional= false
){
    // ---- seam sharing: don’t intrude too far into the 3.2 mm seams ----
    seam_gap = tile_pitch - w_tile;           // 3.2 mm
    max_oh   = max(0, seam_gap/2 - 0.3);      // ≈ 1.3 mm safe share per side
    ox = min(overhang_x, max_oh);
    oy = min(overhang_y, max_oh);

    // ---- stud field spans ----
    grid_w      = (studs_x-1) * stud_pitch;   // stud center span in X (should be 48 mm for 7 studs)
    grid_h      = (studs_y-1) * stud_pitch;
    stud_radius = (stud_d_nom * stud_rescale)/2;

    // ---- deck size: wide enough for full 2*tile_pitch AND to cover stud edges ----
    min_w_centers = 2*tile_pitch;                             // 56 mm
    min_w_studs   = grid_w + 2*(stud_radius + edge_margin);   // covers stud discs
    deck_w        = max(min_w_centers, min_w_studs) + 2*ox;   // plus side lips
    deck_h        = (grid_h + 2*(stud_radius + edge_margin)) + 2*oy;

    // ---- place snaps: one at each tile center; child space is TOP of snap ----
    translate([0, 0, 0])
      openGridSnap(lite=snap_lite, directional=snap_directional, orient=UP, anchor=TOP, spin=0)
        children();   // (optional) add posts here if you ever want them

    // ---- deck (centered on seam) ----
    translate([0, 0, standoff_h])
      linear_extrude(height=deck_thick)
        rounded_rect(deck_w, deck_h, min(corner_radius, min(deck_w,deck_h)/2));

    // ---- top surface (centered; NO offsets) ----
    translate([-grid_w/2, -grid_h/2, standoff_h + deck_thick]) {
        if (top_style == "stud")
            lego_stud_field(studs_x, studs_y, stud_d_nom*stud_rescale, stud_h_nom, stud_pitch);
        else if (top_style == "tile")
            translate([-stud_pitch/2, -stud_pitch/2, 0])
              cube([grid_w + stud_pitch, grid_h + stud_pitch, tile_thick], center=false);
    }
}

// ---------------------------- HELPERS ----------------------------
module lego_stud_field(cols, rows, d, h, pitch){
    for (i=[0:cols-1]) for (j=[0:rows-1])
        translate([i*pitch, j*pitch, 0]) cylinder(d=d, h=h, $fn=64);
}

module rounded_rect(w, h, r){
    if (r <= 0) square([w,h], center=true);
    else hull(){
        translate([ w/2 - r,  h/2 - r]) circle(r, $fn=48);
        translate([-w/2 + r,  h/2 - r]) circle(r, $fn=48);
        translate([ w/2 - r, -h/2 + r]) circle(r, $fn=48);
        translate([-w/2 + r, -h/2 + r]) circle(r, $fn=48);
    }
}

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

// ---------------------------- DEMO ----------------------------
include <BOSL2/std.scad>
// Preview a 2-tile bridge (studs) that tessellates with neighbors:
og_2tile_bridge_from_snap(studs_x=7, studs_y=4, top_style="stud",
                          standoff_h=0, deck_thick=1.0,
                          overhang_x=1.75, overhang_y=1.75,
                          snap_lite=true, snap_directional=false);