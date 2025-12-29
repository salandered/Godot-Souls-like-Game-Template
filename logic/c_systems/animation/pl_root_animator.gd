## Sub part of PlayerModifierAnimator which calculates root related data
class_name PlayerRootAnimator
extends NodeCharacterSystem

@onready var full_body: PlayerModifierAnimator = %FullBody

var _root_track: String


func __hard_dependencies() -> Array[Object]:
	return [full_body]

func __soft_dependencies() -> Array[Object]:
	return []


func is_player() -> bool:
	return true


func initialise(root_track: String) -> void:
	self._root_track = root_track
	error_.empty_string(_root_track)
	__validate_dependencies()


func get_global_speed_scale() -> float:
	return full_body.global_speed_scale

func get_curr_playback() -> AnimPlayback:
	return full_body.curr_playback

func get_prev_playback() -> AnimPlayback:
	return full_body.prev_playback

func get_blend_playback() -> BlendPlayback:
	return full_body.curr_blend_playback

func get_custom_delta() -> float:
	return full_body.__custom_delta.delta


func get_prev_root_rotation() -> float:
	if get_prev_playback().get_effective_time_spent() >= get_prev_playback().anim.duration:
		__log_("", "Will return 0.0. effective_prog >= anim.duration. Details:", get_prev_playback()._to_string_short())
		return 0.0
	var prev_rotation_delta := _calculate_rotation_delta(get_prev_playback(), BoneIdx.ROOT)
	# var rotation_ := prev_rotation_delta * (1.0 - blend_playback.percentage) * global_speed_scale
	var rotation_ := prev_rotation_delta * get_global_speed_scale()
	# if abs(rotation_) > 0.0001:
	#  	print_.skm("", "get_prev_root_rotation(): delta=%.4f | result=%.4f" % [prev_rotation_delta, residual_rotation])

	return rotation_


func get_root_velocity(y_zeroed: bool = true, use_blending: bool = false, backwards: bool = false) -> Vector3:
	var curr_playback := get_curr_playback()
	var curr_eff_progress := curr_playback.get_effective_time_spent()
	if curr_eff_progress < Constants.ONE_FRAME:
		# print_.dev("✔", "curr_eff_progress", curr_eff_progress, "< Constants.ONE_FRAME -> we at the beginning of the anim. backwards to true")
		backwards = true
	elif curr_playback.anim.duration - curr_eff_progress < Constants.ONE_FRAME:
		# print_.dev("✔", "anim.duration - curr_eff_progress", curr_playback.anim.duration - curr_eff_progress,
			# "< Constants.ONE_FRAME -> we at the end f the anim. backwards to false")
		backwards = false

	var curr_velocity := _calculate_velocity_delta(get_curr_playback(), BoneIdx.ROOT, backwards)
	
	if use_blending and get_blend_playback().is_blending:
		var prev_velocity := _calculate_velocity_delta(get_prev_playback(), BoneIdx.ROOT, backwards)
		curr_velocity = prev_velocity.lerp(curr_velocity, get_blend_playback().percentage)
	
	if y_zeroed:
		curr_velocity.y = 0
	
	return curr_velocity * get_global_speed_scale()


func get_root_rotation(y_only: bool = true) -> float:
	var curr_rotation_delta := _calculate_rotation_delta(get_curr_playback(), BoneIdx.ROOT)
	
	# NOTE: Not supporing two animations in a row with root rotation. 
	#       For one root rot and other w/o it, this should be checked for sanity
	
	return curr_rotation_delta * get_global_speed_scale()


func _calculate_velocity_delta(playback: AnimPlayback, bone_idx: int, backwards: bool = false) -> Vector3:
	var pos_track := playback.anim.get_pos_track_idx(_root_track)

	if pos_track == -1 or playback.anim.native_anim.track_get_key_count(pos_track) <= 1:
		return Vector3.ZERO
	
	var scaled_delta := get_custom_delta() * full_body._EFFECTIVE_SPEED_SCALE(playback)
	var curr_progress := playback.get_effective_time_spent()
	var prev_progress := curr_progress - scaled_delta
	if backwards:
		curr_progress += scaled_delta
		prev_progress += scaled_delta

	prev_progress = max(0.0, prev_progress)
	
	var prev_pos: Vector3 = playback.anim.native_anim.position_track_interpolate(pos_track, prev_progress)
	var curr_pos: Vector3 = playback.anim.native_anim.position_track_interpolate(pos_track, curr_progress)
	
	return (curr_pos - prev_pos) / scaled_delta if scaled_delta > 0 else Vector3.ZERO


func _calculate_rotation_delta(playback: AnimPlayback, bone_idx: int) -> float:
	var rot_track := playback.anim.get_rot_track_idx(_root_track)
	if rot_track == -1:
		return 0.0
	
	var scaled_delta := get_custom_delta() * full_body._EFFECTIVE_SPEED_SCALE(playback)
	var curr_progress := playback.get_effective_time_spent()
	var prev_progress: float = max(0.0, curr_progress - scaled_delta)
	
	var prev_rot: Quaternion = playback.anim.native_anim.rotation_track_interpolate(rot_track, prev_progress)
	var curr_rot: Quaternion = playback.anim.native_anim.rotation_track_interpolate(rot_track, curr_progress)
	
	var delta_rot := prev_rot.inverse() * curr_rot
	var rotation_delta := delta_rot.get_euler().y
	
	# Handle angle wrapping
	if rotation_delta > PI:
		rotation_delta -= TAU
	elif rotation_delta < -PI:
		rotation_delta += TAU
	
	return rotation_delta


## needs polishing
func calculate_animation_start_root_velocity(anim: AnimationData, start_time_offset: float = 0.0, backwards: bool = false) -> float:
	var root_pos_track := anim.get_pos_track_idx(_root_track)
	
	if root_pos_track == -1 or anim.native_anim.track_get_key_count(root_pos_track) <= 1:
		return 0.0
	
	# Sample at start and a small delta to get initial velocity
	var sample_delta := Constants.ONE_FRAME
	var start_time := start_time_offset
	if backwards:
		start_time -= sample_delta

	# prints("root vel", em.mark_2, start_time, start_time + sample_delta)
	var pos_at_start := anim.native_anim.position_track_interpolate(root_pos_track, start_time)
	var pos_at_delta := anim.native_anim.position_track_interpolate(root_pos_track, start_time + sample_delta)
	
	var velocity := (pos_at_delta - pos_at_start) / sample_delta
	velocity.y = 0
	
	var result := velocity.length() * anim.speed_scale
	return result


# region __LOGS


func __LOG_B() -> bool:
	return LogToggler.SKM_B

func __LOG_INDENT() -> int:
	return 4

# endregion
