// tile_deck_midseam_halves.scad
// Standalone tile top whose deck **extends to the seam midpoint** between tiles.
// The stud lattice is offset so that **stud centers lie on each edge**, yielding
// clean **half‑studs on all four sides**. Adjacent tiles visually form full studs.
//
// No external includes. Pure OpenSCAD.
//
// ---------------- Usage ----------------
// Render a single tile (default shows 2x2 demo).
// Set SHOW_DEMO=false to export a single tile at origin.
//
// ---------------- Notes ----------------
// - Board/tile pitch is assumed 28.0 mm; visible tile top is 24.8 mm → seam is 3.2 mm total.
// - Deck overhang goes to the **mid‑seam** but leaves a tiny shared clearance so neighbors
//   don’t collide. Default total clearance across the seam is 0.2 mm (0.1 per tile).
// - Stud lattice is auto‑offset so a stud center lies at each deck edge → exact half‑studs.
// - You can tweak seam_clear_total and stud_rescale to taste.

$fn = 64;

// ---------------- Parameters ----------------
tile_top         = 24.8;   // visible tile top (square)
pitch_board      = 28.0;   // center-to-center pitch between tiles
seam_clear_total = 0.20;   // total clearance *between two neighboring decks* at the seam
stud_pitch       = 8.0;    // LEGO stud pitch
stud_d_nom       = 4.80;   // stud diameter
stud_h_nom       = 1.80;   // stud height
stud_rescale     = 1.03;   // printer fit
deck_thick       = 2.6;    // deck thickness
corner_r         = 3.0;    // deck corner radius
stud_top_relief  = 0.10;   // tiny bevel to fight elephant's foot (0 = off)

// ---------------- Derived ----------------
// seam total = pitch_board - tile_top (typically 3.2 mm)
seam_total = pitch_board - tile_top;           // e.g., 3.2
// Each deck shares half the seam minus half the clearance
overhang   = max(0, seam_total/2 - seam_clear_total/2);   // e.g., 1.6 - 0.1 = 1.5
deck_w     = tile_top + 2*overhang;
deck_h     = tile_top + 2*overhang;

// Distance from center to deck edge
edge_pos   = tile_top/2 + overhang;            // ≈ 12.4 + 1.5 = 13.9

// Compute lattice offsets so a stud center lands exactly at each deck edge.
// grid_off = edge_pos modulo stud_pitch (0..8).
// This ensures edge aligns with a stud center → perfect halves on each side.
function mod_pos(a,b) = a - floor(a/b)*b;
grid_off_x = mod_pos(edge_pos, stud_pitch);
grid_off_y = mod_pos(edge_pos, stud_pitch);

// ---------------- Helpers ----------------
module rounded_rect(w,h,r){
  if (r<=0) square([w,h],center=true);
  else hull(){
    translate([ w/2 - r,  h/2 - r]) circle(r);
    translate([-w/2 + r,  h/2 - r]) circle(r);
    translate([ w/2 - r, -h/2 + r]) circle(r);
    translate([-w/2 + r, -h/2 + r]) circle(r);
  }
}

module stud_cyl(d,h,relief=0){
  if (relief<=0) cylinder(d=d,h=h);
  else{ cylinder(d=d,h=h-relief); translate([0,0,h-relief]) cylinder(d1=d,d2=d-2*relief,h=relief); }
}

// Build full stud grid with given XY offsets, then clip to deck boundary → half‑studs on edges.
module clipped_stud_field(tile_w, tile_h, pitch, d, h, offx, offy, relief=0){
  r=d/2;
  min_x=-tile_w/2 - r; max_x=tile_w/2 + r;
  min_y=-tile_h/2 - r; max_y=tile_h/2 + r;
  i0=floor((min_x-offx)/pitch); i1=ceil((max_x-offx)/pitch);
  j0=floor((min_y-offy)/pitch); j1=ceil((max_y-offy)/pitch);

  intersection(){
    union(){
      for(i=[i0:i1]) for(j=[j0:j1])
        translate([i*pitch + offx, j*pitch + offy, 0])
          stud_cyl(d=d,h=h,relief=relief);
    }
    // Clip to deck boundary volume
    translate([0,0,h/2]) cube([tile_w, tile_h, h+0.3], center=true);
  }
}

// ---------------- MAIN ----------------
module tile_deck_midseam_halves(){
  d = stud_d_nom*stud_rescale;

  // 1) Deck to the mid‑seam (minus half the clearance)
  linear_extrude(height=deck_thick)
    rounded_rect(deck_w, deck_h, min(corner_r, min(deck_w,deck_h)/2));

  // 2) Stud field: full lattice clipped to deck -> exact halves on edges
  translate([0,0,deck_thick])
    clipped_stud_field(deck_w, deck_h, stud_pitch, d, stud_h_nom, grid_off_x, grid_off_y, relief=stud_top_relief);
}

// ---------------- DEMO: 2×2 preview ----------------
SHOW_DEMO = true;
if (SHOW_DEMO){
  // Layout a 2×2 array at board pitch; with the computed offsets and overhang,
  // the edge halves from neighboring tiles will visually reconstruct full studs.
  for (r=[0:1]) for (c=[0:1])
    translate([ (c*2-1)*(pitch_board/2), (r*2-1)*(pitch_board/2), 0 ])
      tile_deck_midseam_halves();
}else{
  tile_deck_midseam_halves();
}
