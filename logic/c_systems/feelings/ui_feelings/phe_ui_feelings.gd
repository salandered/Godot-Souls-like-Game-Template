class_name EnemyUIFeelings
extends NodeSystem


@onready var _health_bar: TextureProgressBar = %HealthBar
@onready var _ghost_bar: TextureProgressBar = %GhostBar
@onready var _back_health_bar: TextureProgressBar = %BackHealthBar
@onready var _bars_container: MarginContainer = %Bars


var e_feelings: PHEFeelings
var _anchor_3d: Node3D
var _camera: Camera3D

var PULSE_DURATION := 1.0
var _pulse_tween: Tween

var _is_pulsing: bool = false
var _is_fading_out := false

var _prev_health: float

var __UI_HARD_ENABLE: bool = false
var ui_can_be_shown: bool = false

var health_bar: FeelingBar


func __hard_dependencies() -> Array:
	return [
		_bars_container,
		_health_bar
	]

func __soft_dependencies() -> Array:
	return [
		_ghost_bar,
		_back_health_bar
	]


func initialise(enable_ui: bool, e_feelings_: PHEFeelings, anchor_node_: Node3D = null) -> void:
	self .e_feelings = e_feelings_
	self._anchor_3d = anchor_node_
	self.__UI_HARD_ENABLE = enable_ui


	health_bar = FeelingBar.new(
		_health_bar,
		_ghost_bar,
		_back_health_bar,
		_bars_container,
		e_feelings.get_curr_health(),
		e_feelings.get_max_health(),
		FeelingBarConfig.new(),
		"EHealth"
	)
	if not __UI_HARD_ENABLE:
		hide_ui()
		__log_("__UI_HARD_ENABLE", __UI_HARD_ENABLE, "__validated = false")
		__validated = false
		return

	if _anchor_3d:
		_camera = get_viewport().get_camera_3d()
		
		health_bar.modulate_a(0.0)
		var _tw := create_tween()
		_tw.tween_property(health_bar.container, PropC.MODULATE_A, 1.0, 0.3)
		health_bar.scale_xy(0.5)

	hide_ui()

	## 
	_prev_health = e_feelings.get_curr_health()

	__perform_validation(true)


func _process(delta: float) -> void:
	if _anchor_3d:
		_update_floating_position()
	# polling on every frame - may be switch to signals
	_update_health_bar()


func _update_health_bar():
	var curr_health := e_feelings.get_curr_health()
	if curr_health == _prev_health:
		return

	health_bar.animate_main_bar_value_change(self , curr_health)
	
	var is_damage := curr_health < _prev_health
		
	if is_damage:
		health_bar.animate_ghost_bar_value_change(self , _prev_health, curr_health)
	else:
		# instant ghost bar update on heal
		health_bar.set_ghost_bar_value(curr_health)
	
	if e_feelings.is_lower_to_switch_phase() and not _is_pulsing:
		_start_low_health_pulse()
	elif not e_feelings.is_lower_to_switch_phase() and _is_pulsing:
		_stop_low_health_pulse()
	

	if curr_health <= 0 and not _is_fading_out:
		_is_fading_out = true
		_fade_out_and_hide()

	_prev_health = curr_health


func _update_floating_position() -> void:
	if not is_instance_valid(_anchor_3d):
		return
	
	if not is_instance_valid(_camera):
		_camera = get_viewport().get_camera_3d()
		return

	var anchor_pos := _anchor_3d.global_position
	
	# Hide if behind camera
	if _camera.is_position_behind(anchor_pos):
		hide_ui()
		return
	
	# Ensure visible if previously hidden by camera check
	# (Note: Logic in _fade_out_and_hide might conflict if we aren't careful, 
	# but strictly for camera checks this is fine)
	if not _is_fading_out:
		show_ui()

	var screen_pos := _camera.unproject_position(anchor_pos)
	
	# Center the bar using the container size
	# Assuming Pivot is top-left (default)
	var centered_pos := screen_pos

	centered_pos.x -= health_bar.container.size.x * health_bar.container.scale.x / 2.0
	
	# Apply to the container, or self if this script is on the root Control
	health_bar.container.position = centered_pos


func _fade_out_and_hide():
	if _is_pulsing:
		_stop_low_health_pulse()
	
	health_bar.fade_out_and_hide(self )
	

# region: PULSE

func _start_low_health_pulse() -> void:
	if _is_pulsing:
		return
	_is_pulsing = true
	
	UIUtils.kill_tween_if_exists(_pulse_tween)
	
	_pulse_tween = UIUtils.start_pulse(health_bar.main_bar, 0.5, PULSE_DURATION)


func _stop_low_health_pulse() -> void:
	_is_pulsing = false
	UIUtils.stop_pulse(health_bar.main_bar, _pulse_tween)

# endregion


func show_ui():
	if __UI_HARD_ENABLE and ui_can_be_shown:
		health_bar.set_visible(true)

func hide_ui():
	health_bar.set_visible(false)


func _on_ph_enemy_sig_awaken() -> void:
	if __UI_HARD_ENABLE and _prev_health > 0.0:
		ui_can_be_shown = true
		health_bar.set_visible(true)


## to override
func __LOG_B() -> bool:
	return LogToggler.FEEL.ENEMY_UI
