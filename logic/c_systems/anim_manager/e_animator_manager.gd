@tool

class_name EnemyAnimatorManager
extends BaseSkeletonAnimatorManager


@export var config: AnimatableEntityConfig
@export var ignore_root_bone: bool = false
@export var set_root_bone_postponed: bool = false

# Track the starting position to calculate time_spent
var _curr_anim_start_offset: float = 0.0
var _curr_anim: AnimationData


func initialize_implementation():
	if _native_player and not ignore_root_bone:
		if set_root_bone_postponed:
			await FrameUtils.wait_process_frames(self , 4)
		# dont rely on UI setting, it's very fragile.
		_native_player.root_motion_track = NodePath(Const.ROOT_TRACK_PATH)

	if general_skeleton:
		_reset_root_motion()
	
	if overlay_modifier:
		overlay_modifier.initialize()


func _reset_root_motion() -> void:
	var root_bone_id := general_skeleton.find_bone(Const.ROOT_BONE)
	general_skeleton.set_bone_pose_position(root_bone_id, Vector3.ZERO)
	

## SET ANIMATIONS TO PLAY ▶️

func set_anim_to_play(anim_id: StringName, blend_for: float = 0.0, start_time_offset: float = 0.0) -> void:
	var result := AnimUtils.set_anim_to_play(_native_player,
		_anim_container,
		config,
		anim_id,
		blend_for,
		start_time_offset)
	if result:
		__log_new_anim(_curr_anim, result.anim)
		_curr_anim = result.anim
		_curr_anim_start_offset = result.start_time_offset


func set_global_speed_scale(new_scale: float) -> void:
	AnimUtils.set_global_speed_scale(_native_player, config, new_scale)


func reset_global_speed_scale() -> void:
	AnimUtils.reset_global_speed_scale(_native_player, config)


## guarantees not 0.0
func get_global_speed_scale() -> float:
	return AnimUtils.get_global_speed_scale(_curr_anim, _native_player)


## READ INFO ABOUT WHAT'S PLAYING

func get_curr_anim_effective_time_spent() -> float:
	return AnimUtils.get_anim_effective_time_spent(_curr_anim, _native_player)


func get_curr_anim_time_spent() -> float:
	return AnimUtils.get_anim_time_spent(_curr_anim, _curr_anim_start_offset, _native_player)


## Returns the raw, unscaled playhead position. (Animation Time)
func get_curr_anim_position_unscaled() -> float:
	return AnimUtils.get_anim_position_unscaled(_curr_anim, _native_player)


## Returns the raw, unscaled duration. (Animation Time)
func get_curr_anim_duration_unscaled() -> float:
	return AnimUtils.get_anim_duration_unscaled(_curr_anim)


## returns 0.0 if no curr anim
func get_curr_anim_effective_duration() -> float:
	return AnimUtils.get_anim_effective_duration(_curr_anim, _curr_anim_start_offset, _native_player)


## returns "" if no curr anim
func get_curr_anim_id() -> StringName:
	if not _curr_anim:
		return Const.EMPTY_SNAME
	return _curr_anim.anim_id


func is_playing() -> bool:
	return get_native_player().is_playing()


## nullable
func get_curr_anim() -> AnimationData:
	return _curr_anim


## ROOT MOTION

func get_root_motion_position(y_zeroed: bool = true, __log: bool = false) -> Vector3:
	var delta_pos := get_native_player().get_root_motion_position()
	if __log:
		__log_(">> Native root motion RAW: ", delta_pos)
		__log_(">> Animation playing: ", get_native_player().is_playing())
		__log_(">> Current animation: ", get_native_player().current_animation)
		__log_(">> Animation position: ", get_native_player().current_animation_position)
		
	if y_zeroed:
		delta_pos.y = 0
	if __log: __log_(">> After Y zero (if applicable): ", delta_pos)
	return delta_pos


## __LOG

func __LOG_B() -> bool:
	return LogToggler.ANIM.E_MANAGER
