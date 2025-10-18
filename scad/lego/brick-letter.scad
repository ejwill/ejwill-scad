// === Stud-Mosaic Letter Generator ==========================================
// If your customizer exposes `block(width,length,height,...)`, set use_block=true
// and adjust parameter names if needed. Otherwise set use_block=false.
use_block = true;     // use your block() to make 1x1 plates
plate_ratio = 1/3;    // LEGO plate is 1/3 the height of a brick
stud_pitch = 8;       // mm between stud centers (LEGO = 8 mm)
tile_gap = 0;         // optional spacing between 1x1s (mm)
brand = "lego";       // pass through to your block(), if you use it

// Bring in your customizer:
include <brick-customizer.scad>;

// -- Primitive 1x1 plate ----------------------------------------------------
module plate1x1() {
    if (use_block) {
        // Adjust named params if your block() signature differs.
        block(
            width=1, length=1, height=plate_ratio,
            type="brick",          // studs on top; use "tile" for flat tops
            brand=brand,
            stud_type="solid"
        );
    } else {
        // Fallback: approximate 8x8x3.2mm plate
        translate([-stud_pitch/2, -stud_pitch/2, 0])
            cube([stud_pitch, stud_pitch, 9.6*plate_ratio], center=false);
    }
}

// -- 3x5 uppercase font (0=off,1=on) ----------------------------------------
/* Each glyph is 5 rows of 3 chars: top->bottom, left->right.
   Example "A":
   010
   101
   111
   101
   101
*/
FONT = [
 ["A", ["010","101","111","101","101"]],
 ["B", ["110","101","110","101","110"]],
 ["C", ["011","100","100","100","011"]],
 ["D", ["110","101","101","101","110"]],
 ["E", ["111","100","110","100","111"]],
 ["F", ["111","100","110","100","100"]],
 ["G", ["011","100","101","101","011"]],
 ["H", ["101","101","111","101","101"]],
 ["I", ["111","010","010","010","111"]],
 ["J", ["111","001","001","101","010"]],
 ["K", ["101","101","110","101","101"]],
 ["L", ["100","100","100","100","111"]],
 ["M", ["101","111","111","101","101"]],
 ["N", ["101","111","111","111","101"]],
 ["O", ["010","101","101","101","010"]],
 ["P", ["110","101","110","100","100"]],
 ["Q", ["010","101","101","111","011"]],
 ["R", ["110","101","110","101","101"]],
 ["S", ["011","100","010","001","110"]],
 ["T", ["111","010","010","010","010"]],
 ["U", ["101","101","101","101","111"]],
 ["V", ["101","101","101","101","010"]],
 ["W", ["101","101","111","111","101"]],
 ["X", ["101","101","010","101","101"]],
 ["Y", ["101","101","010","010","010"]],
 ["Z", ["111","001","010","100","111"]],
 ["0", ["111","101","101","101","111"]],
 ["1", ["010","110","010","010","111"]],
 ["2", ["111","001","111","100","111"]],
 ["3", ["111","001","111","001","111"]],
 ["4", ["101","101","111","001","001"]],
 ["5", ["111","100","111","001","111"]],
 ["6", ["111","100","111","101","111"]],
 ["7", ["111","001","001","001","001"]],
 ["8", ["111","101","111","101","111"]],
 ["9", ["111","101","111","001","111"]]
];

// Lookup a glyph by char (uppercase)
function glyph_of(c) =
    let(idx = search([str(upper(c))], FONT, 1)[0])
    (idx == undef ? ["000","000","000","000","000"] : FONT[idx][1]);

// Render a single character as 1x1 plates.
// scale_studs = integer scale (1 => 3x5, 2 => 6x10, etc.)
module lego_char(c="A", scale_studs=1) {
    g = glyph_of(c);
    // rows = 5, cols = 3
    for (r = [0:4])
    for (s = [0:scale_studs-1])      // vertical supersampling
    for (cidx = [0:2])
    for (t = [0:scale_studs-1]) {    // horizontal supersampling
        on = (substr(g[r], cidx, cidx) == "1");
        if (on) {
            translate([
                (cidx*scale_studs + t) * (stud_pitch + tile_gap),
                // invert rows so top row is visually "up" (positive Y)
                ((4 - r)*scale_studs + s) * (stud_pitch + tile_gap),
                0
            ]) plate1x1();
        }
    }
}

// Render a whole word
// letter_spacing in studs (extra columns between glyph blocks)
module lego_word(txt="HELLO", scale_studs=1, letter_spacing=1) {
    cursor = 0;
    // Each 3x5 glyph is 3*scale_studs studs wide
    glyph_w = 3*scale_studs;
    for (i=[0:len(txt)-1]) {
        translate([cursor*(stud_pitch + tile_gap), 0, 0])
            lego_char(txt[i], scale_studs=scale_studs);
        cursor += glyph_w + letter_spacing;
    }
}

// ------------------ Demo ------------------
// 1) Single letter on a 3x5 grid of 1x1 plates
//lego_char("A", scale_studs=1);

// 2) Larger letters (2x scale) -> 6x10 studs per glyph
//lego_char("A", scale_studs=2);

// 3) A whole word, 2x scale, with 1-stud spacing between letters
lego_word("BRICKS", scale_studs=2, letter_spacing=1);