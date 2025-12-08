extends SkeletonModifier3D
## WARNING: should not be called directly!
## 			PlAnimatorManager manages all modifier animators
class_name PlayerModifierAnimator

@export var native_animator: AnimationPlayer ## real AnimationPlayer with anim data
@onready var skeleton := get_skeleton()
@onready var root_animator: PlayerRootAnimator = %RootAnimator

@export var animator_name: String ## name of animator


var bone_mask: Array

var __initialised: bool = false

## for animation non related effects like slow mo
## note that animation may have it's own speed scale. They will be multiplied.
# var _dev_hard_speed_scale := true # for tests
var _dev_hard_speed_scale := false
# var global_speed_scale := 1.0
var global_speed_scale := 1.0


# region: DOCS
# TODO: Consider "weighted blend system"
# Maintain a list of active AnimPlaybacks, each with a weight (0.0 to 1.0)
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
# endregion


var curr_blend_playback := BlendPlayback.new() # The active B->A blend
var prev_blend_playback := BlendPlayback.new() # The interrupted C->B blend
var prev_prev_blend_playback := BlendPlayback.new() # The twice-interrupted D->C blend

var curr_playback: AnimPlayback # Animation A
var prev_playback: AnimPlayback # Animation B
var prev_prev_playback: AnimPlayback # Animation C
var prev_prev_prev_playback: AnimPlayback # Animation D

var _bone_idx_to_track: Dictionary[int, String] = {}
# todo: flying bone attachments


var __custom_delta: CustomDelta = CustomDelta.new()


func initialise() -> void:
	BoneTools.validate_skeleton(skeleton)

	assert(animator_name == "full_body", "no animator_name or its unknown. Only 'full_body' is supported")
	
	## NOTE: root is not animated here. See PlayerRootAnimator
	bone_mask = BoneMask.get_full_body_no_root()

	# Pre-cache all bone track paths into the dictionary
	_bone_idx_to_track = BoneTools.calculate_bone_idx_to_track(skeleton)


	root_animator.initialise(_bone_idx_to_track[BoneIdx.ROOT])
	__initialised = true


func set_anim_to_play(anim: AnimationData, blend_for: float = 0, start_time_offset: float = 0):
	__custom_delta.update_last_process_time()
	
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

	# print_.skm(animator_name, __log_state())


func _process_modification():
	if __initialised:
		# calculate custom_delta between now and the last call.
		__custom_delta.update()
		# add custom_delta to curr anim's time_spent.
		_update_time(__custom_delta.delta)
		_update_blend_values(__custom_delta.delta)
		_update_skeleton(__custom_delta.delta)


func _update_time(custom_delta: float):
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


func _update_blend_values(custom_delta: float):
	curr_blend_playback.update(custom_delta) # new B->A blend
	prev_blend_playback.update(custom_delta) # interrupted C->B blend
	prev_prev_blend_playback.update(custom_delta) # twice-interrupted D->C blend


var __print_4: bool = false

func _update_skeleton(custom_delta: float):
	__print_4 = false
	for bone_idx in bone_mask:
		# Pose for the newest animation (A)
		var curr_transform := _calculate_bone_pose(bone_idx, curr_playback)
		var final_transform: Transform3D

		if curr_blend_playback.is_blending:
			var prev_transform := _calculate_bone_pose(bone_idx, prev_playback) # Pose for animation B
			var blend_base := prev_transform # Start assuming a simple B->A blend

			# Check if the C->B blend is active
			if prev_blend_playback.is_blending and prev_prev_playback:
				var prev_prev_transform := _calculate_bone_pose(bone_idx, prev_prev_playback) # Pose for C
				var blend_base_prev := prev_prev_transform # Start assuming a C->B blend

				# D->C blend
				if prev_prev_blend_playback.is_blending and prev_prev_prev_playback:
					# if not __print_4: print_.dev(em.mark, "4 animations!", __log_blend_state())
					__print_4 = true
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

		skeleton.set_bone_pose(bone_idx, final_transform)


func _calculate_bone_pose(bone_idx: int, playback: AnimPlayback) -> Transform3D:
	return BoneTools.calculate_bone_pose_for_anim_playback(
		bone_idx, playback, skeleton, _bone_idx_to_track
	)
	

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


## __LOG


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


func __log_blend_state() -> String:
	var anim_names: Array[String] = []
	var blend_times: Array[float] = []
	var times_left: Array[float] = []

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
	
	var overlap_duration := "-unknown-"
	if len(times_left) == 3:
		overlap_duration = pp.round_001(min(times_left[0], times_left[1], times_left[2]))
	
	return "Blend anims " + "/".join(anim_names) \
		+"| blend times " + pp.array_(blend_times) \
		+"| times left " + pp.array_(times_left) \
		+"| overlap (may be) " + str(overlap_duration)
