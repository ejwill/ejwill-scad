# Rail Bracket

This repository contains an OpenSCAD script for generating customizable rail brackets. These brackets are designed for use with popular mounting systems such as Multiconnect, Multipoint (Multiboard), and GOEWS. The script provides extensive customization options, making it suitable for various applications, including wall mounting or shelving systems like Muscle Rack shelving.

## Features

- **Mounting System Support:** Choose from Multiconnect (Multiboard, openGrid, Custom Size), Multipoint, and GOEWS.
- **Customizable Backplate:** Adjust `back_width`, `backHeight`, and thickness for your specific needs.
- **Catch Options:** Configure catch length, back wall thickness, floor thickness, opening height, and rounding for secure rail engagement.
- **Slot Customization:**
  - Select Multiconnect slot version (`v1` or `v2`)
  - Adjust slot spacing, tolerance, dimple scale, depth microadjustment, and quick-release features
  - Enable on-ramps for easier mounting of tall items, with customizable frequency
  - Control the number of slots and their position
- **GOEWS Cleat Customization:** Set cleat position and custom height for GOEWS compatibility.
- **Modular Design:** Easily adapt for different mounting scenarios and hardware.

## Usage

1. Open `rail-bracket.scad` in OpenSCAD.
2. Adjust the parameters at the top of the file to match your mounting system and requirements:
    - `Connection_Type` for mounting system
    - `back_width`, `backHeight`, `catch_length`, `catch_back_thickness`, etc.
    - Slot and catch options for fit and printability
3. Render the model and export for 3D printing.

## Parameters

- `Connection_Type`: Select mounting system (`Multipoint`, `Multiconnect - Multiboard`, `Multiconnect - openGrid`, `Multiconnect - Custom Size`, `GOEWS`)
- `back_width`, `backHeight`: Backplate dimensions
- `catch_length`, `catch_back_thickness`, `catch_floor_thickness`, `catch_opening_height`, `catch_rounding`: Catch geometry
- `multiConnectVersion`, `customDistanceBetweenSlots`, `slotQuickRelease`, `dimpleScale`, `slotTolerance`, `slotDepthMicroadjustment`, `onRampEnabled`, `On_Ramp_Every_X_Slots`, `Multiconnect_Stop_Distance_From_Back`: Slot customization
- `GOEWS_Cleat_position`, `GOEWS_Cleat_custom_height_from_top_of_back`: GOEWS cleat options

## License

This script is licensed under the Creative Commons 4.0 Attribution Non-Commercial Share Alike license. For more details, refer to the license terms in the script comments.

## Acknowledgments

- **@David D** on Printables for Multiconnect.
- **Jonathan** at Keep Making for the Multiboard ecosystem.
- **@SnazzyGreenWarrior** on GitHub for contributions to Multipoint-compatible mounts.
- **MrExo3D** on Printables for the GOEWS system.

For questions or contributions, see [ejwill on GitHub](https://github.com/ejwill).