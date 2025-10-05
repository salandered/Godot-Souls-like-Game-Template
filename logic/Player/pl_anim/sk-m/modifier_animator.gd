extends SkeletonModifier3D
## WARNING: should not be called directly!
## 			AnimatorManager manages all modifier animators
class_name ModifierAnimator

@export var native_animator: AnimationPlayer ## real AnimationPlayer with anim data
@onready var skeleton = get_skeleton()
@onready var overlay: OverlayFeature = %overlay ## responsible for overlaying another anim

@export var animator_name: String ## name of animator

# TODO: Unix time in milliseconds, just as in model states. 
# Need a better time calculation
var last_processing_time: float = 0 # seconds unix from system
var custom_delta := 0.0 # seconds
var now := 0.0 # seconds unix from system

var bone_list: Array
var curr_transform: Transform3D
var prev_transform: Transform3D

var __initialised: bool = false

## for animation non related effects like slow mo
## note that animation may have it's own speed scale. They will be multiplied.
# var _dev_hard_speed_scale = true # for tests
var _dev_hard_speed_scale = false
# var global_speed_scale := 1.0
var global_speed_scale := 1.0

var blend_playback := BlendPlayback.new()

var curr_playback: AnimPlayback
## for blending between two animations
var prev_playback: AnimPlayback

# todo: flying bone attachments


func initialise():
	## NOTE: 0 - root is not animated here. If animation is RM, use get_root_velocity()
	## 45 - first leg bone
	if animator_name == 'full_body':
		bone_list = range(1, 52)
	elif animator_name == 'legs':
		bone_list = range(45, 52)
	else:
		push_error("no animator_name or its unknown")
	__initialised = true


func set_overlay_anim(anim: AnimationData, fade_in: float = 0.1, hold: float = -1.0, fade_out: float = 0.15, local_speed: float = 1.0):
	overlay.set_overlay_anim(anim, fade_in, hold, fade_out, local_speed)


func set_anim_to_play(anim: AnimationData, blend_for: float = 0, start_time_offset: float = 0):
	last_processing_time = Time.get_unix_time_from_system()
	
	blend_playback.reset()

	prev_playback = curr_playback
	curr_playback = AnimPlayback.new(anim, 0.0, start_time_offset)

	if blend_for > 0:
		blend_playback.start(blend_for)

	print_.skm(animator_name, __log_state())


func _process_modification():
	if __initialised:
		_update_time()
		_update_blend_values()
		_update_skeleton()
		# _apply_residual_rotation()


func _update_time():
	# Each frame we manage our time awareness. 
		# - Calculate the custom_delta between now and the last call.
		# - Then add this custom_delta to curr anim's time_spent.
	now = Time.get_unix_time_from_system()
	custom_delta = now - last_processing_time
	last_processing_time = now

	curr_playback.time_spent += custom_delta * _EFFECTIVE_SPEED_SCALE(curr_playback)
	
	## prev_playback plays as if it still was a curr one.
	if prev_playback.time_spent < prev_playback.anim.duration:
		prev_playback.time_spent += custom_delta * _EFFECTIVE_SPEED_SCALE(prev_playback)

	if curr_playback.time_spent > curr_playback.anim.duration and curr_playback.anim.is_looping:
		curr_playback.time_spent = fmod(curr_playback.time_spent, curr_playback.anim.duration)
	if blend_playback.is_blending and prev_playback.time_spent > prev_playback.anim.duration and prev_playback.anim.is_looping:
		prev_playback.time_spent = fmod(prev_playback.time_spent, prev_playback.anim.duration)


func _update_blend_values():
	blend_playback.update(custom_delta)
	overlay._update_blend_values(custom_delta)


