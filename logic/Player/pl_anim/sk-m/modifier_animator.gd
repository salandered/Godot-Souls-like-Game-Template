extends SkeletonModifier3D
class_name ModifierAnimator

@export var native_animator: AnimationPlayer ## real AnimationPlayer with anim data
@onready var skeleton = get_skeleton()
@onready var overlay: OverlayFeature = %overlay ## responsible for overlaying another anim
@onready var anim_container: PlayerAnimationContainer = %AnimContainer

@export var animator_name: String ## name of animator

var curr_anim: AnimationData
# Animation can be cyclical to be playing in loop
var curr_anim_looping: bool = true
# counts progress for data interpolation. 
var curr_anim_progress: float = 0 # seconds

# for blending between two animations
var prev_anim: AnimationData
var prev_anim_looping: bool = true
var prev_anim_progress: float = 0 # seconds

# is_blending decides if we blend between the animations
# `blending_percentage`:
#    - If zero, then it's full previous animation. If one, we play full current animation.
#    - Is calculated using the time over which we blend and counting the progress of the process.
var is_blending: bool = false
var blend_duration: float # seconds
var blend_time_spent: float # seconds
var blending_percentage: float # [0 ; 1]

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
## animation speed scale stored in itslef and is handled separately
var global_speed_scale := 1.0


func initialise():
	# 45 - first leg bone
	if animator_name == 'full_body':
		# bone_list = range(1, 45)
		bone_list = range(1, 52)
	elif animator_name == 'legs':
		bone_list = range(45, 52)
		# bone_list.append(0) # root is not animated here. If animation is RM, use get_root_velocity()
		# bone_list.append(1) # TODO consider: giving hips bone to legs?
	else:
		push_error("no animator_name or its unknown")
	
	__initialised = true


func set_overlay_anim(anim_name: String, fade_in: float = 0.1, hold: float = -1.0, fade_out: float = 0.15, local_speed: float = 1.0):
	var anim: AnimationData = anim_container.get_by_name(anim_name)
	if anim == null:
		push_error("Overlay anim not found: " + anim_name)
		return
	overlay.set_overlay_anim(anim, fade_in, hold, fade_out, local_speed)


func _set_previous_animation():
	prev_anim = curr_anim
	prev_anim_looping = curr_anim_looping
	prev_anim_progress = curr_anim_progress


func set_anim_to_play(anim_name: String, blend_for: float = 0):
	if blend_for < 0:
		push_error("can't blend two animations over " + str(blend_for))
		blend_for = 0
	
	var anim: AnimationData = anim_container.get_by_name(anim_name)

	if anim == null:
		push_error("Animation not found: " + anim_name)
		return

	last_processing_time = Time.get_unix_time_from_system()
	
	_set_previous_animation()
	
	curr_anim = anim
	# NOTE: progress always starts with 0. Custom start_time will be added when 
	#       getting info from the native (original animation)
	curr_anim_progress = 0
	curr_anim_looping = curr_anim.is_looping

	if blend_for > 0:
		is_blending = true
		blend_duration = blend_for
		blend_time_spent = 0
		blending_percentage = 0


func _process_modification():
	if __initialised:
		_update_time()
		_update_blend_values()
		_update_skeleton()


func _update_time():
	# Each frame, first thing we do is we manage our time awareness. 
		# - We do it by calculating the custom_delta between now and the last call.
		# - We then add this custom_delta to our animation progresses, and if animations are cycling, we undergo a cycle switch.
	now = Time.get_unix_time_from_system()
	custom_delta = now - last_processing_time
	last_processing_time = now

	curr_anim_progress += custom_delta * _EFFECTIVE_SPEED_SCALE(curr_anim)
	prev_anim_progress += custom_delta * _EFFECTIVE_SPEED_SCALE(prev_anim)
	# if curr_anim.anim_name == A.combat_run:
		# print("~~~", str(curr_anim))
	if curr_anim_progress > curr_anim.duration and curr_anim_looping:
		curr_anim_progress = fmod(curr_anim_progress, curr_anim.duration)
	if prev_anim_progress > prev_anim.duration and prev_anim_looping:
		prev_anim_progress = fmod(prev_anim_progress, prev_anim.duration)


# We use the custom_delta time value we just got and add it to blending_time_counter, 
# and then we update blending_percentage value. 
func _update_blend_values():
	if is_blending:
		blend_time_spent += custom_delta
		blending_percentage = blend_time_spent / blend_duration
		if blending_percentage >= 1:
			blending_percentage = 1
			blend_time_spent = 0
			is_blending = false
	overlay._update_blend_values(custom_delta)

