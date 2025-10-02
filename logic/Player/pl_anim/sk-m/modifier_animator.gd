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
# var global_speed_scale := 0.4
var global_speed_scale := 1.0

var blend_playback := BlendPlayback.new()

var curr_playback: AnimPlayback
## for blending between two animations
var prev_playback: AnimPlayback


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


func _update_time():
	# Each frame we manage our time awareness. 
		# - Calculate the custom_delta between now and the last call.
		# - Then add this custom_delta to curr anim's time_spent.
	now = Time.get_unix_time_from_system()
	custom_delta = now - last_processing_time
	last_processing_time = now

	curr_playback.time_spent += custom_delta * _EFFECTIVE_SPEED_SCALE(curr_playback)
	
	if blend_playback.is_blending:
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
	
	var bone_position_track := playback.native_anim.find_track(_bone_to_track_name(bone_idx), Animation.TYPE_POSITION_3D)
	if bone_position_track != -1:
		result_transform.origin = playback.native_anim.position_track_interpolate(bone_position_track, playback.get_effective_progress())
	else:
		result_transform.origin = skeleton.get_bone_pose(bone_idx).origin

	var bone_rotation_track := playback.native_anim.find_track(_bone_to_track_name(bone_idx), Animation.TYPE_ROTATION_3D)
	if bone_rotation_track != -1:
		result_transform.basis = Basis(playback.native_anim.rotation_track_interpolate(bone_rotation_track, playback.get_effective_progress()))
	else:
		result_transform.basis = skeleton.get_bone_pose(bone_idx).basis
	
	return result_transform


func _EFFECTIVE_SPEED_SCALE(playback: AnimPlayback) -> float:
	return global_speed_scale * playback.anim.speed_scale


func _bone_to_track_name(bone_index: int) -> String:
	return "%GeneralSkeleton:" + skeleton.get_bone_name(bone_index)

func get_root_velocity(y_zeroed: bool = true) -> Vector3:
	var root_track_path := _bone_to_track_name(0)
	var pos_track := curr_playback.native_anim.find_track(root_track_path, Animation.TYPE_POSITION_3D)
	if pos_track == -1 or curr_playback.native_anim.track_get_key_count(pos_track) <= 1:
		return Vector3.ZERO

	var scaled_delta = custom_delta * _EFFECTIVE_SPEED_SCALE(curr_playback)
	var curr_progress = curr_playback.get_effective_progress()
	var prev_progress = max(0.0, curr_progress - scaled_delta)
	
	var prev_pos: Vector3 = curr_playback.native_anim.position_track_interpolate(pos_track, prev_progress)
	var curr_pos: Vector3 = curr_playback.native_anim.position_track_interpolate(pos_track, curr_progress)
	var curr_velocity = (curr_pos - prev_pos) / scaled_delta if scaled_delta > 0 else Vector3.ZERO
	
	# TODO: experimental! It might be anim is not rm, but track is not empty. Result is unknown
	if blend_playback.is_blending:
		var prev_pos_track := prev_playback.native_anim.find_track(root_track_path, Animation.TYPE_POSITION_3D)
		var prev_velocity := Vector3.ZERO # Default to zero if no root motion
		
		# Only calculate prev velocity if the track exists and has data
		if prev_pos_track != -1 and prev_playback.native_anim.track_get_key_count(prev_pos_track) > 1:
			var prev_scaled_delta = custom_delta * _EFFECTIVE_SPEED_SCALE(prev_playback)
			var prev_curr_progress = prev_playback.get_effective_progress()
			var prev_prev_progress = max(0.0, prev_curr_progress - prev_scaled_delta)
			
			var prev_prev_pos: Vector3 = prev_playback.native_anim.position_track_interpolate(prev_pos_track, prev_prev_progress)
			var prev_curr_pos: Vector3 = prev_playback.native_anim.position_track_interpolate(prev_pos_track, prev_curr_progress)
			prev_velocity = (prev_curr_pos - prev_prev_pos) / prev_scaled_delta if prev_scaled_delta > 0 else Vector3.ZERO
		
		# Blend the velocities
		curr_velocity = prev_velocity.lerp(curr_velocity, blend_playback.percentage)

	# print_.prefix("", pp.s("~~~~prev_pos", pp.vec3(prev_pos), "len", prev_pos.length()) + " " +
	# pp.s("curr_pos", pp.vec3(curr_pos), "len", curr_pos.length()) + " " +
	# pp.s("delta_pos", pp.vec3(delta_pos), "len", delta_pos.length()))
	if y_zeroed:
		curr_velocity.y = 0
	
	return curr_velocity * global_speed_scale


# experimantal. not really working. 
# RM driven animation usually root rotation at hips. But hips also have their usual rotation. 
# root rotation from hips should be retargeted to root bone.
func get_root_rotation() -> float:
	var hip_track_path := _bone_to_track_name(1)
	var rot_track := curr_playback.native_anim.find_track(hip_track_path, Animation.TYPE_ROTATION_3D)
	if rot_track == -1:
		return 0.0
	
	var scaled_delta = custom_delta * _EFFECTIVE_SPEED_SCALE(curr_playback)
	var curr_progress = curr_playback.get_effective_progress()
	var prev_progress = max(0.0, curr_progress - scaled_delta)
	
	var prev_rot: Quaternion = curr_playback.native_anim.rotation_track_interpolate(rot_track, prev_progress)
	var curr_rot: Quaternion = curr_playback.native_anim.rotation_track_interpolate(rot_track, curr_progress)
	
	# Get Y-axis rotation difference
	var delta_rot = prev_rot.inverse() * curr_rot
	return delta_rot.get_euler().y # Returns radians


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


func __log_state() -> String:
	var nt = "\n\t\t\t"
	var msg = pp.s(
		"TO:  ", curr_playback,
		nt, "FROM:  ", prev_playback,
		nt, "BLEND:  ", blend_playback, "  glob speed", global_speed_scale)
	return msg
