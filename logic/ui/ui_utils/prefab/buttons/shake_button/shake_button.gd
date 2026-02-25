@tool
extends Button
class_name ShakeButton

@onready var panel: Panel = %Panel

@export var def_modulation_color = Color(1.0, 1.0, 1.0, 1.0):
	set(value):
		def_modulation_color = value
		if is_node_ready():
			_change_shader_modulation_color(value)

@export var modulation_color_pressed = Color(0.65, 0.65, 0.65, 1.0)

@export_group("Shake Power")
@export var def_shake_power := 0.011
@export var add_shake_power_on_hover := 0.01

@export_group("Shake Speed")
@export var def_shake_speed := 1.5
@export var add_shake_speed_on_hover := 0.4


@export_group("Shine Effect")
@export var enable_shine := false:
	set(value):
		enable_shine = value
		if is_node_ready():
			_change_shader_param(SHADER_PARAM_ENABLE_SHINE, value)


const SHADER_PARAM_MODULATION_COLOR = "modulation_color"
const SHADER_PARAM_SHAKE_POWER = "shake_power"
const SHADER_PARAM_SHAKE_SPEED = "shake_speed"
const SHADER_PARAM_TIME_OFFSET = "time_offset"
const SHADER_PARAM_ENABLE_SHINE = "enable_shine"


func _ready() -> void:
	_update_visuals(def_shake_power, def_shake_speed, def_modulation_color)
	_change_shader_param(SHADER_PARAM_ENABLE_SHINE, enable_shine)

	if not eu.is_editor():
		# randomize phase
		if _validate_panel():
			panel.material.set_shader_parameter(SHADER_PARAM_TIME_OFFSET, randf_range(0.0, 100.0))
		
		SigUtils.safe_connect_pairs([
			[mouse_entered, _on_mouse_entered],
			[mouse_exited, _on_mouse_exited],
			[button_down, _on_button_down],
			[button_up, _on_button_up],
		])


## PUBLIC


func get_panel() -> Panel:
	return panel


## ON SIGNALS

func _on_button_down() -> void:
	# PRESS STATE: Base + (Add * 2)
	var p = def_shake_power + (add_shake_power_on_hover * 2.0)
	var s = def_shake_speed + (add_shake_speed_on_hover * 2.0)
	_update_visuals(p, s, modulation_color_pressed)


func _on_button_up() -> void:
	# Check if we are still hovering to decide return state
	if is_hovered():
		_on_mouse_entered() # Return to Hover state
	else:
		_on_mouse_exited() # Return to Idle state


func _on_mouse_entered():
	# HOVER STATE: Base + Add
	var p = def_shake_power + add_shake_power_on_hover
	var s = def_shake_speed + add_shake_speed_on_hover
	# Keep current color (handled by button down/up), or enforce default if not pressed?
	# Usually mouse enter shouldn't reset color if we were somehow holding it, 
	# but for a standard button, you can't enter while holding unless you clicked outside.
	# We'll safely apply default color here to ensure clean state.
	_update_visuals(p, s, def_modulation_color)


func _on_mouse_exited():
	# IDLE STATE: Base
	_update_visuals(def_shake_power, def_shake_speed, def_modulation_color)


## INTERNAL

func _update_visuals(power: float, speed: float, color: Color) -> void:
	_change_shader_modulation_color(color)
	_change_shader_param(SHADER_PARAM_SHAKE_POWER, power)
	_change_shader_param(SHADER_PARAM_SHAKE_SPEED, speed)


func _change_shader_modulation_color(color: Color):
	if _validate_panel():
		panel.material.set_shader_parameter(SHADER_PARAM_MODULATION_COLOR, color)


## value is String or Boolean usually
func _change_shader_param(param_name: String, value: Variant):
	if _validate_panel():
		panel.material.set_shader_parameter(param_name, value)


func _validate_panel() -> bool:
	return panel and panel.material and panel.material is ShaderMaterial
