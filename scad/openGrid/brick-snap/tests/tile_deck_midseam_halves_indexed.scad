// tile_deck_midseam_halves_indexed.scad
// Deck extends to mid‑seam (minus tiny clearance) and produces **half‑studs on the shared seam**
// by clipping a global 8 mm lattice. Which edge gets the half is **auto‑flipped by (col,row)**,
// so any tiled grid will have halves that **match across every seam**.
//
// No external includes. Pure OpenSCAD. Includes a 2x2 demo.
//
// ---------------- Parameters ----------------
$fn = 64;

tile_top         = 24.8;   // visible tile top (square)
pitch_board      = 28.0;   // tile spacing
seam_clear_total = 0.20;   // total clearance between neighboring decks (both tiles)
stud_pitch       = 8.0;    // LEGO pitch
stud_d_nom       = 4.80;   // stud diameter
stud_h_nom       = 1.80;   // stud height
stud_rescale     = 1.03;   // printer fit
deck_thick       = 2.6;    // deck thickness
corner_r         = 3.0;    // corner radius
stud_top_relief  = 0.10;   // tiny top bevel (0 = off)

// ---------------- Derived ----------------
seam_total = pitch_board - tile_top;          // ~3.2
overhang   = max(0, seam_total/2 - seam_clear_total/2);  // to mid‑seam minus clearance/2
deck_w     = tile_top + 2*overhang;
deck_h     = tile_top + 2*overhang;
edge_pos   = tile_top/2 + overhang;           // distance from center to deck edge

// Base offset that puts a stud center on the +edge (one side)
function mod_pos(a,b) = a - floor(a/b)*b;
base_off = mod_pos(edge_pos, stud_pitch);     // in [0, stud_pitch)

// If you want to render a single tile: set col,row to its board indices
col = 0;   // X index
row = 0;   // Y index

// Flip which edge gets the half by parity: even → +edge, odd → −edge
off_x = (col % 2 == 0) ? base_off : (stud_pitch - base_off) % stud_pitch;
off_y = (row % 2 == 0) ? base_off : (stud_pitch - base_off) % stud_pitch;

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

// Build full stud grid with XY offsets, then clip to deck boundary → half‑studs on the selected edges.
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
    translate([0,0,h/2]) cube([tile_w, tile_h, h+0.3], center=true);
  }
}

// ---------------- MAIN ----------------
module tile_deck_midseam_halves_indexed(col=0,row=0){
  // recompute offsets from provided col,row (so module can be instanced many times)
  edge_pos_local = edge_pos;
  base_off_local = base_off;
  offx = (col % 2 == 0) ? base_off_local : (stud_pitch - base_off_local) % stud_pitch;
  offy = (row % 2 == 0) ? base_off_local : (stud_pitch - base_off_local) % stud_pitch;

  d = stud_d_nom*stud_rescale;

  // Deck
  linear_extrude(height=deck_thick)
    rounded_rect(deck_w, deck_h, min(corner_r, min(deck_w,deck_h)/2));

  // Studs (clipped lattice)
  translate([0,0,deck_thick])
    clipped_stud_field(deck_w, deck_h, stud_pitch, d, stud_h_nom, offx, offy, relief=stud_top_relief);
}

// ---------------- DEMO: 2×2 grid ----------------
SHOW_DEMO = false;
if (SHOW_DEMO){
  // Lay out a 2×2 at board pitch; we pass (col,row) so adjacent tiles flip which edge gets halves.
  for (r=[0:1]) for (c=[0:1])
    translate([ (c*2-1)*(pitch_board/2), (r*2-1)*(pitch_board/2), 0 ])
      tile_deck_midseam_halves_indexed(col=c,row=r);
}else{
  tile_deck_midseam_halves_indexed(col=col,row=row);
}
