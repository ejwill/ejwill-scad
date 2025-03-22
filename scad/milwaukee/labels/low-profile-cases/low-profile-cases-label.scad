/************** Low-Profile Milwaukee Packout Case Handle Labels *******************
*
* Updated By ejwill https://github.com/ejwill/ejwill-scad
* 
* Description:
* This is a customizable label for the Milwaukee Packout Low-Profile Handle.
* The label can be customized with text, font, color, and size.
* The label can be engravedded into the handle or printed on the face. 
*
* Compatible with the following Milwaukee Packout Low-Profile Organizers:
* 5 compartment 48-22-8436 (compact low profile)
* 11 compartment 48-22-8431 (low profile)
*
* Originally from Benjamen Johnson's Low-Profile Packout Handle Label. <https://3dprints.electronsmith.com/low-profile-packout-handle-labels/>
* Benjamen Johnson <workshop.electronsmith.com>
*
* Changes: 
* - Added option to engraved text into the handle
* - Updated for use on MakerWorld
* - Added option to print on face
* - Updated to OpenScad 2024.12.11
*
* Licesnse: Creative Commons - Attribution - Share Alike
*           https://creativecommons.org/licenses/by-sa/4.0/
*
* Version: 1.0.0
*******************************************************************************/

include <BOSL2/std.scad>

/*[Case]*/

//What Case is the handle for?
handle_length = 118; //[118:Compact Low Profile, 144:Low Profile]

/* [Hidden] */
// Length of the handle (face of the handle)
// Define the dimensions of the base handle depending on case type
// compact low profile: 118
// low profile: 144
// handle_length = (caseType == "compact low profile") ? 118 : 144;
// Width of the base (face of the handle)
// handle_width = (caseType == "compact low profile") ? 20 : 20;
// Diameter of catch pocket
catch_dia = 4.5;
// How wide the catch should be
catch_length = 4;
// How hight the catch should be
catch_height = 7;
// Height of the base (thickness of the label)
handle_thickness = 2;

/* [Handle Options] */
//Handle Width
handle_width = 20;
//Handle Color
handle_color = "#000000"; //color
// How tight the catch should be
catch_adjust_tightness = "normal"; // [loose, normal, tight]
catch_adjust = (catch_adjust_tightness == "loose") ? 1.05 : 
               (catch_adjust_tightness == "normal") ? 1 : 0.95;

/*[Label Options]*/
//What do you want the label to say?
label = "TAPS & DIES";

//Which font do you want to use
font_style ="Open Sans"; // font

//How big you want the text
font_size = 14;//[0:0.5:20]

//Bold Text
font_bold = true; //[false, true]

// Thickness of the font. If engraved, this defines how deep the text will be engraved into the handle
font_thickness = 0.6;

//Match label color to handle color. If true label color will not be used.
label_color_match = false; //[false, true]

//Label Color
label_Color = "#ffffff"; //color

//Adjust the length of the handle by percentage. 1 is 100%
handle_length_adjust = 1; //[0.95:0.001:1.05]

//Option to engraved the text into the handle
engraved_text = false; //[false, true]

/*[Hidden]*/
// Calculations
adj_handle_length = handle_length * handle_length_adjust;
adj_catch_dia = catch_dia * catch_adjust;

//create vector for defining the handle
HANDLE_DEF = [adj_handle_length,handle_width,handle_thickness];

// figure out where the end of the label will be
// end_pos = (adj_handle_length+2*handle_thickness)/2;
end_pos = (adj_handle_length+0*handle_thickness)/2;

// create vectors for defining the catch and catch position
CATCH_DEF = [catch_length,handle_width,catch_height];
CATCH_POS = [-end_pos,0,-catch_height/2+handle_thickness];
CATCH_CUT_POS = [-adj_handle_length/2+adj_catch_dia/2,0,-adj_catch_dia/2];

adj_label_color = (label_color_match == true) ? handle_color : label_Color;

INVERT_X =[[-1,0,0],[0,1,0],[0,0,1]];
INVERT_Y =[[1,0,0],[0,-1,0],[0,0,1]];

$dl= 0.01;

module handle() {
    difference(){
        union(){
            color(handle_color){
                translate([0,0,handle_thickness/2])
                cuboid(HANDLE_DEF, anchor = CENTER, rounding=2, 
                    edges=[TOP+FRONT,TOP+BACK],$fn=24){};
            
                translate(CATCH_POS)
                cuboid(CATCH_DEF, anchor = CENTER, rounding=2, 
                    edges=[TOP,RIGHT],$fn=24){};
            
                translate(INVERT_X * CATCH_POS)
                cuboid(CATCH_DEF, anchor = CENTER, rounding=2, 
                    edges=[TOP,LEFT],$fn=24){};
            }
        }

        color(handle_color){
            // make cutout for the catches
            translate(CATCH_CUT_POS)
            rotate([90,0,0])
            cylinder(d = adj_catch_dia,h = handle_width+$dl,$fn=20,center = true);
            
            translate(INVERT_X * CATCH_CUT_POS)
            rotate([90,0,0])
            cylinder(d = adj_catch_dia,h = handle_width+$dl,$fn=20,center = true);
        }

        label(font_thickness, font_bold, adj_label_color, engraved_text);
    }
}

module label(font_thickness = 0.6, bold = true, labelColor = "white", engraved = false){
    translate(engraved ? [0,0,handle_thickness- font_thickness] : [0,0,handle_thickness]){
        color(labelColor){
            linear_extrude(height = font_thickness){
                text(text = label, font = str(font_style, ":", bold ? "bold" : "normal"), size = font_size, valign = "center", halign = "center");
            };
        }
    }
}

if(engraved_text){
    handle();
} else {
    handle();
    label(font_thickness, font_bold, adj_label_color, engraved_text);
}