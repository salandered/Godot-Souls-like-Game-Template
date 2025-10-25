@tool
@icon("res://-assets-/x_misc/x_icons/node-colors/purple.png")
extends BaseAnimatorManager

class_name EnemyAnimatorManager


@onready var anim_container: AnimationContainer = %AnimContainer
@onready var native_player: AnimationPlayer = %NativePlayer

# Track the starting position to calculate time_spent
var _curr_anim_start_position: float = 0.0
var _curr_anim: AnimationData

## SET ANIMATIONS TO PLAY AND CONFIGURE ▶️

func set_anim_to_play(anim_id: String, blend_for: float = 0.0, start_time_offset: float = 0.0) -> void:
	if anim_id == "":
		print()
	if blend_for < 0:
		print_.warn("blend_for < 0 is not supported, 0 will be used:" + str(blend_for))
		blend_for = 0
	
	if start_time_offset < 0:
		print_.warn("start time shift < 0 is not supported, 0 will be used: " + str(start_time_offset))
		start_time_offset = 0
	
	var anim: AnimationData = anim_container.get_by_anim_id(anim_id)

	if anim == null:
		push_error("set_anim_to_play fail: animation not found: " + anim_id)
		return

	if not native_player.has_animation(anim_id):
		push_error("set_anim_to_play fail: animation not found: " + anim_id)
		return
	
	# NOTE: playing anim and setting _curr_anim is atomic
	native_player.play(anim.anim_id, blend_for, anim.speed_scale)
	__log_new_anim(_curr_anim, anim)
	_curr_anim = anim
	#
	
	if start_time_offset > 0:
		native_player.seek(start_time_offset, true)

	_curr_anim_start_position = start_time_offset


func set_global_speed_scale(new_scale: float):
	var max_speed_scale := 2.0
	var min_speed_scale := 0.1
	new_scale = snappedf(new_scale, 0.01)
	
	if new_scale < min_speed_scale or new_scale > max_speed_scale:
		new_scale = clamp(new_scale, min_speed_scale, max_speed_scale)
	
	if absf(native_player.speed_scale - new_scale) > 0.005:
		# __log_("set_global_speed_scale to", new_scale, "  (from", native_player.speed_scale, ")")
		native_player.speed_scale = new_scale


func reset_global_speed_scale():
	# __log_("reset_global_speed_scale to 1.0")
	native_player.speed_scale = 1.0

## if no anim playing returns 0.0
func get_global_speed_scale() -> float:
	return native_player.speed_scale


## READ INFO ABOUT WHAT'S PLAYING

func get_current_anim_effective_time_spent() -> float:
	return native_player.current_animation_position

func get_curr_anim_time_spent() -> float:
	return native_player.current_animation_position - _curr_anim_start_position

## returns 0.0 if no curr anim
func get_curr_anim_effective_duration() -> float:
	if not _curr_anim:
		return 0.0

	var _base_duration: float
	if _curr_anim.is_looping:
		_base_duration = _curr_anim.duration
	else:
		_base_duration = _curr_anim.duration - _curr_anim_start_position
	
	# account for speed scales
	var playing_speed = native_player.get_playing_speed()
	# returns 0 if not playing. then just _base_duration (not INF!)
	if playing_speed == 0:
		return _base_duration
	
	return _base_duration / absf(playing_speed)

## returns empty string if nothing's playing
func get_curr_anim_id() -> String:
	if not _curr_anim:
		return ""
	return _curr_anim.anim_id


func is_playing() -> bool:
	return native_player.is_playing()


## may be null
func get_curr_anim() -> AnimationData:
	return _curr_anim


## ROOT MOTION

func get_root_motion_position(y_zeroed: bool = true) -> Vector3:
	var delta_pos = native_player.get_root_motion_position()
	if y_zeroed:
		delta_pos.y = 0
	return delta_pos


## FUTRURE METHODS 

# func get_playing_speed() -> float:
# 	return native_player.get_playing_speed()

# func pause() -> void:
# 	native_player.pause()

# func stop(keep_state: bool = false) -> void:
# 	native_player.stop(keep_state)

# func seek(seconds: float, update: bool = false, update_only: bool = false) -> void:
# 	native_player.seek(seconds, update, update_only)

# func play_backwards(anim_name: String = "", custom_blend: float = -1) -> void:
# 	native_player.play_backwards(anim_name, custom_blend)

# func queue(anim_name: String) -> void:
# 	# Queue animation to play after current one finishes
# 	native_player.queue(anim_name)


# func set_blend_time(anim_from: String, anim_to: String, seconds: float) -> void:
# 	native_player.set_blend_time(anim_from, anim_to, seconds)


func __log_new_anim(prev_anim: AnimationData, new_anim: AnimationData):
	var _prev_anim_name = "-x-"
	if prev_anim:
		_prev_anim_name = pp.in_q(_curr_anim.anim_name)
	var _curr_anim_name = pp.in_q(new_anim.anim_name)
	var _msg = pp.s("set_anim_to_play:",
		_curr_anim_name,
		"curr glob-sp-scale", get_global_speed_scale(),
		"  ", pp.in_br("from prev " + _prev_anim_name))
	__log_(_msg)

func __log_(...parts: Array):
	print_.anim_manager("", pp.list_(parts))
