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


var curr_blend_playback := BlendPlayback.new() # The active B->A blend
var prev_blend_playback := BlendPlayback.new() # The interrupted C->B blend

var curr_playback: AnimPlayback # Animation A
var prev_playback: AnimPlayback # Animation B
var prev_prev_playback: AnimPlayback # Animation C


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
	prev_prev_playback = prev_playback
	prev_playback = curr_playback
	curr_playback = AnimPlayback.new(anim, 0.0, start_time_offset)

	# shift blend playbacks down.
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
	if prev_playback: # might not on the very first anim
		if prev_playback.time_spent < prev_playback.anim.duration:
			prev_playback.time_spent += custom_delta * _EFFECTIVE_SPEED_SCALE(prev_playback)
		
		if curr_blend_playback.is_blending and prev_playback.time_spent > prev_playback.anim.duration and prev_playback.anim.is_looping:
			prev_playback.time_spent = fmod(prev_playback.time_spent, prev_playback.anim.duration)

	# update the "previous previous" anim (C)
	if prev_prev_playback:
		if prev_prev_playback.time_spent < prev_prev_playback.anim.duration:
			prev_prev_playback.time_spent += custom_delta * _EFFECTIVE_SPEED_SCALE(prev_prev_playback)
		
		if prev_blend_playback.is_blending and prev_prev_playback.time_spent > prev_prev_playback.anim.duration and prev_prev_playback.anim.is_looping:
			prev_prev_playback.time_spent = fmod(prev_prev_playback.time_spent, prev_prev_playback.anim.duration)


func _update_blend_values():
	curr_blend_playback.update(custom_delta) # new B->A blend
	prev_blend_playback.update(custom_delta) # interrupted C->B blend

	overlay._update_blend_values(custom_delta)


func _update_skeleton():
	for bone_idx in bone_list:
		var curr_transform := _calculate_bone_pose(bone_idx, curr_playback)
		var final_transform: Transform3D

		if curr_blend_playback.is_blending:
			# pose for the prev animation (B)
			var prev_transform := _calculate_bone_pose(bone_idx, prev_playback)

			# if we have an interrupted blend (C->B)
			if prev_blend_playback.is_blending and prev_prev_playback:
				var prev_prev_transform := _calculate_bone_pose(bone_idx, prev_prev_playback) # pose for C
				# blend C and B first, using the old blend's percentage
				var interrupted_blend_result := prev_prev_transform.interpolate_with(prev_transform, prev_blend_playback.percentage)
				# blend that result with A
				final_transform = interrupted_blend_result.interpolate_with(curr_transform, curr_blend_playback.percentage)
			else:
				# normal B->A blend (no C)
				final_transform = prev_transform.interpolate_with(curr_transform, curr_blend_playback.percentage)
		else:
			final_transform = curr_transform # no blending at all, just play A

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
		nt, "GLOB_SPEED:  ", global_speed_scale)
	return msg
