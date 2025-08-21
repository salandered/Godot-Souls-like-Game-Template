extends SkeletonModifier3D
class_name ModifierAnimator

@export var native_animator: AnimationPlayer
@onready var skeleton = get_skeleton()

@export var a_name: String

var current_anim: Animation
# Animation also can be cyclical to linger infinitely, and each animation needs a variable to count progress for data interpolation. 
var current_anim_cycling: bool = true
var current_anim_progress: float = 0 # seconds

# if we are in the process of blending towards something, we have previous_anim defined
var previous_anim: Animation
var previous_anim_cycling: bool = true
var previous_anim_progress: float = 0 # seconds

# To blend between animations, we use a Boolean flag for execution routes. 
# And then the main variable here is `blending_percentage`.
#     - If zero, then we are full previous animation. If one, we play full current animation.
#     - We calculate `blending_percentage` by knowing the time over which we blend and counting the progress of the process.
var is_blending: bool = false
var blend_duration: float # seconds
var blend_time_spent: float # seconds
var blending_percentage: float # [0 ; 1]

# TODO: Unix time in milliseconds, just as in model states. 
# If you want to have a pause in your game or some time coefficients or to be immune to system time change attacks, 
# create a better time calculation
var last_processing_time: float = 0 # seconds unix from system
var delta := 0.0 # seconds
var now := 0.0 # seconds unix from system

var bone_list: Array
var current_transform: Transform3D
var previous_transform: Transform3D

var bone_position_track: int
var bone_rotation_track: int

var follower: ModifierAnimator

# var derivative_delta: float = 0.02 # what ?

var __initialised: bool = false

var speed_scale := 1.0


# --- Overlay / impact animation ------------------------------------------
# var overlay_anim: Animation
# var overlay_anim_progress: float = 0
# var overlay_anim_cycling: bool = false

# var is_overlay_active: bool = false
# var overlay_blend_duration: float # seconds
# var overlay_blend_time_spent: float = 0 # seconds
# var overlay_blending_percentage: float = 0 # [0 ; 1]

var overlay_anim: Animation
var overlay_anim_progress := 0.0
var overlay_is_active := false

var overlay_fade_in := 0.1 # seconds
var overlay_hold := 0.0 # seconds at full weight
var overlay_fade_out := 0.15 # seconds
var overlay_weight := 0.0 # 0‥1, updated each frame
var overlay_local_speed := 1.0

# Plays a one-shot or looping overlay on top of whatever is currently running.
# `over_time` governs how quickly the overlay fades in *and* back out.
# func play_overlay(next_animation: String, over_time: float = 0.1):
# 	# Reset overlay clock
# 	overlay_blend_time_spent = 0
# 	overlay_blending_percentage = 0
# 	is_overlay_active = true
	
# 	overlay_blend_duration = max(over_time, 0.01)
	
# 	overlay_anim = native_animator.get_animation(next_animation)
# 	if overlay_anim == null:
# 		push_error("Overlay animation not found: " + next_animation)
# 		is_overlay_active = false
# 		return
	
# 	overlay_anim_progress = 0
# 	overlay_anim_cycling = overlay_anim.loop_mode == Animation.LoopMode.LOOP_LINEAR
func play_overlay(name_: String, fade_in: float = 0.1, hold: float = -1.0, fade_out: float = 0.15, local_speed: float = 1.0):
	overlay_anim = native_animator.get_animation(name_)
	if overlay_anim == null:
		push_error("Overlay animation not found: " + name_)
		return
	
	overlay_fade_in = max(fade_in, 0.01)
	overlay_fade_out = max(fade_out, 0.01)
	overlay_hold = overlay_anim.length - overlay_fade_in - overlay_fade_out if hold < 0 else hold
	
	overlay_anim_progress = 0
	overlay_local_speed = local_speed # new var; see §3
	overlay_is_active = true
	overlay_weight = 0


func set_speed_scale(new_scale: float):
	if new_scale < 0.2 or new_scale > 2.0:
		push_warning("extreme new speed scale: " + str(new_scale) + ". Was: " + str(speed_scale))
	speed_scale = clamp(new_scale, 0.4, 2.0)
	if _has_follower():
		follower.speed_scale = speed_scale

func reset_speed_scale():
	speed_scale = 1
	if _has_follower():
		follower.speed_scale = speed_scale

