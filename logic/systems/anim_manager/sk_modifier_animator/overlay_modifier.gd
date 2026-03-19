class_name OverlayModifier
extends SkeletonModifier3DSystem


@onready var skeleton := get_skeleton()


var default_bone_mask: Array[int]


var _bone_idx_to_track: Dictionary[int, String] = {}

## TODO: get rid of this CustomDelta! frame dependent
var __custom_delta: CustomDelta = CustomDelta.new()


const duration = &"duration"
const elapsed = &"elapsed"
const start_w = &"start_w"
const start_hips_w = &"start_hips_w"

class OverlayInstance extends RefCounted:
	var playback: AnimPlayback
	var timing: OverlayTiming
	var bone_mask: Array[int]
	var speed: float
	var curr_weight: float = 0.0
	var curr_hips_weight: float = 0.0

	# TODO: use struct
	var forced_fade: Dictionary[StringName, Variant] = {}

	func _init(playback_: AnimPlayback, timing_: OverlayTiming, bone_mask_: Array[int], speed_: float):
		self.playback = playback_
		self.timing = timing_
		self.bone_mask = bone_mask_
		self.speed = speed_

	# checks if a bone is part of this overlay's mask
	func affects_bone(bone_idx: int, default_mask: Array[int]) -> bool:
		var mask := bone_mask if not bone_mask.is_empty() else default_mask
		return mask.has(bone_idx)

	func start_forced_fade(fade_duration: float, current_w: float, current_hips_w: float):
		forced_fade = {
			duration: max(fade_duration, 0.01), # prevents / 0
			elapsed: 0.0,
			start_w: current_w,
			start_hips_w: current_hips_w
		}
	func is_forced_fade_finished() -> bool:
		return not forced_fade.is_empty() and forced_fade.elapsed >= forced_fade.duration


var curr_overlay: OverlayInstance
var prev_overlay: OverlayInstance


func __hard_dependencies() -> Array:
	return [
		skeleton
	]

func initialize():
	BoneTools.validate_skeleton(skeleton)
	
	default_bone_mask = BoneMask.get_full_body_no_root()
	
	# Cache bone track paths
	_bone_idx_to_track = BoneTools.calculate_bone_idx_to_track(skeleton)

	__perform_validation(true)


func _create_overlay_timing(anim: AnimationData, overlay_config: OverlayConfig) -> OverlayTiming:
	var anim_duration := anim.duration
	if anim.does_marker_exist(MarkerName.OVERLAY.START) and anim.does_marker_exist(MarkerName.OVERLAY.END):
		var start_t := anim.get_marker_time_by_name(MarkerName.OVERLAY.START)
		var end_t := anim.get_marker_time_by_name(MarkerName.OVERLAY.END)
		anim_duration = end_t - start_t
		__log_("used markers for overlay anim", pp.in_q(anim.anim_name), "start:", start_t, "end:", end_t, "orig dur/new:", anim.duration, anim_duration)
	
	return OverlayTiming.new(anim_duration, overlay_config)


func set_overlay_anim(anim: AnimationData, overlay_config: OverlayConfig, start_time_offset: float = 0):
	prev_overlay = curr_overlay

	var new_playback := AnimPlayback.new(anim, 0.0, start_time_offset)
	var new_timing := _create_overlay_timing(anim, overlay_config)
	var new_mask := overlay_config.get_bone_mask()
	var new_speed := overlay_config.get_speed_scale()


	curr_overlay = OverlayInstance.new(new_playback, new_timing, new_mask, new_speed)

	__custom_delta.update_last_process_time()
	__log_(new_timing)


func force_stop_overlay(fade_out_duration: float = 0.2) -> void:
	if curr_overlay:
		# capture the exact weight RIGHT NOW to prevent snapping
		curr_overlay.start_forced_fade(
			fade_out_duration,
			curr_overlay.curr_weight,
			curr_overlay.curr_hips_weight
		)
		__log_("Overlay force stopped. Duration:", fade_out_duration)


