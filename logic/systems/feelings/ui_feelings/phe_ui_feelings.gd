extends Node


@onready var e_feelings: PHEFeelings = %PHEFeelings

@onready var back_health_bar: TextureProgressBar = %BackHealthBar
@onready var health_bar: TextureProgressBar = %HealthBar

## Delayed damage indicator
## shows where health was before damage
@onready var ghost_bar: TextureProgressBar = %GhostBar


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

var _is_fading_out = false

func _ready() -> void:
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


func _process(delta: float):
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


func _fade_out_and_hide():
	if _is_pulsing:
		_stop_low_health_pulse()
	
	var panels = [health_bar, back_health_bar, ghost_bar]
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
	
	var config = TweenConfig.new(Tween.TRANS_QUAD, Tween.EASE_IN)
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
