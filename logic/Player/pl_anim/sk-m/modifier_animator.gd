extends SkeletonModifier3D
## WARNING: should not be called directly!
## 			AnimatorManager manages all modifier animators
class_name ModifierAnimator

@export var native_animator: AnimationPlayer ## real AnimationPlayer with anim data
@onready var skeleton := get_skeleton()
@onready var overlay: OverlayFeature = %overlay ## responsible for overlaying another anim

@export var animator_name: String ## name of animator

# TODO: Unix time in millisecond, needs a better time calculation
var last_processing_time: float = 0 # seconds unix from system
var custom_delta := 0.0 # seconds
var now := 0.0 # seconds unix from system

var bone_list: Array

var __initialised: bool = false

## for animation non related effects like slow mo
## note that animation may have it's own speed scale. They will be multiplied.
# var _dev_hard_speed_scale := true # for tests
var _dev_hard_speed_scale := false
# var global_speed_scale := 1.0
var global_speed_scale := 1.0

# TODO: Consider "weighted blend system"
# Maintain a list of active AnimPlayback s, each with a weight (0.0 to 1.0)
# when set_anim_to_play is called:
#   - Mark all existing playbacks in the list to fade out
#   - Add new AnimPlayback to the list with weight 0.0, marked to fade in
# In _update_blend_values:
#   - Decrease the weight of all fading-out playbacks towards 0.0 over the blend dur
#   - Increase the weight of the fading-in playback towards 1.0 over the blend dur
#   - Remove playbacks from the list when their weight reaches 0
# In _update_skeleton:
#   - Calculate the pose for each active playback in the list.
#   - Calculate the total weight of all active playbacks.
#   - Compute the final pose 
#     (weighted average blend of all calculated poses, using their normalized weights (weight/total_weight))

var curr_blend_playback := BlendPlayback.new() # The active B->A blend
var prev_blend_playback := BlendPlayback.new() # The interrupted C->B blend
var prev_prev_blend_playback := BlendPlayback.new() # The twice-interrupted D->C blend

var curr_playback: AnimPlayback # Animation A
var prev_playback: AnimPlayback # Animation B
var prev_prev_playback: AnimPlayback # Animation C
var prev_prev_prev_playback: AnimPlayback # Animation D

var _bone_idx_to_track := {}
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

	var full_range := range(0, 52)
		# Pre-cache all bone track paths into the dictionary
	for bone_idx in full_range:
		_bone_idx_to_track[bone_idx] = "%GeneralSkeleton:" + skeleton.get_bone_name(bone_idx)

	__initialised = true


func set_overlay_anim(anim: AnimationData, fade_in: float = 0.1, hold: float = -1.0, fade_out: float = 0.15, local_speed: float = 1.0):
	overlay.set_overlay_anim(anim, fade_in, hold, fade_out, local_speed)


func set_anim_to_play(anim: AnimationData, blend_for: float = 0, start_time_offset: float = 0):
	last_processing_time = Time.get_unix_time_from_system()
	
	# shift anim playbacks down.
	prev_prev_prev_playback = prev_prev_playback
	prev_prev_playback = prev_playback
	prev_playback = curr_playback
	curr_playback = AnimPlayback.new(anim, 0.0, start_time_offset)

	# shift blend playbacks down.
	prev_prev_blend_playback = prev_blend_playback
	prev_blend_playback = curr_blend_playback
	curr_blend_playback = BlendPlayback.new()

	if blend_for > 0:
		curr_blend_playback.start(blend_for)

	print_.skm(animator_name, __log_state())


func _process_modification():
	if __initialised:
		_update_time()
		_update_blend_values()
		_update_skeleton()