## returns 0.0 if no overlay
func get_time_left() -> float:
	if not curr_overlay:
		return 0.0

	var total_duration := curr_overlay.timing.get_total_duration()
	var time_spent := curr_overlay.playback.time_spent
	var remaining := total_duration - time_spent

	return max(0.0, remaining)

	
func _process_modification():
	if not __validation_ok(): ## disabling process_mode disables _process_modification?
		return

	if not curr_overlay and not prev_overlay:
		return

	__custom_delta.update()
	
	__log_process_start(__custom_delta.delta)
	

	_update_time(__custom_delta.delta)
	_update_blend_values()
	_apply_overlay()


func _update_time(custom_delta: float):
	if curr_overlay:
		curr_overlay.playback.time_spent += custom_delta * curr_overlay.speed
		if not curr_overlay.forced_fade.is_empty():
			# i think speed scale may be ignored for UI/Logic fades, but u can multiply by speed as well
			curr_overlay.forced_fade.elapsed += custom_delta
	
	if prev_overlay:
		prev_overlay.playback.time_spent += custom_delta * prev_overlay.speed
		if not prev_overlay.forced_fade.is_empty():
			prev_overlay.forced_fade.elapsed += custom_delta


func _update_blend_values():
	if curr_overlay:
		_calculate_overlay_weight(curr_overlay)
		# Note: curr_overlay is never nulled here, only by set_overlay_anim

	if prev_overlay:
		_calculate_overlay_weight(prev_overlay)
		
		# check if we should kill prev_overlay
		var natural_end := prev_overlay.playback.time_spent >= prev_overlay.timing.get_total_duration()
		var forced_end := prev_overlay.is_forced_fade_finished()
		
		if natural_end or forced_end:
			prev_overlay.curr_weight = 0.0
			prev_overlay.curr_hips_weight = 0.0
			prev_overlay = null


func _calculate_overlay_weight(instance: OverlayInstance) -> void:
	# PRIORITY 1: Forced Fade Out
	if not instance.forced_fade.is_empty():
		var t = instance.forced_fade.elapsed
		var d = instance.forced_fade.duration
		
		d = max(instance.forced_fade.duration, 0.001) # Extra safety
		# Linear fade from captured start weight down to 0
		var progress = clamp(t / d, 0.0, 1.0)
		var factor = 1.0 - progress
		
		instance.curr_weight = instance.forced_fade.start_w * factor
		instance.curr_hips_weight = instance.forced_fade.start_hips_w * factor
		return

	# PRIORITY 2: Natural OverlayTiming
	var time_spent = instance.playback.time_spent
	if time_spent < instance.timing.get_total_duration():
		instance.curr_weight = instance.timing.get_weight_at_time(time_spent)
		instance.curr_hips_weight = instance.timing.get_hips_weight_at_time(time_spent)
	else:
		instance.curr_weight = 0.0
		instance.curr_hips_weight = 0.0


