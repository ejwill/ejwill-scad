// seamcut_tile_standalone.scad
$fn = 64;
tile_top=24.8; stud_pitch=8.0; stud_d_nom=4.80; stud_h_nom=1.80; stud_rescale=1.03;
deck_thick=2.6; corner_r=3.0; boundary_inset=0.05; stud_top_relief=0.10;

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
module seamcut_stud_field(tile_w, tile_h, pitch, d, h, inset=0, relief=0){
  r=d/2;
  min_x=-tile_w/2-r; max_x=tile_w/2+r;
  min_y=-tile_h/2-r; max_y=tile_h/2+r;
  i0=floor(min_x/pitch); i1=ceil(max_x/pitch);
  j0=floor(min_y/pitch); j1=ceil(max_y/pitch);
  bound_w=tile_w-2*inset; bound_h=tile_h-2*inset;
  intersection(){
    union(){
      for(i=[i0:i1]) for(j=[j0:j1])
        translate([i*pitch, j*pitch, 0]) stud_cyl(d=d,h=h,relief=relief);
    }
    translate([0,0,h/2]) cube([bound_w,bound_h,h+0.2],center=true);
  }
}
module seamcut_tile(){
  d=stud_d_nom*stud_rescale;
  linear_extrude(height=deck_thick) rounded_rect(tile_top,tile_top,corner_r);
  translate([0,0,deck_thick])
    seamcut_stud_field(tile_top,tile_top,stud_pitch,d,stud_h_nom,inset=boundary_inset,relief=stud_top_relief);
}
// Demo 2x2
SHOW_DEMO=true; pitch_board=28.0;
if(SHOW_DEMO){
  for(r=[0:1]) for(c=[0:1])
    translate([(c*2-1)*(pitch_board/2),(r*2-1)*(pitch_board/2),0]) seamcut_tile();
}else seamcut_tile();