func _update_time():
	# Each frame we manage time awareness. 
		# - Calculate the custom_delta between now and the last call.
		# - Then add this custom_delta to curr anim's time_spent.
	now = Time.get_unix_time_from_system()
	custom_delta = now - last_processing_time
	last_processing_time = now


	#  update curr animation (A)
	curr_playback.time_spent += custom_delta * _EFFECTIVE_SPEED_SCALE(curr_playback)
	if curr_playback.time_spent > curr_playback.anim.duration and curr_playback.anim.is_looping:
		curr_playback.time_spent = fmod(curr_playback.time_spent, curr_playback.anim.duration)

	#  update prev animation (B)
	if prev_playback: # curr_blend_playback.is_blending is omitted! NOTE: we use prev_playback in manager as if it still runs
		if prev_playback.time_spent < prev_playback.anim.duration:
			prev_playback.time_spent += custom_delta * _EFFECTIVE_SPEED_SCALE(prev_playback)
		
		if curr_blend_playback.is_blending and prev_playback.time_spent > prev_playback.anim.duration and prev_playback.anim.is_looping:
			prev_playback.time_spent = fmod(prev_playback.time_spent, prev_playback.anim.duration)

	# update C
	if prev_prev_playback and prev_blend_playback.is_blending:
		if prev_prev_playback.time_spent < prev_prev_playback.anim.duration:
			prev_prev_playback.time_spent += custom_delta * _EFFECTIVE_SPEED_SCALE(prev_prev_playback)
		
		if prev_blend_playback.is_blending and prev_prev_playback.time_spent > prev_prev_playback.anim.duration and prev_prev_playback.anim.is_looping:
			prev_prev_playback.time_spent = fmod(prev_prev_playback.time_spent, prev_prev_playback.anim.duration)

	# update D
	if prev_prev_prev_playback and prev_prev_blend_playback.is_blending:
		if prev_prev_prev_playback.time_spent < prev_prev_prev_playback.anim.duration:
			prev_prev_prev_playback.time_spent += custom_delta * _EFFECTIVE_SPEED_SCALE(prev_prev_prev_playback)

		if prev_prev_blend_playback.is_blending and prev_prev_prev_playback.time_spent > prev_prev_prev_playback.anim.duration and prev_prev_prev_playback.anim.is_looping:
			prev_prev_prev_playback.time_spent = fmod(prev_prev_prev_playback.time_spent, prev_prev_prev_playback.anim.duration)


func _update_blend_values():
	curr_blend_playback.update(custom_delta) # new B->A blend
	prev_blend_playback.update(custom_delta) # interrupted C->B blend
	prev_prev_blend_playback.update(custom_delta) # twice-interrupted D->C blend

	overlay._update_blend_values(custom_delta)

var print_4: bool = false

func _update_skeleton():
	print_4 = false
	for bone_idx in bone_list:
		# Pose for the newest animation (A)
		var curr_transform := _calculate_bone_pose(bone_idx, curr_playback)
		var final_transform: Transform3D

		if curr_blend_playback.is_blending:
			var prev_transform := _calculate_bone_pose(bone_idx, prev_playback) # Pose for animation B
			var blend_base = prev_transform # Start assuming a simple B->A blend

			# Check if the C->B blend is active
			if prev_blend_playback.is_blending and prev_prev_playback:
				var prev_prev_transform := _calculate_bone_pose(bone_idx, prev_prev_playback) # Pose for C
				var blend_base_prev = prev_prev_transform # Start assuming a C->B blend

				# D->C blend
				if prev_prev_blend_playback.is_blending and prev_prev_prev_playback:
					if not print_4: print_.prefix_s(em.mark, "4 animations!", __log_blend_state())
					print_4 = true
					var prev_prev_prev_transform := _calculate_bone_pose(bone_idx, prev_prev_prev_playback) # Pose for D
					# calculate D->C blend first
					blend_base_prev = prev_prev_prev_transform.interpolate_with(prev_prev_transform, prev_prev_blend_playback.percentage)

				# Calculate the C->B blend (using D->C result if applicable)
				blend_base = blend_base_prev.interpolate_with(prev_transform, prev_blend_playback.percentage)

			# Finally, blend the result of all previous blends towards A
			final_transform = blend_base.interpolate_with(curr_transform, curr_blend_playback.percentage)

		else:
			# just play A
			final_transform = curr_transform

		final_transform = overlay.apply_overlay(bone_idx, final_transform, self)
		skeleton.set_bone_pose(bone_idx, final_transform)


