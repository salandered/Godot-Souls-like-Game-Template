extends SkeletonModifier3D
class_name ModifierAnimatorTemp

@export var native_animator: AnimationPlayer ## real AnimationPlayer with anim data
@onready var skeleton = get_skeleton()
@onready var overlay: OverlayFeature = %overlay ## responsible for overlaying another anim

@export var a_name: String ## name of animator

var current_anim: Animation
# Animation can be cyclical to be playing in loop
var current_anim_cycling: bool = true
# counts progress for data interpolation. 
var current_anim_progress: float = 0 # seconds

# for blending between two animations
var previous_anim: Animation
var previous_anim_cycling: bool = true
var previous_anim_progress: float = 0 # seconds

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
var current_transform: Transform3D
var previous_transform: Transform3D

var __initialised: bool = false

var speed_scale := 1.0

func initialise():
	# 45 - first leg bone
	if a_name == 'torso':
		bone_list = range(1, 45)
	elif a_name == 'legs':
		bone_list = range(45, 52)
		# bone_list.append(0) # root is not animated here. If animation is RM, use get_root_velocity()
		# bone_list.append(1) # TODO consider: giving hips bone to legs?
	else:
		push_error("no a_name or its unknown")
	
	__initialised = true


func set_overlay_anim(anim_name: String, fade_in: float = 0.1, hold: float = -1.0, fade_out: float = 0.15, local_speed: float = 1.0):
	var overlay_anim := native_animator.get_animation(anim_name)
	if overlay_anim == null:
		push_error("Overlay animation not found: " + anim_name)
		return
	overlay.set_overlay_anim(overlay_anim, anim_name, fade_in, hold, fade_out, local_speed)


func set_speed_scale(new_scale: float):
	if new_scale < 0.2 or new_scale > 2.0:
		push_warning("extreme new speed scale: " + str(new_scale) + ". Was: " + str(speed_scale))
	speed_scale = clamp(new_scale, 0.4, 2.0)
	print_.skm(a_name, "new scale set (follower as well if any): " + str(new_scale))

func reset_speed_scale():
	speed_scale = 1
	print_.skm(a_name, "scale reset to 1 (follower as well if any)")


func _set_previous_animation():
	previous_anim = current_anim
	previous_anim_cycling = current_anim_cycling
	previous_anim_progress = current_anim_progress


func set_anim_to_play(next_animation: String, blend_for: float = 0):
	# speed_scale = 1 # TODO s??
	if blend_for < 0:
		push_error("can't blend two animations over " + str(blend_for))
	
	last_processing_time = Time.get_unix_time_from_system()

	_set_previous_animation()

	var anim := native_animator.get_animation(next_animation)
	if anim == null:
		push_error("Animation not found: " + next_animation)
		return

	current_anim = anim
	current_anim_progress = 0
	current_anim_cycling = current_anim.loop_mode == Animation.LoopMode.LOOP_LINEAR

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

	current_anim_progress += custom_delta * speed_scale
	previous_anim_progress += custom_delta * speed_scale

	if current_anim_progress > current_anim.length and current_anim_cycling:
		current_anim_progress = fmod(current_anim_progress, current_anim.length)
	if previous_anim_progress > previous_anim.length and previous_anim_cycling:
		previous_anim_progress = fmod(previous_anim_progress, previous_anim.length)


# We use the custom_delta time value we just got and add it to blending_time_counter, 
# and then we update blending_percentage value. 
func _update_blend_values():
	if is_blending:
		blend_time_spent += custom_delta
		blending_percentage = blend_time_spent / blend_duration
		if blending_percentage >= 1:
			blending_percentage = 1
			blending_percentage = 0
			blend_time_spent = 0
			is_blending = false

	overlay._update_blend_values(custom_delta)

func _update_skeleton():
	for bone_idx in bone_list:
		# For each suggested bone, we first calculate its pose according to the `current_anim` and its progress.
		#   - If we don't blend, that's our work for the bone.
		#   - If we do blend, we need to also calculate this bone's pose according to the `previous_anim` and its progress, and then interpolate those two transforms via `blending_progress` value.
		current_transform = calculate_bone_pose(bone_idx, current_anim, current_anim_progress)
		if is_blending:
			previous_transform = calculate_bone_pose(bone_idx, previous_anim, previous_anim_progress)
			current_transform = previous_transform.interpolate_with(current_transform, blending_percentage)
		
		skeleton.set_bone_pose(bone_idx, current_transform)
	
func calculate_bone_pose(bone_idx: int, anim: Animation, anim_progress: float) -> Transform3D:
	# - We search for a position track by turning our bone index into track path.
	# 	  - If -1, it means that `AnimationResource` doesn't contain such a track. For example, that bone doesn't move in this animation. 
	# 	In this case, we set transform's `origin` to the origin of our bone; we don't touch it.
	# 	  - If we find the track, we interpolate the value from it using progress.
	# - then we do the same with rotation. The only difference is type casting because animation stores rotation data in quaternions, but `Transform3D` stores it in basis vector triples.
	var result_transform: Transform3D
	
	var bone_position_track := anim.find_track(_bone_to_track_name(bone_idx), Animation.TYPE_POSITION_3D)
	if bone_position_track != -1:
		result_transform.origin = anim.position_track_interpolate(bone_position_track, anim_progress)
	else:
		result_transform.origin = skeleton.get_bone_pose(bone_idx).origin
	
	var bone_rotation_track := anim.find_track(_bone_to_track_name(bone_idx), Animation.TYPE_ROTATION_3D)
	if bone_rotation_track != -1:
		result_transform.basis = Basis(anim.rotation_track_interpolate(bone_rotation_track, anim_progress))
	else:
		result_transform.basis = skeleton.get_bone_pose(bone_idx).basis
	
	return result_transform


func _bone_to_track_name(bone_index: int) -> String:
	return "%GeneralSkeleton:" + skeleton.get_bone_name(bone_index)


func get_root_velocity(y_zeroed: bool = true) -> Vector3:
	var root_track_path := _bone_to_track_name(0)
	var pos_track := current_anim.find_track(root_track_path, Animation.TYPE_POSITION_3D)
	if pos_track == -1 or current_anim.track_get_key_count(pos_track) <= 1:
		return Vector3.ZERO

	var scaled_delta = custom_delta * speed_scale
	var prev_pos: Vector3 = current_anim.position_track_interpolate(pos_track, current_anim_progress - scaled_delta)
	var curr_pos: Vector3 = current_anim.position_track_interpolate(pos_track, current_anim_progress)
	var delta_pos = curr_pos - prev_pos
	if y_zeroed:
		delta_pos.y = 0
	if custom_delta <= 0.0:
		return Vector3.ZERO

	return (delta_pos / scaled_delta) * speed_scale

# Return length in seconds of the currently active animation.
# If there is no current_anim, return 0.0.
func get_current_anim_length() -> float:
	if current_anim:
		return current_anim.length
	return 0.0
