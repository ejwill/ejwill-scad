// tile_deck_midseam_halves_indexed_chamfer.scad
$fn = 64;

tile_top         = 24.8;
pitch_board      = 28.0;
seam_clear_total = 0.20;
stud_pitch       = 8.0;
stud_d_nom       = 4.80;
stud_h_nom       = 1.80;
stud_rescale     = 1.03;
deck_thick       = 2.6;
corner_r         = 3.0;
stud_top_relief  = 0.00; // 0.1

// micro chamfer
chamfer_z        = 0.12;
chamfer_xy       = 0.20;

seam_total = pitch_board - tile_top;
overhang   = max(0, seam_total/2 - seam_clear_total/2);
deck_w     = tile_top + 2*overhang;
deck_h     = tile_top + 2*overhang;
edge_pos   = tile_top/2 + overhang;

function mod_pos(a,b) = a - floor(a/b)*b;
base_off = mod_pos(edge_pos, stud_pitch);

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
  offx = (col % 2 == 0) ? base_off : (stud_pitch - base_off) % stud_pitch;
  offy = (row % 2 == 0) ? base_off : (stud_pitch - base_off) % stud_pitch;

  d = stud_d_nom*stud_rescale;

  deck_with_chamfer(deck_w, deck_h, deck_thick, corner_r, chamfer_z, chamfer_xy);

  translate([0,0,deck_thick])
    clipped_stud_field(deck_w, deck_h, stud_pitch, d, stud_h_nom, offx, offy, relief=stud_top_relief);
}

// Demo
SHOW_DEMO = false;
if (SHOW_DEMO){
  for (r=[0:1]) for (c=[0:1])
    translate([ (c*2-1)*(pitch_board/2), (r*2-1)*(pitch_board/2), 0 ])
      tile_deck_midseam_halves_indexed(col=c,row=r);
}else{
  tile_deck_midseam_halves_indexed(col=0,row=0);
}
