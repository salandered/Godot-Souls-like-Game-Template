@tool
class_name M_OptionControl
extends ControlLogger

signal setting_changed(value)

enum OptionSections {
	NONE,
	INPUT,
	AUDIO,
	VIDEO,
	GAME,
	APPLICATION,
	CUSTOM,
}

const OptionSectionNames: Dictionary = {
	OptionSections.NONE: "",
	OptionSections.INPUT: M_AppSettings.INPUT_SECTION,
	OptionSections.AUDIO: M_AppSettings.AUDIO_SECTION,
	OptionSections.VIDEO: M_AppSettings.VIDEO_SECTION,
	OptionSections.GAME: M_AppSettings.GAME_SECTION,
	OptionSections.APPLICATION: M_AppSettings.APPLICATION_SECTION,
	OptionSections.CUSTOM: M_AppSettings.CUSTOM_SECTION,
}

## Locks config names in case of issues with inherited scenes.
## Intentionally put first for initialization.
@export var lock_config_names: bool = false
## Defines text displayed to the user.
@export var option_name: String:
	set(value):
		var _update_config: bool = option_name.to_pascal_case() == key and not lock_config_names
		option_name = value
		if is_inside_tree():
			%OptionLabel.text = "%s%s" % [option_name, label_suffix]
		if _update_config:
			key = option_name.to_pascal_case()
## Defines what section in the config file this option belongs under.
@export var option_section: OptionSections:
	set(value):
		var _update_config: bool = OptionSectionNames[option_section] == section and not lock_config_names
		option_section = value
		if _update_config:
			section = OptionSectionNames[option_section]

@export_group("Config Names")
## Defines the key for this option variable in the config file.
@export var key: String
## Defines the section for this option variable in the config file.
@export var section: String
@export_group("Format")
@export var label_suffix: String = " "
@export_group("Properties")
## Defines whether the option is editable, or only visible by the user.
@export var editable: bool = true: set = set_editable
## Defines what kind of variable this option stores in the config file.
@export var property_type: Variant.Type = TYPE_BOOL

## It is advised to use an external editor to set the default value in the scene file.
## Godot can experience a bug (caching issue?) that may undo changes.
var default_value
var _connected_nodes: Array


# M_OptionControl is a "Smart Frame" for a setting.
# You give the frame a label (the option_name, like "Fullscreen").
# You put an interactive element inside the frame (like the CheckButton).
# Script then automatically does all the work:
#    - automatically wires up the CheckButton.
#    - automatically loads the correct current value from your settings file.


func _ready() -> void:
	lock_config_names = lock_config_names
	option_section = option_section
	option_name = option_name
	property_type = property_type
	
	# TODO: just hard code defaults for all settings, no @export
	# Can be lost somehow. (See default_value description)
	# And indeed it was lost. So this tries to make a safe default automatically.
	if default_value == null:
		match property_type:
			TYPE_BOOL: default_value = false
			TYPE_INT: default_value = 0
			TYPE_FLOAT: default_value = 0.0
			TYPE_STRING: default_value = ""
			TYPE_COLOR: default_value = Color.WHITE
			TYPE_VECTOR2I: default_value = Vector2i(0, 0) # resolution
			TYPE_VECTOR2: default_value = Vector2(0, 0)
			_: __log_warn("non primitive type. Cannot assign safe default_value", "M_OptionControl", "", "Using safe default", "property type/Option name", property_type, option_name)
		
		if key == M_AppSettings.BRIGHTNESS:
			default_value = 1.0
		elif key == M_AppSettings.SHADOW_MODE:
			default_value = 1
		elif key == M_AppSettings.VOLUMETRIC_FOG:
			default_value = true
		elif key == M_AppSettings.FPS_LIMIT:
			default_value = 60
		elif key == M_AppSettings.DISPLAY_MODE:
			default_value = 2
		elif key == M_AppSettings.SCREEN_RESOLUTION:
			default_value = Vector2i(0, 0)
		elif key == M_AppSettings.V_SYNC:
			default_value = 1
		elif key == M_AppSettings.UI_SCALE:
			default_value = 1.0
		elif key == M_AppSettings.MSAA_3D:
			default_value = 1
	
		if default_value != null:
			__log_warn("Auto-fixed NULL default_value", "M_OptionControl", "Using safe default", "Safe Default/property type/Option name", default_value, property_type, option_name)

	if default_value == null:
		__log_warn("Option Control has NULL default_value", "M_OptionControl", "", "Option Name/Section/Key", [option_name, section, key])

	var value_from_settings: Variant = _get_setting(default_value)
	
	__log_(name + "_ready🦕", pp.s_in_q(
		"Option Name (User side)", option_name,
		"Section/Key in config file", [section, key],
		"Option section", option_section,
		"propery type", property_type,
		"lock_config_names", lock_config_names))
	
	__log_(name + "_ready🦕", pp.s_in_q("def val", default_value, "returned val from settings", value_from_settings))
	_set_value(value_from_settings, true)

	for child in get_children():
		_connect_option_inputs(child)

	child_entered_tree.connect(_connect_option_inputs)


func _on_setting_changed(value) -> void:
	if u.is_editor(): return
	M_PlayerConfig.set_config(section, key, value)
	setting_changed.emit(value)

func _get_setting(default: Variant = null) -> Variant:
	return M_PlayerConfig.get_config(section, key, default)

func _connect_option_inputs(node) -> void:
	if node in _connected_nodes: return
	if node is Button:
		if node is OptionButton:
			node.item_selected.connect(_on_setting_changed)
		elif node is ColorPickerButton:
			node.color_changed.connect(_on_setting_changed)
		else:
			node.toggled.connect(_on_setting_changed)
		_connected_nodes.append(node)
	if node is Range:
		node.value_changed.connect(_on_setting_changed)
		_connected_nodes.append(node)
	if node is LineEdit or node is TextEdit:
		node.text_changed.connect(_on_setting_changed)
		_connected_nodes.append(node)

func _set_value(value: Variant, on_init: bool = false) -> Variant:
	if value == null:
		return
	for node in get_children():
		if node is Button:
			if node is OptionButton:
				node.select(value as int)
			elif node is ColorPickerButton:
				node.color = value as Color
			else:
				node.button_pressed = value as bool
		if node is Range:
			node.value = value as float
		if node is LineEdit or node is TextEdit:
			node.text = "%s" % value
	return value

func set_value(value: Variant) -> void:
	value = _set_value(value)
	_on_setting_changed(value)

func set_editable(value: bool = true) -> void:
	editable = value
	for node in get_children():
		if node is Button:
			node.disabled = !editable
		if node is Slider or node is SpinBox or node is LineEdit or node is TextEdit:
			node.editable = editable


func _set(property: StringName, value: Variant) -> bool:
	if property == "value":
		set_value(value)
		return true
	return false

func _get_property_list() -> Array[Dictionary]:
	return [
		{"name": "value", "type": property_type, "usage": PROPERTY_USAGE_NONE},
		{"name": "default_value", "type": property_type}
	]


func __LOG_B() -> bool:
	return LogToggler.UI.M_OPTION_CONTROL
