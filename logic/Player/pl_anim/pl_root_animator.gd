extends Node
## Sub part of PlayerModifierAnimator which calculates root related data
class_name PlayerRootAnimator

@onready var full_body: PlayerModifierAnimator = %FullBody


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
		print_.skm("PlayerRootAnimator", "Will return 0.0. effective_prog >= anim.duration. Details:" + get_prev_playback()._to_string_short(), 0, LogL.FORCE_PRINT)
		return 0.0
	var prev_rotation_delta := _calculate_rotation_delta(get_prev_playback(), BoneIdx.ROOT)
	# var rotation_ := prev_rotation_delta * (1.0 - blend_playback.percentage) * global_speed_scale
	var rotation_ := prev_rotation_delta * get_global_speed_scale()
	# if abs(rotation_) > 0.0001:
	#  	print_.skm("", "get_prev_root_rotation(): delta=%.4f | result=%.4f" % [prev_rotation_delta, residual_rotation])

	return rotation_


func get_root_velocity(y_zeroed: bool = true, use_blending: bool = true, backwards: bool = false) -> Vector3:
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
	# if blend_playback.is_blending:
	# 	var prev_rot_track := __get_rotation_track(0, prev_playback.native_anim)
		
	# 	# Only blend if previous animation also has rotation
	# 	if prev_rot_track != -1: # WARNING: what if track existed but we dont use it? switch to AnimationData
	# 		var prev_rotation_delta := _calculate_rotation_delta(prev_playback, 0)
	# 		curr_rotation_delta = lerp(prev_rotation_delta, curr_rotation_delta, blend_playback.percentage)
	# 		# prints(u.fr(), "ROT_BLEND", curr_rotation_delta)
	
	return curr_rotation_delta * get_global_speed_scale()


func _calculate_velocity_delta(playback: AnimPlayback, bone_idx: int, backwards: bool = false) -> Vector3:
	var _track_path := full_body.__bone_idx_to_track_path(bone_idx)
	var pos_track := playback.anim.get_pos_track_idx(_track_path)

	if pos_track == -1 or playback.native_anim.track_get_key_count(pos_track) <= 1:
		return Vector3.ZERO
	
	var scaled_delta := get_custom_delta() * full_body._EFFECTIVE_SPEED_SCALE(playback)
	var curr_progress := playback.get_effective_time_spent()
	var prev_progress := curr_progress - scaled_delta
	if backwards:
		curr_progress += scaled_delta
		prev_progress += scaled_delta

	prev_progress = max(0.0, prev_progress)
	# prints(em.mark_2, prev_progress, curr_progress)
	var prev_pos: Vector3 = playback.native_anim.position_track_interpolate(pos_track, prev_progress)
	var curr_pos: Vector3 = playback.native_anim.position_track_interpolate(pos_track, curr_progress)
	
	return (curr_pos - prev_pos) / scaled_delta if scaled_delta > 0 else Vector3.ZERO


func _calculate_rotation_delta(playback: AnimPlayback, bone_idx: int) -> float:
	var _track_path := full_body.__bone_idx_to_track_path(bone_idx)
	var rot_track := playback.anim.get_rot_track_idx(_track_path)
	if rot_track == -1:
		return 0.0
	
	var scaled_delta := get_custom_delta() * full_body._EFFECTIVE_SPEED_SCALE(playback)
	var curr_progress := playback.get_effective_time_spent()
	var prev_progress: float = max(0.0, curr_progress - scaled_delta)
	
	var prev_rot: Quaternion = playback.native_anim.rotation_track_interpolate(rot_track, prev_progress)
	var curr_rot: Quaternion = playback.native_anim.rotation_track_interpolate(rot_track, curr_progress)
	
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
	var _track_path := full_body.__bone_idx_to_track_path(BoneIdx.ROOT)
	var root_pos_track := anim.get_pos_track_idx(_track_path)
	
	if root_pos_track == -1 or anim.native_anim.track_get_key_count(root_pos_track) <= 1:
		return 0.0
	
	# Sample at start and a small delta to get initial velocity
	var sample_delta := Constants.ONE_FRAME # One frame at 60fps
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
