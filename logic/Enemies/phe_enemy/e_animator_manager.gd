@tool
@icon("res://-assets-/x_misc/x_icons/node-colors/purple.png")
extends BaseAnimatorManager

class_name EnemyAnimatorManager


@onready var anim_container: AnimationContainer = %AnimContainer
@onready var native_player: AnimationPlayer = %NativePlayer
@onready var general_skeleton: Skeleton3D = %GeneralSkeleton


# Track the starting position to calculate time_spent
var _curr_anim_start_offset: float = 0.0
var _curr_anim: AnimationData

## SET ANIMATIONS TO PLAY AND CONFIGURE ▶️

func set_anim_to_play(anim_id: String, blend_for: float = 0.0, start_time_offset: float = 0.0) -> void:
	if anim_id == "":
		print()
	if blend_for < 0:
		print_.warn_raw(false, "blend_for < 0 is not supported, 0 will be used:" + str(blend_for))
		blend_for = 0
	
	if start_time_offset < 0:
		print_.warn_raw(false, "start time shift < 0 is not supported, 0 will be used: " + str(start_time_offset))
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

	_curr_anim_start_offset = start_time_offset


func set_global_speed_scale(new_scale: float) -> void:
	var max_speed_scale := 2.0
	var min_speed_scale := 0.1
	new_scale = snappedf(new_scale, 0.01)
	
	if new_scale < min_speed_scale or new_scale > max_speed_scale:
		__log_("new_scale will be clamped. min/max/curr scale", new_scale, min_speed_scale, max_speed_scale)
		new_scale = clampf(new_scale, min_speed_scale, max_speed_scale)
	
	if absf(native_player.speed_scale - new_scale) > 0.005:
		# __log_("set_global_speed_scale to", new_scale, "  (from", native_player.speed_scale, ")")
		native_player.speed_scale = new_scale


func reset_global_speed_scale() -> void:
	# __log_("reset_global_speed_scale to 1.0")
	native_player.speed_scale = 1.0


## guarantees not 0.0
func get_global_speed_scale() -> float:
	return _get_effective_speed()


## READ INFO ABOUT WHAT'S PLAYING

func get_curr_anim_effective_time_spent() -> float:
	var raw_time_spent := native_player.current_animation_position
	var effective_speed := _get_effective_speed()
	return raw_time_spent / absf(effective_speed)


func get_curr_anim_time_spent() -> float:
	var raw_time_spent := native_player.current_animation_position - _curr_anim_start_offset
	var effective_speed := _get_effective_speed()
	return raw_time_spent / absf(effective_speed)


## Returns the raw, unscaled playhead position. (Animation Time)
func get_curr_anim_position_unscaled() -> float:
	return native_player.current_animation_position


## Returns the raw, unscaled duration. (Animation Time)
func get_curr_anim_duration_unscaled() -> float:
	if not _curr_anim:
		return 0.0
	return _curr_anim.duration


## returns 0.0 if no curr anim
func get_curr_anim_effective_duration() -> float:
	if not _curr_anim:
		return 0.0

	var _base_duration: float
	if _curr_anim.is_looping:
		_base_duration = _curr_anim.duration
	else:
		_base_duration = _curr_anim.duration - _curr_anim_start_offset
	
	var effective_speed := _get_effective_speed()

	return _base_duration / absf(effective_speed)


## guarantees not 0.0
## returns 1.0 if no curr anim
func _get_effective_speed() -> float:
	# NOTE: we could use native_player.get_playing_speed(), 
	# 		but then if animation ends playing, it drops to 0.0.
	if not _curr_anim:
		return 1.0
	var _r := _curr_anim.speed_scale * native_player.speed_scale
	if _r == 0.0:
		print_.warn(false, "effective_speed 0", "enemy animator", "return 1.0")
		return 1.0
	return _r


## returns "" if no curr anim
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

func get_root_motion_position(y_zeroed: bool = true, __log: bool = false) -> Vector3:
	var delta_pos := native_player.get_root_motion_position()
	if __log:
		print(">> Native root motion RAW: ", delta_pos)
		print(">> Animation playing: ", native_player.is_playing())
		print(">> Current animation: ", native_player.current_animation)
		print(">> Animation position: ", native_player.current_animation_position)
		
	if y_zeroed:
		delta_pos.y = 0
	if __log: print(">> After Y zero (if applicable): ", delta_pos)
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
	var _prev_anim_name := "-x-"
	if prev_anim:
		_prev_anim_name = pp.in_q(_curr_anim.anim_name)
	var _curr_anim_name := pp.in_q(new_anim.anim_name)
	var _msg := pp.s("set_anim_to_play:",
		_curr_anim_name,
		"curr glob-sp-scale", get_global_speed_scale(),
		"  ", pp.in_br("from prev " + _prev_anim_name))
	__log_(_msg)

func __log_(...parts: Array):
	print_.anim_manager("", pp.list_(parts))


func initialise() -> void:
	# dont rely on UI setting, it will be lost on almost any change, super fragile.
	native_player.root_motion_track = NodePath("%GeneralSkeleton:Root")
	_reset_root_motion()
	native_player.play(PHEA.sleep)
	

func _reset_root_motion() -> void:
	var root_bone_id := general_skeleton.find_bone("Root")
	general_skeleton.set_bone_pose_position(root_bone_id, Vector3.ZERO)
	
	# may be also reset the whole character:
	# global_position = spawn_position