func _update_skeleton():
	for bone_idx in bone_list:
		# For each suggested bone, we first calculate its pose according to the `curr_playback` and its time spent.
		#   - If we don't blend, that's our work for the bone.
		#   - If we do blend, we need to also calculate this bone's pose according to the `prev_playback` and its time spent, 
		#     and then interpolate those two transforms via blending progress.
		curr_transform = _calculate_bone_pose(bone_idx, curr_playback)
		if blend_playback.is_blending:
			prev_transform = _calculate_bone_pose(bone_idx, prev_playback)
			curr_transform = prev_transform.interpolate_with(curr_transform, blend_playback.percentage)
		
		curr_transform = overlay.apply_overlay(bone_idx, curr_transform, self)
		skeleton.set_bone_pose(bone_idx, curr_transform)
	

func _calculate_bone_pose(bone_idx: int, playback: AnimPlayback) -> Transform3D:
	# - We search for a position track by turning our bone index into track path.
	# 	  - If -1, it means that `AnimationResource` doesn't contain such a track. For example, that bone doesn't move in this animation. 
	# 	In this case, we set transform's `origin` to the origin of our bone; we don't touch it.
	# 	  - If we find the track, we interpolate the value from it using effective anim time.
	# - then we do the same with rotation. Difference is type casting because animation stores rotation data in quaternions, but `Transform3D` stores it in basis vector triples.
	var result_transform: Transform3D
	
	var bone_position_track := __get_position_track(bone_idx, playback.native_anim)
	if bone_position_track != -1:
		result_transform.origin = playback.native_anim.position_track_interpolate(bone_position_track, playback.get_effective_progress())
	else:
		result_transform.origin = skeleton.get_bone_pose(bone_idx).origin

	var bone_rotation_track := __get_rotation_track(bone_idx, playback.native_anim)
	if bone_rotation_track != -1:
		result_transform.basis = Basis(playback.native_anim.rotation_track_interpolate(bone_rotation_track, playback.get_effective_progress()))
	else:
		result_transform.basis = skeleton.get_bone_pose(bone_idx).basis
	
	return result_transform


func _EFFECTIVE_SPEED_SCALE(playback: AnimPlayback) -> float:
	return global_speed_scale * playback.anim.speed_scale


func get_prev_root_rotation() -> float:
	var prev_rotation_delta = _calculate_rotation_delta(prev_playback, 0)
	# var residual_rotation = prev_rotation_delta * (1.0 - blend_playback.percentage) * global_speed_scale
	var residual_rotation = prev_rotation_delta * global_speed_scale
	if abs(residual_rotation) > 0.0001:
		print("[MOD_ANIM] get_prev_root_rotation(): delta=%.4f | result=%.4f" % [
			prev_rotation_delta,
			residual_rotation
		])

	return residual_rotation

func get_root_velocity(y_zeroed: bool = true) -> Vector3:
	var curr_velocity = _calculate_velocity_delta(curr_playback, 0)
	
	if blend_playback.is_blending:
		var prev_velocity = _calculate_velocity_delta(prev_playback, 0)
		curr_velocity = prev_velocity.lerp(curr_velocity, blend_playback.percentage)
	
	if y_zeroed:
		curr_velocity.y = 0
	
	return curr_velocity * global_speed_scale


func get_root_rotation(y_only: bool = true) -> float:
	var curr_rotation_delta = _calculate_rotation_delta(curr_playback, 0)
	
	# if blend_playback.is_blending:
	# 	var prev_rot_track := __get_rotation_track(0, prev_playback.native_anim)
		
	# 	# Only blend if previous animation also has rotation
	# 	if prev_rot_track != -1:
	# 		var prev_rotation_delta = _calculate_rotation_delta(prev_playback, 0)
	# 		curr_rotation_delta = lerp(prev_rotation_delta, curr_rotation_delta, blend_playback.percentage)
	# 		# prints(u.fr(), "ROT_BLEND", curr_rotation_delta)
	
	return curr_rotation_delta * global_speed_scale


