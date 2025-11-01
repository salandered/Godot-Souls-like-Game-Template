extends Node
class_name OverlayFeature

class OverlayConfig:
	var weight: float
	var fade_in: float
	var fade_out: float
	var speed_scale: float
	## seconds at full weight
	## if not set, will be calculated using anim dur, and fade in/out
	var hold: float
	var bone_mask: Array[int]

	func _init(weight_: float = 0.5, fade_in_: float = 0.1, fade_out_: float = 0.1, speed_scale_: float = 1.0, hold_: float = -1.0, bone_mask_: Array[int] = []):
		self.weight = weight_
		self.fade_in = fade_in_
		self.fade_out = fade_out_
		self.speed_scale = speed_scale_
		self.hold = hold_
		self.bone_mask = bone_mask_

	func _to_string() -> String:
		return "~~~OverlayCfg[w:%.1f, in:%.1f, out:%.1f, spd:%.1f, h:%.1f]" % [weight, fade_in, fade_out, speed_scale, hold]

class OverlayTiming:
	var fade_in: float
	var hold: float
	var fade_out: float
	var weight: float

	func _init(anim_dur_: float, overlay_config: OverlayConfig):
		self.fade_in = max(overlay_config.fade_in, 0.01)
		if overlay_config.hold == -1.0:
			self.hold = anim_dur_ - overlay_config.fade_in - overlay_config.fade_out
		else:
			self.hold = overlay_config.hold
		self.fade_out = max(overlay_config.fade_out, 0.01)
		self.weight = overlay_config.weight

	func get_total_duration() -> float:
		return fade_in + hold + fade_out

	func get_weight_at_time(time_spent: float) -> float:
		if time_spent < fade_in:
			return (time_spent / fade_in) * weight
		elif time_spent < fade_in + hold:
			return weight
		elif time_spent < get_total_duration():
			return weight * (1.0 - (time_spent - fade_in - hold) / fade_out)
		else:
			return 0.0
	
	func _to_string() -> String:
		return "~~~OverlayTiming[w:%.1f, in:%.1f, hold:%.1f, out:%.1f, total:%.1f]" % [weight, fade_in, hold, fade_out, get_total_duration()]

var overlay_playback: AnimPlayback
var overlay_is_active := false

var overlay_weight := 0.0 # 0-1, is updated according to OverlayTiming
var overlay_global_speed := 1.0

var bone_mask: Array[int] = []

var timing: OverlayTiming

# plays a one-shot or looping overlay on top of whats currently playing.

func set_overlay_anim(anim: AnimationData, overlay_config: OverlayFeature.OverlayConfig):
	overlay_playback = AnimPlayback.new(anim, 0.0, 0.0)
	
	var anim_duration = anim.duration
	if anim.does_marker_exist(Marker.Name_.OVERLAY_START) and anim.does_marker_exist(Marker.Name_.OVERLAY_END):
		var start_t = anim.get_marker_time_by_name(Marker.Name_.OVERLAY_START)
		var end_t = anim.get_marker_time_by_name(Marker.Name_.OVERLAY_END)
		anim_duration = end_t - start_t
		print_.skm("~~~Overlay", pp.s("used markers for overlay anim", pp.in_q(anim.anim_name), "start:", start_t, "end:", end_t, "orig dur/new:", anim.duration, anim_duration))
	timing = OverlayTiming.new(anim_duration, overlay_config)
	
	print_.skm("~~~Overlay", pp.s(timing))
	overlay_global_speed = overlay_config.speed_scale
	bone_mask = overlay_config.bone_mask
	overlay_is_active = true
	overlay_weight = 0


# We use the custom_delta time value we just got and add it to blending_time_counter, 
# and then we update blending_percentage value. 
func _update_blend_values(custom_delta):
	if overlay_is_active:
		overlay_playback.time_spent += custom_delta * overlay_global_speed

		var time_spent := overlay_playback.time_spent

		if time_spent < timing.get_total_duration():
			overlay_weight = timing.get_weight_at_time(time_spent)
		else:
			overlay_weight = 0.0
			overlay_is_active = false
			

func apply_overlay(bone_idx: int, current_transform: Transform3D, animator: ModifierAnimator) -> Transform3D:
	if not overlay_is_active or overlay_weight <= 0:
		return current_transform
	
	if not bone_mask.is_empty() and not bone_mask.has(bone_idx):
		return current_transform

	var overlay_transform := animator._calculate_bone_pose(bone_idx, overlay_playback)
	current_transform = current_transform.interpolate_with(overlay_transform, overlay_weight)
	return current_transform


# NOTE: Here in the end of ModifierAnimator._update_time this could be added for looping overlay anims
# Overlay timing
# if is_overlay_active:
# 	overlay_anim_progress += custom_delta * speed_scale
# 	if overlay_anim_progress > overlay_playback.length and overlay_anim_cycling:
# 		overlay_anim_progress = fmod(overlay_anim_progress, overlay_playback.length)
