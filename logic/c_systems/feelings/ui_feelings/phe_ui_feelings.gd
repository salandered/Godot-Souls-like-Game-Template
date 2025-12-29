class_name EnemyUIFeelings
extends NodeSystem


@onready var back_health_bar: TextureProgressBar = %BackHealthBar
@onready var health_bar: TextureProgressBar = %HealthBar

## Delayed damage indicator
## shows where health was before damage
@onready var ghost_bar: TextureProgressBar = %GhostBar
@onready var bars: MarginContainer = $Bars


var e_feelings: PHEFeelings

## how long the change animation should take
var ANIM_HEALTH_DUR: float = 0.2
var GHOST_HEALTH_DUR: float = 0.8
var GHOST_DELAY: float = 0.5
var PULSE_DURATION: float = 1.0
var FADEOUT_DURATION: float = 1.0

var _is_pulsing: bool = false

var _health_tween: Tween
var _ghost_tween: Tween
var _pulse_tween: Tween

var _prev_health: float

var _is_fading_out := false


var _anchor_3d: Node3D
var _camera: Camera3D

var UI_ENABLE: bool = false
var ui_can_be_shown: bool = false

func initialise(enable_ui: bool, e_feelings_: PHEFeelings, anchor_node_: Node3D = null) -> void:
	self.e_feelings = e_feelings_
	self._anchor_3d = anchor_node_
	self.UI_ENABLE = enable_ui

	if not UI_ENABLE:
		hide_ui()
		__log_("UI_ENABLE", UI_ENABLE, "__initialised = false")
		__initialised = false
		return

	if _anchor_3d:
		_camera = get_viewport().get_camera_3d()
		# We modulate the CONTAINER, not self
		bars.modulate.a = 0.0
		var tw = create_tween()
		tw.tween_property(bars, "modulate:a", 1.0, 0.3)
		bars.scale.x /= 2.0
		bars.scale.y /= 2.0

	hide_ui()

	## BACK
	back_health_bar.max_value = e_feelings.get_max_health()
	# should not be changing
	back_health_bar.value = e_feelings.get_max_health()
	
	## HEALTH BAR
	var max_health := e_feelings.get_max_health()
	health_bar.max_value = max_health
	health_bar.value = e_feelings.get_curr_health()
	
	## GHOST BAR
	ghost_bar.texture_progress = health_bar.texture_progress # Reuse same texture
	ghost_bar.max_value = max_health
	ghost_bar.value = e_feelings.get_curr_health()
	# ghost_bar.modulate = Color(1, 1, 1, 0.4) # Better in UI
	
	## 
	_prev_health = e_feelings.get_curr_health()

	__validate_dependencies()


func _process(delta: float) -> void:
	if __could_not_initialised():
		# here its not like we had problem initialising, but UI_ENABLE may be false
		return
	if _anchor_3d:
		_update_floating_position()
	# polling on every frame - may be switch to signals
	_update_health_bar()


func _update_health_bar():
	var curr_health := e_feelings.get_curr_health()
	if curr_health == _prev_health:
		return

	_animate_health_change(curr_health)
	
	var is_damage := curr_health < _prev_health
		
	if is_damage:
		_animate_ghost_bar_change(_prev_health, curr_health)
	else:
		# instant ghost bar update on heal
		ghost_bar.value = curr_health
	
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

	var anchor_pos = _anchor_3d.global_position
	
	# Hide if behind camera
	if _camera.is_position_behind(anchor_pos):
		hide_ui()
		return
	
	# Ensure visible if previously hidden by camera check
	# (Note: Logic in _fade_out_and_hide might conflict if we aren't careful, 
	# but strictly for camera checks this is fine)
	if not _is_fading_out:
		show_ui()

	var screen_pos = _camera.unproject_position(anchor_pos)
	
	# Center the bar using the container size
	# Assuming Pivot is Top-Left (default)
	var centered_pos = screen_pos

	centered_pos.x -= bars.size.x * bars.scale.x / 2.0
	
	# Apply to the container, or self if this script is on the root Control
	bars.position = centered_pos


func _fade_out_and_hide():
	if _is_pulsing:
		_stop_low_health_pulse()
	
	var panels := [health_bar, back_health_bar, ghost_bar]
	UIUtils.fade_out_and_hide(self, panels, FADEOUT_DURATION)


func _animate_health_change(target_value: float) -> void:
	UIUtils.kill_tween_if_exists(_health_tween)

	_health_tween = UIUtils.animate_property(
		self,
		health_bar,
		"value",
		target_value,
		ANIM_HEALTH_DUR,
	)


func _animate_ghost_bar_change(from_value: float, to_value: float) -> void:
	UIUtils.kill_tween_if_exists(_ghost_tween)
	
	ghost_bar.value = from_value
	
	var config := TweenConfig.new(Tween.TRANS_QUAD, Tween.EASE_IN)
	_ghost_tween = UIUtils.animate_property(
		self,
		ghost_bar,
		"value",
		to_value,
		GHOST_HEALTH_DUR,
		GHOST_DELAY,
		config
	)


func _start_low_health_pulse() -> void:
	if _is_pulsing:
		return
	_is_pulsing = true
	
	UIUtils.kill_tween_if_exists(_pulse_tween)
	
	_pulse_tween = UIUtils.start_pulse(health_bar, 0.5, PULSE_DURATION)


func _stop_low_health_pulse() -> void:
	_is_pulsing = false
	UIUtils.stop_pulse(health_bar, _pulse_tween)


func _on_ph_enemy_sig_awaken() -> void:
	if UI_ENABLE and _prev_health > 0.0:
		ui_can_be_shown = true
		bars.visible = true


func show_ui():
	if UI_ENABLE and ui_can_be_shown:
		bars.visible = true

func hide_ui():
	bars.visible = false
