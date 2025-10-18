// og_universal_tile_deck.scad
// Universal single-tile snap with a sliding stud cap that clicks into
// 4 positions to give per-axis half-stud phase: (0,0), (4,0), (0,4), (4,4).
//
// How to use:
//   1) Print one BASE and one CAP.
//   2) Drop the BASE into any OpenGrid tile (snap TOP is flush).
//   3) Slide the CAP to the detent that matches your neighbors.
//      Now LEGO pieces can bridge all seams in rows and columns.
//
// Notes: assumes openGridSnap(lite, directional, orient, anchor, spin) exists.
//        If it's in another file, include it above your call.
//
// Optional: include <BOSL2/std.scad> if your snap uses BOSL2 anchors.

$fn = 72;

// ---- System dimensions ----
tile_pitch   = 28.0;     // OpenGrid center spacing
w_tile       = 24.8;     // visible tile top
stud_pitch   = 8.0;      // LEGO stud pitch
stud_d_nom   = 4.80;
stud_h_nom   = 1.80;
stud_rescale = 1.03;     // printer fit

// ---- Cap stud layout (inside one tile top) ----
// Use 3x3 per-tile so studs never overhang 24.8 mm top in any phase.
stud_cols = 3;
stud_rows = 3;

// ---- Sliding pocket/tongue (mechanism) ----
phase_step   = 4.0;      // half-stud offset (mm) in each axis
pocket_w     = 18.0;     // pocket inner width (X)
pocket_d     = 18.0;     // pocket inner depth (Y)
pocket_h     = 2.0;      // pocket recess (Z)
lip_thick    = 1.6;      // material above pocket
tongue_w     = 17.4;     // cap tongue width (X)  -> pocket_w - clearance
tongue_d     = 17.4;     // cap tongue depth (Y)  -> pocket_d - clearance
tongue_h     = 1.6;      // tongue height (Z)     -> slightly < pocket_h
mech_clear   = 0.30;     // XY clearance for slide (printer dependent)
detent_rad   = 0.7;      // small bump for tactile stops (optional)

// ---- Deck body (base) ----
deck_thick   = lip_thick + pocket_h;  // total base top thickness over snap
corner_r     = 3.0;      // rounded corners on base top

// ---- Helpers ----
module rounded_rect(w, h, r){
  if (r <= 0) square([w,h], center=true);
  else hull(){
    translate([ w/2 - r,  h/2 - r]) circle(r, $fn=48);
    translate([-w/2 + r,  h/2 - r]) circle(r, $fn=48);
    translate([ w/2 - r, -h/2 + r]) circle(r, $fn=48);
    translate([-w/2 + r, -h/2 + r]) circle(r, $fn=48);
  }
}

module lego_stud_field(cols, rows, d, h, pitch){
  for (i=[0:cols-1]) for (j=[0:rows-1])
    translate([ (i-(cols-1)/2)*pitch, (j-(rows-1)/2)*pitch, 0 ])
      cylinder(d=d, h=h);
}

// ======================== BASE (snap + pocket) =========================
module og_universal_base(snap_lite=true, directional=false){
  // Place your OpenGrid snap; its TOP is Z=0 here.
  openGridSnap(lite=snap_lite, directional=directional, orient=UP, anchor=TOP, spin=0){
    // Base top sized to the tile top (plus a small visual lip if you like)
    base_w = w_tile;
    base_h = w_tile;

    // Deck slab with pocket cut-out and 4 corner stop posts
    difference(){
      // deck slab
      linear_extrude(height=deck_thick)
        rounded_rect(base_w, base_h, corner_r);

      // sliding pocket cavity
      translate([-pocket_w/2, -pocket_d/2, deck_thick - pocket_h + 0.01])
        cube([pocket_w, pocket_d, pocket_h+0.02], center=false);

      // shallow seam relief under the slab (optional, combats elephant foot)
      relief = 0.3;
      translate([0,0,-0.01])
        linear_extrude(height=relief+0.02)
          rounded_rect(base_w-2*relief, base_h-2*relief, max(0, corner_r-relief));
    }

    // 4 hard stops at the pocket corners to define the detent positions
    stop_w = 1.6; stop_h = pocket_h; stop_t = 0.8;
    for (sx=[-1,1]) for (sy=[-1,1]) {
      translate([sx*(pocket_w/2 - stop_w/2), sy*(pocket_d/2 - stop_w/2), deck_thick - pocket_h])
        cube([stop_w, stop_w, stop_t], center=true);
    }

    // Optional tiny detent bumps near the 4 corners (feelable click)
    if (detent_rad > 0)
      for (sx=[-1,1]) for (sy=[-1,1]) {
        translate([sx*(pocket_w/2 - 2.0), sy*(pocket_d/2 - 2.0), deck_thick - pocket_h + 0.1])
          sphere(r=detent_rad, $fn=24);
      }
  }
}

// ======================== CAP (stud plate + tongue) ====================
module og_universal_cap(top_style="stud"){
  d = stud_d_nom * stud_rescale;
  r = d/2;

  // Cap body (thin plate) sized to sit on the base
  cap_w = min(w_tile, pocket_w + 6);  // small overhang past pocket edges
  cap_h = min(w_tile, pocket_d + 6);
  cap_t = 1.6;                        // cap thickness above tongue

  // Build cap with tongue underneath
  union(){
    // visible plate
    linear_extrude(height=cap_t)
      rounded_rect(cap_w, cap_h, 2.5);

    // sliding tongue (fits into base pocket)
    translate([0,0, -tongue_h + 0.01])  // slightly proud negative to avoid Z-fight
      cube([tongue_w - mech_clear, tongue_d - mech_clear, tongue_h], center=true);

    // studs or smooth tile surface on top of the cap
    translate([0,0, cap_t]){
      if (top_style == "stud")
        lego_stud_field(stud_cols, stud_rows, d, stud_h_nom, stud_pitch);
      else if (top_style == "tile") {
        deck_w = (stud_cols-1)*stud_pitch + 2*(r+0.6);
        deck_h = (stud_rows-1)*stud_pitch + 2*(r+0.6);
        linear_extrude(height=3.0)
          rounded_rect(deck_w, deck_h, 2.0);
      }
    }
  }
}

// ======================== ASSEMBLY / PLACEMENT =========================
// Place a base at (0,0) and slide the cap to one of 4 positions:
// (0,0), (phase_step,0), (0,phase_step), (phase_step,phase_step).
// For a real print, you print base and cap separately, then assemble.

module og_universal_tile_assembled(phase_x=0, phase_y=0, snap_lite=true, directional=false, top_style="stud"){
  // safety clamp
  px = (phase_x>0) ? phase_step : 0;
  py = (phase_y>0) ? phase_step : 0;

  // Base (snaps into the board)
  og_universal_base(snap_lite=snap_lite, directional=directional);

  // Cap (slides on the base)
  // Cap Z sits on deck_thick (top of base slab).
  translate([px, py, deck_thick]) og_universal_cap(top_style=top_style);
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

// ======================== DEMO =========================================
// Uncomment includes as needed:
include <BOSL2/std.scad>
// include <opengrid-brick-snap.scad>

 //-- Show all 4 phases for visual check --

translate([-40,  40, 0]) og_universal_tile_assembled(phase_x=0,            phase_y=0);
translate([+40,  40, 0]) og_universal_tile_assembled(phase_x=phase_step,   phase_y=0);
translate([-40, -40, 0]) og_universal_tile_assembled(phase_x=0,            phase_y=phase_step);
translate([+40, -40, 0]) og_universal_tile_assembled(phase_x=phase_step,   phase_y=phase_step);
