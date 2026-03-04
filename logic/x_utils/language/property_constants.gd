class_name PropC ## Stands for Property Constant
extends RefCounted


## Example usage: 
##    - tweening property
##    - working with theme overrides
## NOTE: NAMING
##   - should be named exactly like the property.
##	 - non a-z symbols replaced with underscore
##   - if additional info is needed, use class with a const inside
## WARNING: TYPING
##   - depending on the use case, we need String, StringName and NodePath.
##   - NodePath is currently not used in project typings, so make sure to use String. 
##	 	- DANGER: StringName to NodePath results in error
##   - In case of uncertainty, use String
## --------------------------------------------------


## AUDIO
const VOLUME_DB = "volume_db"
const CUTOFF_HZ = "cutoff_hz"


## Node / Node3D
const ADD_CHILD = "add_child"
const GLOBAL_POSITION_Y = "global_position:y"
const POSITION_Z = "position:z"
const POSITION_X = "position:x"


## CONTROL PROPS
## WARNING: not using StringName. These constants represent NodePath

const V_SEPARATION = "v_separation"
const MODULATE_A = "modulate:a"
const MODULATE = "modulate"


## USED FOR THEME (StringName)

## font
const NORMAL_FONT := &"normal_font"
const FONT_SIZE := &"font_size"
const NORMAL_FONT_SIZE := &"normal_font_size"
const BOLD_FONT_SIZE := &"bold_font_size"
const ITALICS_FONT_SIZE := &"italics_font_size"

## margin
const MARGIN_LEFT = &"margin_left"
const MARGIN_RIGHT = &"margin_right"
const MARGIN_TOP = &"margin_top"
const MARGIN_BOTTOM = &"margin_bottom"

## 
class STYLEBOX:
	const PANEL = &"panel"
	const NORMAL = &"normal"

class THEME_TYPE:
	const PANEL_CONTAINER = &"PanelContainer"


## GODOT PROJECT SETTINGS (api uses String)

const APPLICATION_CONFIG_VERSION = "application/config/version"
const PHYSICS_3D_DEFAULT_GRAVITY = "physics/3d/default_gravity"
const APPLICATION_CONFIG_NAME = "application/config/name"
const APPLICATION_RUN_MAIN_SCENE = "application/run/main_scene"
const AUDIO_DRIVER_ENABLE_INPUT = "audio/driver/enable_input"


## PROPERTY LIST
## this dict: https://docs.godotengine.org/en/stable/classes/class_object.html#class-object-method-get-property-list

class PROPERTY_LIST:
	const NAME = "name"
	const CLASS_NAME = "class_name"


## CUSTOM CLASS NAMES
class CUSTOM_CLASS_NAME:
	const INTERACT_AREA = &"InteractArea"
	const WEATHER_CHANGE_AREA = &"WeatherChangeArea"
	const BREAKABLE_AREA = &"BreakableArea"
	const COMMON_AREA = &"CommonArea"