func sync_and_follow(other_animator: ModifierAnimator, over_time: float = 0.0):
	if other_animator == self:
		push_error("You can't sync and follow yourself dumbass")
		return
	if not other_animator.a_name == "legs":
		assert(false, "we are not ready for this")

	_set_previous_animation()

	_mirror_other_animator_data(other_animator)
	
	delta = 0.0 # ?

	if over_time > 0:
		# SOFT SYNC: blend from our current → leader current
		is_blending = true
		blend_time_spent = 0
		blending_percentage = 0
		blend_duration = over_time
	else:
		push_warning("over_time <= 0: " + str(over_time))
	# TODO: HARD SYNC idea? mirrors all previous_anim and blend data
	# 	previous_anim = other_animator.previous_anim
	# 	previous_anim_cycling = other_animator.previous_anim_cycling
	# 	previous_anim_progress = other_animator.previous_anim_progress

	other_animator.accept_follower(self)

func _set_previous_animation():
	previous_anim = current_anim
	previous_anim_cycling = current_anim_cycling
	previous_anim_progress = current_anim_progress

func _mirror_other_animator_data(other_animator: ModifierAnimator):
	current_anim = other_animator.current_anim
	current_anim_cycling = other_animator.current_anim_cycling
	current_anim_progress = other_animator.current_anim_progress

	now = other_animator.now
	last_processing_time = other_animator.last_processing_time
	speed_scale = other_animator.speed_scale


func play(next_animation: String, over_time: float = 0):
	speed_scale = 1 # TODO s??
	if over_time < 0:
		push_error("can't blend two animations over " + str(over_time))
	
	last_processing_time = Time.get_unix_time_from_system()

	_set_previous_animation()

	var anim := native_animator.get_animation(next_animation)
	if anim == null:
		push_error("Animation not found: " + next_animation)
		return

	current_anim = anim
	current_anim_progress = 0
	current_anim_cycling = current_anim.loop_mode == Animation.LoopMode.LOOP_LINEAR

	if over_time > 0:
		is_blending = true
		blend_duration = over_time
		blend_time_spent = 0
		blending_percentage = 0

	if _has_follower():
		print_.prefix("SKM 💀", "'" + a_name + "' makes follower '" + follower.a_name + "' play anim " + next_animation + " over time " + str(over_time))
		follower.play(next_animation, over_time)

func _process_modification():
	if __initialised:
		_update_time()
		_update_blend_values()
		_update_skeleton()


func _update_time():
	# Each frame, first thing we do is we manage our time awareness. 
		# - We do it by calculating the delta between now and the last call.
		# - We then add this delta to our animation progresses, and if animations are cycling, we undergo a cycle switch.
	now = Time.get_unix_time_from_system()
	delta = now - last_processing_time
	last_processing_time = now

	current_anim_progress += delta * speed_scale
	previous_anim_progress += delta * speed_scale

	if current_anim_progress > current_anim.length and current_anim_cycling:
		current_anim_progress = fmod(current_anim_progress, current_anim.length)
	if previous_anim_progress > previous_anim.length and previous_anim_cycling:
		previous_anim_progress = fmod(previous_anim_progress, previous_anim.length)

	# Overlay timing
	# if is_overlay_active:
	# 	overlay_anim_progress += delta * speed_scale
	# 	if overlay_anim_progress > overlay_anim.length and overlay_anim_cycling:
	# 		overlay_anim_progress = fmod(overlay_anim_progress, overlay_anim.length)


# We use the delta time value we just got and add it to blending_time_counter, 
# and then we update blending_percentage value. 
func _update_blend_values():
	if is_blending:
		blend_time_spent += delta
		blending_percentage = blend_time_spent / blend_duration
		if blending_percentage >= 1:
			blending_percentage = 1
			blending_percentage = 0
			blend_time_spent = 0
			is_blending = false

	# Overlay fade-in / hold / fade-out
	if overlay_is_active:
		overlay_anim_progress += delta * overlay_local_speed

		var t := overlay_anim_progress
		if t < overlay_fade_in:
			overlay_weight = t / overlay_fade_in
		elif t < overlay_fade_in + overlay_hold:
			overlay_weight = 1
		elif t < overlay_fade_in + overlay_hold + overlay_fade_out:
			overlay_weight = 1 - ((t - overlay_fade_in - overlay_hold) / overlay_fade_out)
		else:
			overlay_weight = 0
			overlay_is_active = false

