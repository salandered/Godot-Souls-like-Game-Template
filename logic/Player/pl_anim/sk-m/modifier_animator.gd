extends SkeletonModifier3D
class_name ModifierAnimator

@export var native_animator: AnimationPlayer ## real AnimationPlayer with anim data
@onready var skeleton = get_skeleton()
@onready var overlay: OverlayFeature = %overlay ## responsible for overlaying another anim
@onready var anim_container: PlayerAnimationContainer = %AnimContainer

@export var a_name: String ## name of animator

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

var follower: ModifierAnimator

var __initialised: bool = false

## for animation non related effects like slow mo
## animation speed scale stored in itslef and is handled separately
var global_speed_scale := 1.0


func initialise():
	# 45 - first leg bone
	if a_name == 'full_body':
		# bone_list = range(1, 45)
		bone_list = range(1, 52)
	elif a_name == 'legs':
		bone_list = range(45, 52)
		# bone_list.append(0) # root is not animated here. If animation is RM, use get_root_velocity()
		# bone_list.append(1) # TODO consider: giving hips bone to legs?
	else:
		push_error("no a_name or its unknown")
	
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

	if _has_follower():
		print_.skm(a_name, "makes follower '" + follower.a_name + "' set_anim_to_play anim " + anim_name + " over time " + str(blend_for))
		follower.set_anim_to_play(anim_name, blend_for)


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
	if _has_follower():
		if curr_anim_progress > follower.curr_anim_progress + 0.01 or curr_anim_progress < follower.curr_anim_progress - 0.01:
			print_.warn("Animators are not in sync, sadly: " + pp.compare("!=", "cur_anim_progress", curr_anim_progress, "follower's", follower.curr_anim_progress))
	return curr_anim_progress


func set_global_speed_scale(new_scale: float):
	var max_speed_scale = 2
	var min_speed_scale = 0.4
	if new_scale < min_speed_scale or new_scale > max_speed_scale:
		# u.print_warn(pp.ts("extreme speed scale:", new_scale, "Was:", global_speed_scale, "Will be clamped between", max_speed_scale))
		global_speed_scale = clamp(new_scale, 0.2, 2.0)
	else:
		global_speed_scale = new_scale
	
	# print_.skm(a_name, "new scale set (follower as well if any): " + str(new_scale))
	if _has_follower():
		follower.global_speed_scale = global_speed_scale

func reset_global_speed_scale():
	print_.skm(a_name, "scale reset to 1 (follower as well if any)")
	set_global_speed_scale(1)

##############  SYNC AND FOLLOW  ##########################
# region:
## called from the follower. other_animator here is future leader.
# makes one animator (currently only torso) follow another (currently only legs).
# in this case if both animators need to play same thing, all sync issues are solved, because follower has everything set up exactly like the leader
# region: todo: I think it was a bad decision:
#   - it seems like in our case this covers > 90% of animation scenarios. 
#   - current code is cumbersome and easily can be broken (when adding new stuff to animator)
# Alternative: make a full_body animator for this 90% cases and legs animator for splitted behaviour.
#   - This full_body wont be needing to sync, because it's full lol.  
#   - splitted legs behaviour would be achieved by overriding full_body legs changes
# 	  OR by using torso and legs like now. (so it'd be three modifiers. active is either full or torso + legs)
# endregion
func sync_and_follow(leader_animator: ModifierAnimator, over_time: float = 0.0):
	if leader_animator == self:
		push_error("You can't sync and follow yourself dumbass")
		return
	if leader_animator.a_name != "legs":
		assert(false, "we are not ready for this now")

	_set_previous_animation()

	_mirror_other_animator_data(leader_animator)
	
	custom_delta = 0.0 # NOTE ?

	if over_time > 0:
		# SOFT SYNC: blend from our current → leader current
		is_blending = true
		blend_time_spent = 0
		blending_percentage = 0
		blend_duration = over_time
	else:
		push_warning("over_time <= 0: " + str(over_time))
	# TODO: HARD SYNC idea? mirrors all prev_anim and blend data
	# 	prev_anim = other_animator.prev_anim
	# 	prev_anim_looping = other_animator.prev_anim_looping
	# 	prev_anim_progress = other_animator.prev_anim_progress

	leader_animator._accept_follower(self)


func _mirror_other_animator_data(leader_animator: ModifierAnimator):
	curr_anim = leader_animator.curr_anim
	curr_anim_looping = leader_animator.curr_anim_looping
	curr_anim_progress = leader_animator.curr_anim_progress

	now = leader_animator.now
	last_processing_time = leader_animator.last_processing_time
	global_speed_scale = leader_animator.global_speed_scale


func _accept_follower(new_follower: ModifierAnimator):
	if new_follower == self:
		push_error("You cant follow yourself dumbass")
		return
	if follower == new_follower:
		push_warning("Already has this exact follower dumbass")
		return
	print_.skm(a_name, "accepted follower " + pp.in_q(new_follower.a_name))
	follower = new_follower

func remove_follower():
	if follower: print_.skm(a_name, " removes follower " + pp.in_q(follower.a_name))
	else: print_.skm(a_name, " can't remove null follower")
	follower = null


func _has_follower() -> bool:
	return follower != null


# endregion