func _calculate_velocity_delta(playback: AnimPlayback, bone_idx: int) -> Vector3:
	var pos_track := __get_position_track(bone_idx, playback.native_anim)
	if pos_track == -1 or playback.native_anim.track_get_key_count(pos_track) <= 1:
		return Vector3.ZERO
	
	var scaled_delta = custom_delta * _EFFECTIVE_SPEED_SCALE(playback)
	var curr_progress = playback.get_effective_progress()
	var prev_progress = max(0.0, curr_progress - scaled_delta)
	
	var prev_pos: Vector3 = playback.native_anim.position_track_interpolate(pos_track, prev_progress)
	var curr_pos: Vector3 = playback.native_anim.position_track_interpolate(pos_track, curr_progress)
	
	return (curr_pos - prev_pos) / scaled_delta if scaled_delta > 0 else Vector3.ZERO


func _calculate_rotation_delta(playback: AnimPlayback, bone_idx: int) -> float:
	var rot_track := __get_rotation_track(bone_idx, playback.native_anim)
	if rot_track == -1:
		return 0.0
	
	var scaled_delta = custom_delta * _EFFECTIVE_SPEED_SCALE(playback)
	var curr_progress = playback.get_effective_progress()
	var prev_progress = max(0.0, curr_progress - scaled_delta)
	
	var prev_rot: Quaternion = playback.native_anim.rotation_track_interpolate(rot_track, prev_progress)
	var curr_rot: Quaternion = playback.native_anim.rotation_track_interpolate(rot_track, curr_progress)
	
	var delta_rot = prev_rot.inverse() * curr_rot
	var rotation_delta = delta_rot.get_euler().y
	
	# Handle angle wrapping
	if rotation_delta > PI:
		rotation_delta -= TAU
	elif rotation_delta < -PI:
		rotation_delta += TAU
	
	return rotation_delta


## Kinda not Animator's logic, but suits here for now
func calculate_animation_start_root_velocity(anim: AnimationData) -> float:
	var root_pos_track := __get_position_track(0, anim.native_anim)
	
	if root_pos_track == -1 or anim.native_anim.track_get_key_count(root_pos_track) <= 1:
		return 0.0
	
	# Sample at start and a small delta to get initial velocity
	var sample_delta = 0.016 # One frame at 60fps
	var start_time = anim.start_time
	var pos_at_start = anim.native_anim.position_track_interpolate(root_pos_track, start_time)
	var pos_at_delta = anim.native_anim.position_track_interpolate(root_pos_track, start_time + sample_delta)
	
	var velocity = (pos_at_delta - pos_at_start) / sample_delta
	velocity.y = 0
	
	var result = velocity.length() * anim.speed_scale
	# print("[RUN_STOP] calc_start_vel: pos_start=%s pos_delta=%s -> vel=%.2f" % [
	# 	pp.vec3(pos_at_start), pp.vec3(pos_at_delta), result ])
	return result


func set_global_speed_scale(new_scale: float):
	# print_.skm(animator_name, "new scale set: " + str(new_scale))
	if _dev_hard_speed_scale:
		return
	global_speed_scale = new_scale


func reset_global_speed_scale():
	if _dev_hard_speed_scale:
		return
	# print_.skm(animator_name, "scale reset to 1")
	set_global_speed_scale(1.0)


# region: helpers

func __bone_idx_to_track_path(bone_idx: int) -> String:
	# TODO what if non existent bone_idx
	# TODO make a dict once and use. dont use get_bone_name every frame
	return "%GeneralSkeleton:" + skeleton.get_bone_name(bone_idx)


func __get_position_track(bone_idx: int, native_anim: Animation) -> int:
	## if not, returns -1
	var track_path = __bone_idx_to_track_path(bone_idx)
	var pos_track := native_anim.find_track(track_path, Animation.TYPE_POSITION_3D)
	return pos_track


func __get_rotation_track(bone_idx: int, native_anim: Animation) -> int:
	## if not, returns -1
	var track_path = __bone_idx_to_track_path(bone_idx)
	var rot_track := native_anim.find_track(track_path, Animation.TYPE_ROTATION_3D)
	return rot_track

# endregion


func __log_state() -> String:
	var nt = "\n\t\t\t"
	var msg = pp.s(
		"TO:  ", curr_playback,
		nt, "FROM:  ", prev_playback,
		nt, "BLEND:  ", blend_playback, "  glob speed", global_speed_scale)
	return msg