func _update_skeleton():
	for bone_idx in bone_list:
		# For each suggested bone, we first calculate its pose according to the `curr_anim` and its progress.
		#   - If we don't blend, that's our work for the bone.
		#   - If we do blend, we need to also calculate this bone's pose according to the `prev_anim` and its progress, and then interpolate those two transforms via `blending_progress` value.
		curr_transform = calculate_bone_pose(bone_idx, curr_anim, curr_anim_progress)
		if is_blending:
			prev_transform = calculate_bone_pose(bone_idx, prev_anim, prev_anim_progress)
			curr_transform = prev_transform.interpolate_with(curr_transform, blending_percentage)
		
		curr_transform = overlay.apply_overlay(bone_idx, curr_transform, self)
		skeleton.set_bone_pose(bone_idx, curr_transform)
	
func calculate_bone_pose(bone_idx: int, anim: AnimationData, anim_progress: float) -> Transform3D:
	# - We search for a position track by turning our bone index into track path.
	# 	  - If -1, it means that `AnimationResource` doesn't contain such a track. For example, that bone doesn't move in this animation. 
	# 	In this case, we set transform's `origin` to the origin of our bone; we don't touch it.
	# 	  - If we find the track, we interpolate the value from it using progress.
	# - then we do the same with rotation. The only difference is type casting because animation stores rotation data in quaternions, but `Transform3D` stores it in basis vector triples.
	var result_transform: Transform3D
	
	var bone_position_track := anim.native_anim.find_track(_bone_to_track_name(bone_idx), Animation.TYPE_POSITION_3D)
	if bone_position_track != -1:
		result_transform.origin = anim.native_anim.position_track_interpolate(bone_position_track, _SAMPLE_TIME(anim))
	else:
		result_transform.origin = skeleton.get_bone_pose(bone_idx).origin

	var bone_rotation_track := anim.native_anim.find_track(_bone_to_track_name(bone_idx), Animation.TYPE_ROTATION_3D)
	if bone_rotation_track != -1:
		result_transform.basis = Basis(anim.native_anim.rotation_track_interpolate(bone_rotation_track, _SAMPLE_TIME(anim)))
	else:
		result_transform.basis = skeleton.get_bone_pose(bone_idx).basis
	
	return result_transform

func _SAMPLE_TIME(anim: AnimationData) -> float:
	if anim == curr_anim:
		if curr_anim_looping:
			return fmod(curr_anim_progress + curr_anim.start_time, curr_anim.duration)
		else:
			return curr_anim_progress + curr_anim.start_time
	else:
		if prev_anim_looping:
			return fmod(prev_anim_progress + prev_anim.start_time, prev_anim.duration)
		else:
			return prev_anim_progress + prev_anim.start_time


func _EFFECTIVE_SPEED_SCALE(anim: AnimationData) -> float:
	return global_speed_scale * anim.speed_scale

func _bone_to_track_name(bone_index: int) -> String:
	return "%GeneralSkeleton:" + skeleton.get_bone_name(bone_index)


func get_root_velocity(y_zeroed: bool = true) -> Vector3:
	var root_track_path := _bone_to_track_name(0)
	var pos_track := curr_anim.native_anim.find_track(root_track_path, Animation.TYPE_POSITION_3D)
	if pos_track == -1 or curr_anim.native_anim.track_get_key_count(pos_track) <= 1:
		return Vector3.ZERO

	var scaled_delta = custom_delta * _EFFECTIVE_SPEED_SCALE(curr_anim)
	var prev_pos: Vector3 = curr_anim.native_anim.position_track_interpolate(pos_track, _SAMPLE_TIME(curr_anim) - scaled_delta)
	var curr_pos: Vector3 = curr_anim.native_anim.position_track_interpolate(pos_track, _SAMPLE_TIME(curr_anim))
	var delta_pos = curr_pos - prev_pos
	if y_zeroed:
		delta_pos.y = 0
	if custom_delta <= 0.0:
		return Vector3.ZERO

	return (delta_pos / scaled_delta) * global_speed_scale

func get_current_anim_progress() -> float:
	return curr_anim_progress


func set_global_speed_scale(new_scale: float):
	var max_speed_scale = 2
	var min_speed_scale = 0.4
	if new_scale < min_speed_scale or new_scale > max_speed_scale:
		# u.print_warn(pp.ts("extreme speed scale:", new_scale, "Was:", global_speed_scale, "Will be clamped between", max_speed_scale))
		global_speed_scale = clamp(new_scale, 0.2, 2.0)
	else:
		global_speed_scale = new_scale
	
	# print_.skm(animator_name, "new scale set: " + str(new_scale))

func reset_global_speed_scale():
	print_.skm(animator_name, "scale reset to 1")
	set_global_speed_scale(1)
