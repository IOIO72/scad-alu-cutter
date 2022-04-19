/*
Aluminium Foil Gas Stove Cutter

by IOIO72 aka Tamio Patrick Honma (https://honma.de)

This work is licensed under the Creative Commons Attribution-NonCommercial-ShareAlike 4.0 International License. To view a copy of this license, visit http://creativecommons.org/licenses/by-nc-sa/4.0/ or send a letter to Creative Commons, PO Box 1866, Mountain View, CA 94042, USA.

As the saws of the cutter are challenging to print, you need to adjust the setting in the slicer with caution. If you have trouble to print the saws, you can use the customizer and set the height of the saw tooth to zero and use the cutter without saws.

1. I recommend to use 0.1 layer heights for the saws, to get accurate saw shapes.
2. Slow down the print beginning with layer 44 when using 0.1 layer and no adjustment to the cutter heights in the customizer. I slowed it down to 20%. In Cura you can use the ChangeAtZ plugin for this.
3. You may also decrease the retraction feed rate and the retraction length for the saw layers, because otherwise the extruder may squeeze the filament as it moves up and down in short times and jam the extrusion. Use the ChangeAtZ plugin in Cura as done above.

For the rest of the model you should avoid to use fill. Use many walls (i.e. 10) instead. This will increase the general speed of your print.

If you don't see the walls of the cutter, you should enable thin walls in your slicer.
*/

/* [Cutter Basic] */

// Diameter
cutter_diameter = 55;

/* [Cutter Advanced] */

// Cutter blade size
cutter_blade_size = 1.2;

// Cutter blade height
cutter_blade_height = 2.5;

// Handle height
handle_height = 2;

// Hanlde width
handle_width = 10;

// Saw tooth width
saw_tooth_width = 4;

// Saw tooth width
saw_tooth_height = 2;


/* [Conterpart] */

// Blade Sheath Tolerance
blade_sheath_tolerance = 2.5;


/* [Parts] */

// Select parts to render
parts = "all"; // [all:"Cutter & Counterpart",cutter:"Cutter only",counterpart:"Counterpart only"]


/* [Advanced] */

// Number of fragments
$fn = 70; // [20:100]


/* [Hidden] */
blade_length = PI * cutter_diameter;
saw_count = floor(blade_length / saw_tooth_width);

module ring(height,diameter,inner_diameter) {
  linear_extrude(height=height) {
    difference () {
      circle(d=diameter);
      circle(d=inner_diameter);
    };
  };
};


module saw_tooth() {
  translate([
    0,
    cutter_diameter / 2 + cutter_blade_size / 2,
    handle_height + cutter_blade_height
  ])
  rotate([90, 0, 0])
  linear_extrude(cutter_blade_size / 2)
  polygon([
    [-saw_tooth_width / 2, 0],
    [saw_tooth_width / 2, saw_tooth_height],
    [saw_tooth_width / 2, 0]]
  );
};

module cutter_blade(tolerance = 0, with_saws = true) {
  // Handle
  ring(
    handle_height,
    cutter_diameter + cutter_blade_size + handle_width / 2,
    cutter_diameter - handle_width / 2
  );

  // Blade
  translate([0, 0, handle_height])
  ring(
    with_saws ?
      cutter_blade_height :
      cutter_blade_height + saw_tooth_height,
    cutter_diameter + cutter_blade_size + tolerance / 2,
    cutter_diameter - tolerance / 2
  );
  
  // Saw
  if (with_saws) {
    for(i = [1:saw_count]) {
      rotate([0, 0, i * 360 / saw_count])
      saw_tooth();
    };
  };
};

module counterpart() {
  difference() {
    ring(
      cutter_blade_height + saw_tooth_height,
      cutter_diameter + cutter_blade_size + handle_width / 2,
      cutter_diameter - handle_width / 2
    );
    rotate([180, 0, 0])
    translate([
      0,
      0,
      - cutter_blade_height - saw_tooth_height - 2 * handle_height
    ])
    cutter_blade(blade_sheath_tolerance, false);
  };
};

if (parts == "cutter" || parts == "all") {
  cutter_blade();
};

if (parts == "counterpart" || parts == "all") {
  translate([cutter_diameter + handle_width, 0, 0]) counterpart();
};