func _update_skeleton():
	# 45 - first leg bone
	if a_name == 'torso':
		bone_list = range(1, 45)
	elif a_name == 'legs':
		bone_list = range(45, 52)
		bone_list.append(0) # root
		# bone_list.append(1) # TODO: giving hips bone to legs?
		# bone_list.append(2)
		# bone_list.append(3)

	elif a_name == 'full_body': # todo: deprecated modifier
		bone_list = range(0, skeleton.get_bone_count())
	else:
		push_error("no a_name or its unknown")
	
	for bone in bone_list:
		# For each suggested bone, we first calculate its pose according to the `current_anim` and its progress.
		#   - If we don't blend, that's our work for the bone.
		#   - If we do blend, we need to also calculate this bone's pose according to the `previous_anim` and its progress, and then interpolate those two transforms via `blending_progress` value.
		current_transform = calculate_bone_pose(bone, current_anim, current_anim_progress)
		if is_blending:
			previous_transform = calculate_bone_pose(bone, previous_anim, previous_anim_progress)
			current_transform = previous_transform.interpolate_with(current_transform, blending_percentage)
			# skeleton.set_bone_pose(bone, previous_transform.interpolate_with(current_transform, blending_percentage))
		# else: 
		# 	skeleton.set_bone_pose(bone, current_transform)
		
		# --- Overlay on top ---------------------------------------------------
		# if is_overlay_active:
		# 	var overlay_transform := calculate_bone_pose(bone, overlay_anim, overlay_anim_progress)
		# 	current_transform = current_transform.interpolate_with(overlay_transform, overlay_blending_percentage)

		if overlay_is_active and overlay_weight > 0:
			var overlay_t := calculate_bone_pose(bone, overlay_anim, overlay_anim_progress)
			current_transform = current_transform.interpolate_with(overlay_t, overlay_weight)

		skeleton.set_bone_pose(bone, current_transform)
	
func calculate_bone_pose(bone_idx: int, anim: Animation, anim_progress: float) -> Transform3D:
	# - We search for a position track by turning our bone index into track path.
	# 	  - If -1, it means that `AnimationResource` doesn't contain such a track. For example, that bone doesn't move in this animation. 
	# 	In this case, we set transform's `origin` to the origin of our bone; we don't touch it.
	# 	  - If we find the track, we interpolate the value from it using progress.
	# - then we do the same with rotation. The only difference is type casting because animation stores rotation data in quaternions, but `Transform3D` stores it in basis vector triples.
	var result_transform: Transform3D
	
	bone_position_track = anim.find_track(bone_to_track_name(bone_idx), Animation.TYPE_POSITION_3D)
	if bone_position_track != -1:
		result_transform.origin = anim.position_track_interpolate(bone_position_track, anim_progress)
	else:
		result_transform.origin = skeleton.get_bone_pose(bone_idx).origin
	
	bone_rotation_track = anim.find_track(bone_to_track_name(bone_idx), Animation.TYPE_ROTATION_3D)
	if bone_rotation_track != -1:
		result_transform.basis = Basis(anim.rotation_track_interpolate(bone_rotation_track, anim_progress))
	else:
		result_transform.basis = skeleton.get_bone_pose(bone_idx).basis
	
	return result_transform


func bone_to_track_name(bone_index: int) -> String:
	return "%GeneralSkeleton:" + skeleton.get_bone_name(bone_index)


func accept_follower(new_follower: ModifierAnimator):
	if new_follower == self:
		push_error("You cant follow yourself dumbass")
		return
	if follower == new_follower:
		push_warning("Already has this exact follower dumbass")
		return
	print_.prefix("SKM 💀", "'" + a_name + "' accepted follower '" + new_follower.a_name + "'")
	follower = new_follower

func remove_follower():
	if follower: print_.prefix("SKM 💀", "'" + a_name + "' removes follower '" + follower.a_name + "'")
	else: print_.prefix("SKM 💀", "'" + a_name + "' can't remove null follower")
	follower = null


# from tutorial
# func calculate_root_velocity() -> Vector3:
# 	var resulting_velocity: Vectors3
# 	var adjustment_delta: float = Time.get_unix_time_from_system() - last_update
# 	var curr_now: float = fmod(curr_progress + adjustment_delta, curr_cycle_length)

# 	resulting_velocity = lerp(curr_right_anim.get_root_velocity(curr_now), curr_left_anim.get_root_velocity(curr_now), curr_direction)

# 	if is_blending_spectres:
# 		var prev_now: float = fmod(prev_progress + adjustment_delta, prev_cycle_length)
# 		var prev_velocity = lerp(prev_right_anim.get_root_velocity(prev_now), prev_left_anim.get_root_velocity(prev_now), prev_direction)


func _has_follower() -> bool:
	return follower != null
