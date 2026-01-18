@tool
@icon("res://-assets-/x_icons/node-colors/purple.png")
extends BaseAnimatorManager

class_name EnemyAnimatorManager

@onready var config: PHEConfig = %Config
@export var _native_player: AnimationPlayer
@export var general_skeleton: Skeleton3D
@export var overlay_modifier: OverlayModifier
@export var initial_anim_id: String

## _native_player will be duplicated to this
var _anim_player: AnimationPlayer


# Track the starting position to calculate time_spent
var _curr_anim_start_offset: float = 0.0
var _curr_anim: AnimationData


func __hard_dependencies() -> Array[Object]:
	return [
		_native_player,
		_anim_player,
		general_skeleton,
		anim_container
	]

func __soft_dependencies() -> Array[Object]:
	return [
		overlay_modifier
	]

## SET ANIMATIONS TO PLAY AND CONFIGURE ▶️

func set_overlay_anim(anim_id: String, overlay_config: OverlayConfig, start_time_offset: float = 0):
	var anim := anim_container.get_by_anim_id(anim_id)
	if anim == null:
		__log_error("Overlay anim not found: " + anim_id, "set_overlay_anim", "")
		return
	
	overlay_modifier.set_overlay_anim(anim, overlay_config)


func set_anim_to_play(anim_id: String, blend_for: float = 0.0, start_time_offset: float = 0.0) -> void:
	if anim_id == "":
		__log_error("anim_id is empty string", "set_anim_to_play", "will not play anything")
		return
	if blend_for < 0:
		__log_error("blend_for < 0 is not supported, 0 will be used:" + str(blend_for), "", "")
		blend_for = 0
	
	if start_time_offset < 0:
		__log_error("start time shift < 0 is not supported, 0 will be used: " + str(start_time_offset), "", "")
		start_time_offset = 0
	
	var anim: AnimationData = anim_container.get_by_anim_id(anim_id)

	if anim == null:
		__log_error("set_anim_to_play fail: animation not found: " + anim_id, "set_anim_to_play", "")
		return

	if not get_anim_player().has_animation(anim_id):
		__log_error("set_anim_to_play fail: animation not found: " + anim_id, "set_anim_to_play", "")
		return
	
	# NOTE: playing anim and setting _curr_anim is atomic
	get_anim_player().play(anim.anim_id, blend_for, anim.speed_scale * config.SPEED_SCALE_COEF)
	__log_new_anim(_curr_anim, anim)
	_curr_anim = anim
	#
	
	if start_time_offset > 0:
		get_anim_player().seek(start_time_offset, true)

	_curr_anim_start_offset = start_time_offset


func set_global_speed_scale(new_scale: float) -> void:
	var max_speed_scale := 2.0
	var min_speed_scale := 0.2
	new_scale = snappedf(new_scale, 0.01)
	
	if new_scale < min_speed_scale or new_scale > max_speed_scale:
		__log_("new_scale will be clamped. min/max/curr scale", new_scale, min_speed_scale, max_speed_scale)
		new_scale = clampf(new_scale, min_speed_scale, max_speed_scale)
	
	if absf(get_anim_player().speed_scale - new_scale) > 0.005:
		# __log_("set_global_speed_scale to", new_scale, "  (from", get_anim_player().speed_scale, ")")
		## TODO: i think it should use anim.speed_scale * new_scale
		get_anim_player().speed_scale = new_scale * config.SPEED_SCALE_COEF


func reset_global_speed_scale() -> void:
	# __log_("reset_global_speed_scale to 1.0")
	get_anim_player().speed_scale = 1.0 * config.SPEED_SCALE_COEF


## guarantees not 0.0
func get_global_speed_scale() -> float:
	return _get_effective_speed()


## READ INFO ABOUT WHAT'S PLAYING

func get_curr_anim_effective_time_spent() -> float:
	var raw_time_spent := get_anim_player().current_animation_position
	var effective_speed := _get_effective_speed()
	return raw_time_spent / absf(effective_speed)


func get_curr_anim_time_spent() -> float:
	var raw_time_spent := get_anim_player().current_animation_position - _curr_anim_start_offset
	var effective_speed := _get_effective_speed()
	return raw_time_spent / absf(effective_speed)


## Returns the raw, unscaled playhead position. (Animation Time)
func get_curr_anim_position_unscaled() -> float:
	return get_anim_player().current_animation_position


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
	# NOTE: we could use get_anim_player().get_playing_speed(), 
	# 		but then if animation ends playing, it drops to 0.0.
	if not _curr_anim:
		return 1.0
	var _r := _curr_anim.speed_scale * get_anim_player().speed_scale
	if _r == 0.0:
		__log_warn("effective_speed 0", "enemy animator", "return 1.0")
		return 1.0
	return _r


## returns "" if no curr anim
func get_curr_anim_id() -> String:
	if not _curr_anim:
		return ""
	return _curr_anim.anim_id


func is_playing() -> bool:
	return get_anim_player().is_playing()


## may be null
func get_curr_anim() -> AnimationData:
	return _curr_anim


func get_overlay_time_left() -> float:
	return overlay_modifier.get_time_left()


## ROOT MOTION

func get_root_motion_position(y_zeroed: bool = true, __log: bool = false) -> Vector3:
	var delta_pos := get_anim_player().get_root_motion_position()
	if __log:
		__log_(">> Native root motion RAW: ", delta_pos)
		__log_(">> Animation playing: ", get_anim_player().is_playing())
		__log_(">> Current animation: ", get_anim_player().current_animation)
		__log_(">> Animation position: ", get_anim_player().current_animation_position)
		
	if y_zeroed:
		delta_pos.y = 0
	if __log: __log_(">> After Y zero (if applicable): ", delta_pos)
	return delta_pos


## SYSTEM

func get_anim_player() -> AnimationPlayer:
	return _anim_player


func initialise(native_player_: AnimationPlayer, anim_container_: AnimContainer) -> void:
	self.anim_container = anim_container_

	# dont rely on UI setting, it will be lost on almost any change, super fragile.
	native_player_.root_motion_track = NodePath(Constants.ROOT_TRACK_PATH)
	self._anim_player = native_player_

	_reset_root_motion()
	
	# _anim_player.play(initial_anim_id)

	overlay_modifier.initialise()

	__perform_validation()


func _reset_root_motion() -> void:
	var root_bone_id := general_skeleton.find_bone(Constants.ROOT_BONE)
	general_skeleton.set_bone_pose_position(root_bone_id, Vector3.ZERO)
	
	# may be also reset the whole character:
	# global_position = spawn_position

func is_player() -> bool:
	return false


##


## __LOG

func __LOG_B() -> bool:
	return LogToggler.E_ANIM_MANAGER_B


func __LOG_INDENT() -> int:
	return 12

	
func __log_new_anim(prev_anim: AnimationData, new_anim: AnimationData):
	var _prev_anim_name := "-x-"
	if prev_anim:
		_prev_anim_name = pp.in_q(_curr_anim.anim_name)
	var _curr_anim_name := pp.in_q(new_anim.anim_name)
	var _msg := pp.s("set_anim_to_play:",
		_curr_anim_name,
		"curr glob-sp-scale", get_global_speed_scale(),
		"  ", pp.in_br("from prev " + _prev_anim_name))
	__log_("", _msg)