func _apply_overlay() -> void:
	# find all bones we need to modify from both overlays
	var bones_to_modify_set: Dictionary[int, bool] = {}
	if prev_overlay and prev_overlay.curr_weight > 0.0:
		var mask = prev_overlay.bone_mask if not prev_overlay.bone_mask.is_empty() else default_bone_mask
		for bone_idx in mask:
			bones_to_modify_set[bone_idx] = true
			
	if curr_overlay and curr_overlay.curr_weight > 0.0:
		var mask = curr_overlay.bone_mask if not curr_overlay.bone_mask.is_empty() else default_bone_mask
		for bone_idx in mask:
			bones_to_modify_set[bone_idx] = true


	if bones_to_modify_set.is_empty():
		# __log_applying(bones_to_modify_set.keys())
		return

	__log_applying(bones_to_modify_set.keys())

	# loop through the combined set of bones
	for bone_idx in bones_to_modify_set.keys():
		var base_pose := skeleton.get_bone_pose(bone_idx)
		var final_pose := base_pose # Start with the base pose

		# apply prev overlay (if active and affects this bone)
		if prev_overlay and prev_overlay.curr_weight > 0.0 and prev_overlay.affects_bone(bone_idx, default_bone_mask):
			var prev_overlay_pose = _calculate_overlay_bone_pose(bone_idx, prev_overlay.playback)
			final_pose = _blend_pose(final_pose, prev_overlay_pose, prev_overlay.curr_weight, prev_overlay.curr_hips_weight, bone_idx)

		# apply curr overlay (on top of the prev result)
		if curr_overlay and curr_overlay.curr_weight > 0.0 and curr_overlay.affects_bone(bone_idx, default_bone_mask):
			var curr_overlay_pose = _calculate_overlay_bone_pose(bone_idx, curr_overlay.playback)
			final_pose = _blend_pose(final_pose, curr_overlay_pose, curr_overlay.curr_weight, curr_overlay.curr_hips_weight, bone_idx)
			
			__log_overlay_start(bone_idx, base_pose, curr_overlay_pose, final_pose)
		
		skeleton.set_bone_pose(bone_idx, final_pose)


func _calculate_overlay_bone_pose(bone_idx: int, playback: AnimPlayback) -> Transform3D:
	if not playback: # should not happen
		return skeleton.get_bone_pose(bone_idx)

	return BoneTools.calculate_bone_pose_for_anim_playback(
		bone_idx, playback, skeleton, _bone_idx_to_track
	)


func _blend_pose(base_pose: Transform3D, overlay_pose: Transform3D, weight: float, hips_weight: float, bone_idx: int) -> Transform3D:
	var final_pose := Transform3D()
	
	## only blend rotation for Hips
	if bone_idx == BoneIdx.HIPS_1:
		final_pose.origin = base_pose.origin # keep base position
		final_pose.basis = base_pose.basis.slerp(overlay_pose.basis, hips_weight)
	else:
		final_pose = base_pose.interpolate_with(overlay_pose, weight)
	return final_pose

	
## addition logs
# region


var __LOG_OVERLAY_START_B: bool = false
var __LOG_PROCESS_START_B: bool = false


func __log_overlay_start(bone_idx: int, base_pose: Transform3D, overlay_pose: Transform3D, final_pose: Transform3D):
	if curr_overlay and bone_idx < 3 and curr_overlay.playback.time_spent < 0.1 and __LOG_OVERLAY_START_B:
		__log_("Bone", bone_idx, skeleton.get_bone_name(bone_idx))
		__log_("  Base pos:", base_pose.origin, "Overlay pos:", overlay_pose.origin)
		__log_("  Weight:", curr_overlay.curr_weight, "Final:", final_pose.origin)


func __log_applying(bones_to_modify: Array[int]):
	if FrameUtils.ifr() % 60 == 0:
		var weight = curr_overlay.curr_weight if curr_overlay else (prev_overlay.curr_weight if prev_overlay else 0.0)
		__log_("Applying overlay. Weight:", weight, "Bones:", bones_to_modify.slice(0, 5), "...")


func __log_process_start(custom_delta: float):
	if curr_overlay and curr_overlay.playback.time_spent < custom_delta * 2 and __LOG_PROCESS_START_B:
		__log_("=== OVERLAY STARTED ===")
		__log_("Anim:", curr_overlay.playback.anim.anim_name)
		__log_("Duration:", curr_overlay.timing.get_total_duration())
		__log_("Bone mask:", curr_overlay.bone_mask)
		__log_("Skeleton bone count:", skeleton.get_bone_count())


# endregion


## __LOGS
# region

func __LOG_B() -> bool:
	return false

func __LOG_INDENT() -> int:
	return 2

# endregion