class_name PropC ## Stands for Propery Constant
extends RefCounted


## Example usage: 
##    - tweening property
##    - working with theme overrides
## NOTE: should be named exactly like the property.
##	 non a-z symbols replaced with underscore
## WARNING: not using StringName. These constants usually represent NodePath

## audio
const VOLUME_DB = "volume_db"


## Node / Node3D
const ADD_CHILD = "add_child"
const GLOBAL_POSITION_Y = "global_position:y"
const POSITION_Z = "position:z"


## material
const ALBEDO = "albedo"


## CONTROL
# region

## 
const V_SEPARATION = "v_separation"
const MODULATE_A = "modulate:a"
const MODULATE = "modulate"


## font
const FONT_SIZE := "font_size"
const NORMAL_FONT_SIZE := "normal_font_size"
const BOLD_FONT_SIZE := "bold_font_size"
const ITALICS_FONT_SIZE := "italics_font_size"


## margin
const MARGIN_LEFT = "margin_left"
const MARGIN_RIGHT = "margin_right"
const MARGIN_TOP = "margin_top"
const MARGIN_BOTTOM = "margin_bottom"

# endregion


## Godot Project Settings

const APPLICATION_CONFIG_VERSION = "application/config/version"
const PHYSICS_3D_DEFAULT_GRAVITY = "physics/3d/default_gravity"
const APPLICATION_CONFIG_NAME = "application/config/name"
const APPLICATION_RUN_MAIN_SCENE = "application/run/main_scene"
const AUDIO_DRIVER_ENABLE_INPUT = "audio/driver/enable_input"
