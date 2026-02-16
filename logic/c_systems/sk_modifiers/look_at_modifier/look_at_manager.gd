## currently used for enemies only
class_name ELookAtManager
extends BaseLookAtManager


@export_group("Modifiers")
@export var modifiers: Array[LookAtHeadModifier3D]
@export var initial_mode: InitialMode = InitialMode.RANDOM


@export_group("Randomness")
@export var min_duration: float = 10.0
@export var max_duration: float = 20.0
## random not looking will be longer than looking if > 0.0
@export var boost_dur_for_not_looking: float = 10.0

@export_group("Proximity")
@export var proximity_threshold: float = 2.5


# @onready var vosn: VisibleOnScreenNotifier3D = %VOSN
var vosn = null # WARNING: temporary

enum InitialMode {
	RANDOM,
	FORCE_OFF,
	FORCE_ON,
	DISTANCE,
}


enum LookState {
	FORCE_ON,
	FORCE_OFF,
	TOO_CLOSE_ON,
	TEMP_ON,
	RANDOM_ON,
	RANDOM_OFF,
	DISTANCE_ON,
	DISTANCE_OFF
}


var curr_state: LookState
var _random_look_timer: float = 0.0
var _temp_look_timer: float = 0.0


func __hard_dependencies() -> Array:
	return super.__hard_dependencies() + [
		_target_marker
	]

func __soft_dependencies() -> Array:
	return [
		# vosn,
	]

func __hard_validation() -> bool:
	var _r := true
	if len(modifiers) == 0:
		_r = false
	return _r


func initialise(target_marker_: LookAtCharacterMarker, my_marker_: LookAtCharacterMarker) -> void:
	_my_marker = my_marker_

	if target_marker_:
		__log_("initialise", target_marker_)
		_target_marker = target_marker_

		for modifier: LookAtHeadModifier3D in modifiers:
			if modifier:
				modifier.set_marker(_target_marker)

		match initial_mode:
			InitialMode.RANDOM:
				look_random_whatever()
			InitialMode.FORCE_OFF:
				look_force(false)
			InitialMode.FORCE_ON:
				look_force(true)
			InitialMode.DISTANCE:
				set_distance_mode()
			_:
				__log_warn("initial mode is not supported", "", "will be random", initial_mode)
				look_random_whatever()


	if not __perform_validation():
		__log_warn_soft("not working")
		set_process(false)
		shut_down()
	else:
		if vosn:
			SigUtils.safe_connect(vosn.screen_entered, _on_sceen_entered)
			SigUtils.safe_connect(vosn.screen_exited, _on_sceen_exited)
			if not vosn.is_on_screen():
				_on_sceen_exited()
			

func _on_sceen_entered():
	__log_("vosn", "screen entered✴️")
	if __validation_ok():
		set_process(true)

func _on_sceen_exited():
	__log_("vosn", "screen exited 🚪")
	set_process(false)
	_apply_look_state(false)


func _process(delta: float) -> void:
	if _temp_look_timer > 0:
		_temp_look_timer -= delta
	
	if _random_look_timer > 0:
		_random_look_timer -= delta


	match curr_state:
		LookState.FORCE_ON:
			pass
		LookState.FORCE_OFF:
			pass
		LookState.RANDOM_ON:
			if _random_look_timer <= 0:
				look_random(false)
		LookState.RANDOM_OFF:
			if _random_look_timer <= 0:
				look_random(true)
			elif _is_too_close(0.9):
				_change_state(LookState.TOO_CLOSE_ON)
		LookState.TEMP_ON:
			if _temp_look_timer <= 0:
				look_random_whatever()
		LookState.TOO_CLOSE_ON:
			if not _is_too_close(0.9):
				look_random_whatever()
		LookState.DISTANCE_ON:
			if not _is_too_close(0.9):
				_change_state(LookState.DISTANCE_OFF)
		LookState.DISTANCE_OFF:
			if _is_too_close(1.1):
				_change_state(LookState.DISTANCE_ON)


	var should_look: bool = false
	match curr_state:
		LookState.FORCE_ON, LookState.TOO_CLOSE_ON, LookState.RANDOM_ON, LookState.TEMP_ON, LookState.DISTANCE_ON:
			should_look = true
		_:
			should_look = false

	_apply_look_state(should_look)


var last_applied_value: bool = false

func _apply_look_state(should_look: bool) -> void:
	if should_look == last_applied_value:
		return
	last_applied_value = should_look
	for m in modifiers:
		if m:
			m.set_to_work(should_look)


# --- API ---

func look_for_duration(time: float) -> void:
	if time <= 0.0:
		return
	__log_("look_for_duration", time)
	_temp_look_timer = time
	_change_state(LookState.TEMP_ON)


func look_random(is_looking: bool) -> void:
	__log_("look_random")
	var _next_state := LookState.RANDOM_ON if is_looking else LookState.RANDOM_OFF
	_reset_random_timer(0.0 if _next_state == LookState.RANDOM_ON else boost_dur_for_not_looking)
	_change_state(_next_state)

func look_random_whatever() -> void:
	__log_("look_random_whatever")
	var _next_state := LookState.RANDOM_ON if ra.coinflip() else LookState.RANDOM_OFF
	_reset_random_timer(0.0 if _next_state == LookState.RANDOM_ON else boost_dur_for_not_looking)
	_change_state(_next_state)


func look_force(is_looking: bool) -> void:
	__log_("look_force", is_looking)
	_change_state(LookState.FORCE_ON if is_looking else LookState.FORCE_OFF)


func set_distance_mode() -> void:
	__log_("set_distance_mode")
	_change_state(LookState.DISTANCE_ON if _is_too_close(1.0) else LookState.DISTANCE_OFF)


func shut_down() -> void:
	__log_("shut_down")
	_apply_look_state(false)
	set_process(false)
	if vosn:
		SigUtils.safe_disconnect(vosn.screen_entered, _on_sceen_entered)
		SigUtils.safe_disconnect(vosn.screen_exited, _on_sceen_exited)
			

# --- Internal ---


func _change_state(new_state: LookState) -> void:
	__log_("↪️", LookState.find_key(new_state), "from", LookState.find_key(curr_state) if curr_state else "-x-")
	curr_state = new_state


func _is_too_close(mult: float) -> bool:
	if not is_instance_valid(_target_marker):
		__log_warn("not _target_marker.is_instance_valid()")
		return false

	if not is_instance_valid(_my_marker):
		__log_warn("not _my_marker.is_instance_valid()")
		return false
	
	var _dist_sq: float = _my_marker.global_position.distance_squared_to(_target_marker.global_position)
	var is_close: bool = _dist_sq * mult < MathUtil.fpow2(proximity_threshold)
	return is_close


func _reset_random_timer(boost_timings: float = 0.0) -> void:
	_random_look_timer = randf_range(min_duration + boost_timings, max_duration + boost_timings)
	__log_("_reset_random_timer", "set to", _random_look_timer)


##

func __LOG_B() -> bool:
	return false