func _calculate_bone_pose(bone_idx: int, playback: AnimPlayback) -> Transform3D:
	# Search for a pos track by turning bone index into track path.
	# 	- If -1, it means that anim dont have it. E.g that bone doesn't move in this animation. 
	# 	  => we set transform's `origin` to the origin of our bone; we don't touch it.
	#   - If track's found, we get interpolated value from it using effective anim time.
	# Same with rotation. Difference is type casting because anim stores rot data in quaternions, 
	# 	but `Transform3D` stores it in basis vector triples.
	var result_transform: Transform3D
	
	var _track_path: String = _bone_idx_to_track[bone_idx]
		
	var bone_pos_track := playback.anim.get_pos_track_idx(_track_path)
	var bone_rot_track := playback.anim.get_rot_track_idx(_track_path)
	var playback_eff_progress := playback.get_effective_progress()

	if bone_pos_track != -1:
		result_transform.origin = playback.native_anim.position_track_interpolate(bone_pos_track, playback_eff_progress)
	else:
		# var rest_origin = skeleton.get_bone_rest(bone_idx).origin # Rest pose
		# var current_origin = skeleton.get_bone_pose(bone_idx).origin # Current pose
		# if rest_origin != current_origin:
			# print("Bone %d - Rest: %v, Current: %v" % [bone_idx, rest_origin, current_origin])
		# result_transform.origin = current_origin
		result_transform.origin = skeleton.get_bone_pose(bone_idx).origin

	if bone_rot_track != -1:
		result_transform.basis = Basis(playback.native_anim.rotation_track_interpolate(bone_rot_track, playback_eff_progress))
	else:
		result_transform.basis = skeleton.get_bone_pose(bone_idx).basis
	
	return result_transform


func _EFFECTIVE_SPEED_SCALE(playback: AnimPlayback) -> float:
	return global_speed_scale * playback.anim.speed_scale


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
	# cached version of "%GeneralSkeleton:" + skeleton.get_bone_name(bone_idx)
	return _bone_idx_to_track[bone_idx]

# endregion


func __log_state() -> String:
	var nt := "\n\t\t\t"
	var msg := pp.s(
		"TO:  ", curr_playback,
		nt, "BLEND:  ", curr_blend_playback,
		nt, "FROM:  ", prev_playback,
		nt, "PREV_BLEND:  ", prev_blend_playback,
		nt, "PREV_PREV:  ", prev_prev_playback,
		nt, "PREV_PREV_PREV: ", prev_prev_prev_playback,
		nt, "GLOB_SPEED:  ", global_speed_scale)
	return msg


# Add this function to your modifier_animator.gd script

func __log_blend_state() -> String:
	var anim_names = []
	var blend_times = []
	var times_left = []

	if prev_prev_blend_playback.is_blending and prev_prev_prev_playback and prev_prev_playback:
		anim_names.append(prev_prev_prev_playback.anim.anim_name) # D
		anim_names.append(prev_prev_playback.anim.anim_name) # C
		blend_times.append(prev_prev_blend_playback.duration)
		times_left.append(prev_prev_blend_playback.time_remaining())

	if prev_blend_playback.is_blending and prev_playback:
		anim_names.append(prev_playback.anim.anim_name) # B
		blend_times.append(prev_blend_playback.duration)
		times_left.append(prev_blend_playback.time_remaining())

	if curr_blend_playback.is_blending and curr_playback:
		anim_names.append(curr_playback.anim.anim_name) # A
		blend_times.append(curr_blend_playback.duration)
		times_left.append(curr_blend_playback.time_remaining())
	
	var overlap_duration = "-unknown-"
	if len(times_left) == 3:
		overlap_duration = pp.round_001(min(times_left[0], times_left[1], times_left[2]))
	
	return "Blend anims " + "/".join(anim_names) \
		+"| blend times " + pp.list_(blend_times) \
		+"| times left " + pp.list_(times_left) \
		+"| overlap (may be) " + str(overlap_duration)
