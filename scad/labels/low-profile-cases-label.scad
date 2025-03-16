/************** Low-Profile Milwaukee Packout Case Handle Labels *******************
*
* Updated By ejwill https://github.com/ejwill/milwaukee-scad
* 
* Description:
* This is a customizable label for the Milwaukee Packout Low-Profile Handle.
* The label can be customized with text, font, color, and size.
* The label can be embedded into the handle or printed on the face. 
*
* Compatible with the following Milwaukee Packout Low-Profile Organizers:
* 5 compartment 48-22-8436 (compact low profile)
* 11 compartment 48-22-8431 (low profile)
*
* Originally from Benjamen Johnson's Low-Profile Packout Handle Label. <https://3dprints.electronsmith.com/low-profile-packout-handle-labels/>
* Benjamen Johnson <workshop.electronsmith.com>
*
* Changes: 
* - Added option to embed text into the handle
* - Updated for use on MakerWorld
* - Added option to print on face
* - Updated to OpenScad 2024.12.11
*
* Licesnse: Creative Commons - Attribution - Share Alike
*           https://creativecommons.org/licenses/by-sa/4.0/
*******************************************************************************/

/*[Case]*/

//What Case is the handle for?
caseType = "compact low profile"; // [compact low profile, low profile]

/* [Hidden] */
// Length of the base (face of the handle)
base_length = (caseType == "compact low profile") ? 117 : 144;
// Width of the base (face of the handle)
base_width = (caseType == "compact low profile") ? 18 : 20;
// Diameter of catch pocket
catch_dia = 3;
// How wide the catch should be
catch_length = 8.5;
// How hight the catch should be
catch_height = 7;
// Height of the base (thickness of the label)
base_height = 3;

/* [Handle Options] */
//Handle Color
handle_color = "#000000"; //color
// How tight the catch should be
catch_adjust_tightness = "normal"; // [loose, normal, tight]
catch_adjust = (catch_adjust_tightness == "loose") ? 0.95 : 
               (catch_adjust_tightness == "normal") ? 1 : 1.05;


/*[Label Options]*/
// What do you want the label to say?
label = "TAPS & DIES";

// Which font do you want to use
font_style ="Open Sans"; // font

// How big you want the text
font_size = 11;//[0:0.5:15]

// How thick the font is (back to front)
font_thickness = 0.6;

//Label Color
label_Color = "#ffffff"; //color

// Adjust the length of the label
length_adjust = 1; //[0.95:0.001:1.05]

// Option to embed the text into the handle
embed_text = false; //[false, true]

/* [Print Options] */
// Print on Face
// Reconmended to print on face if you are embedding the text
print_on_face = false; //[false, true]

/*[Hidden]*/
// Calculations
adj_base_len = base_length * length_adjust;
adj_catch_dia = catch_dia * catch_adjust;

// create vector for defining the base
BASE_DEF = [adj_base_len,base_width,base_height];

// figure out where the end of the label will be
end_pos = (adj_base_len+2*base_height)/2;

// create vectors for defining the catch and catch position
CATCH_DEF = [catch_length,base_width,catch_height];
CATCH_POS = [-end_pos,0,-catch_height/2+base_height];
CATCH_CUT_POS = [-adj_base_len/2+adj_catch_dia/2,0,-adj_catch_dia/2];

LONG_CHAMFER_DEF = [2*end_pos,base_height*sqrt(2),10];
LONG_CHAMFER_POS = [0,base_width/2,base_height];


/*******************************************************************************
* Important definitions
*******************************************************************************/
INVERT_X =[[-1,0,0],[0,1,0],[0,0,1]];
INVERT_Y =[[1,0,0],[0,-1,0],[0,0,1]];

$dl= 0.01;

/*******************************************************************************
* Make the label
*******************************************************************************/

module handle() {
    color(handle_color){
        difference(){
            union(){
                translate([0,0,base_height/2])
                cube(BASE_DEF,center = true);
            
                translate(CATCH_POS)
                cube(CATCH_DEF,center=true);
            
                translate(INVERT_X * CATCH_POS)
                cube(CATCH_DEF,center=true);
            } //end union
            
            //chamfer long edges
            translate(LONG_CHAMFER_POS)
            rotate([45,0,0])
            cube(LONG_CHAMFER_DEF,center = true);
            
            translate(INVERT_Y*LONG_CHAMFER_POS)
            rotate([-45,0,0])
            cube(LONG_CHAMFER_DEF,center = true);
            
            //chamfer top ends
            translate([-end_pos-3*sqrt(2),0,base_height])
            rotate([0,45,0])
            cube([base_height*sqrt(2)+2*3,base_width+10,20],center = true);
            
            translate([end_pos+3*sqrt(2),0,base_height])
            rotate([0,-45,0])
            cube([base_height*sqrt(2)+2*3,base_width+10,20],center = true);
            
            // chamfer bottom ends
            translate([end_pos+3*sqrt(2)+2,0,-base_height])
            rotate([0,45,0])
            cube([base_height*sqrt(2)+2*3,base_width+10,20],center = true);
            
            translate([-end_pos-3*sqrt(2)-2,0,-base_height])
            rotate([0,-45,0])
            cube([base_height*sqrt(2)+2*3,base_width+10,20],center = true);
            
            // chamfer corners
            corner_cut = 1.3;
            translate([-end_pos-3*sqrt(2)-corner_cut,base_width/2,base_height])
            rotate([0,0,-45])
            cube([base_height*sqrt(2)+2*3,base_width+10,20],center = true);

            translate([-end_pos-3*sqrt(2)-corner_cut,-base_width/2,base_height])
            rotate([0,0,45])
            cube([base_height*sqrt(2)+2*3,base_width+10,20],center = true);

            translate([end_pos+3*sqrt(2)+corner_cut,base_width/2,base_height])
            rotate([0,0,45])
            cube([base_height*sqrt(2)+2*3,base_width+10,20],center = true);

            translate([end_pos+3*sqrt(2)+corner_cut,-base_width/2,base_height])
            rotate([0,0,-45])
            cube([base_height*sqrt(2)+2*3,base_width+10,20],center = true);

            // make cutout for the catches
            translate(CATCH_CUT_POS)
            rotate([90,0,0])
            cylinder(d = adj_catch_dia,h = base_width+$dl,$fn=20,center = true);
            
            translate(INVERT_X * CATCH_CUT_POS)
            rotate([90,0,0])
            cylinder(d = adj_catch_dia,h = base_width+$dl,$fn=20,center = true);

            // add the label text
            if (embed_text) {
                translate([0,0,base_height - font_thickness])
                color(label_Color)
                linear_extrude(height = font_thickness)
                text(text = label, font = font_style, size =font_size, valign="center",halign = "center");
            }
        }
    }// end difference}
}

if(embed_text){
    label_Color = handle_color;
    if(print_on_face){
        rotate([180, 0, 0]) {
            handle();
        }
    } else {
        handle();
    }
} else {
    if(print_on_face){
        rotate([180, 0, 0]) {
            handle();
        }
    } else {
        handle();
    }
    translate([0,0,base_height])
    color(label_Color)
    linear_extrude(height = font_thickness)
        text(text = label, font = font_style, size = font_size, valign="center", halign = "center");
}

