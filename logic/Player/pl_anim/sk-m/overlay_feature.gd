extends Node
class_name OverlayFeature


class OverlayTiming:
	var fade_in: float
	var hold: float # seconds at full weight
	var fade_out: float

	func _init(fade_in_: float, hold_: float, fade_out_: float, overlay_playback_: AnimPlayback):
		fade_in = max(fade_in_, 0.01)
		hold = overlay_playback_.anim.duration - fade_in - fade_out_ if hold_ < 0 else hold_
		fade_out = max(fade_out_, 0.01)

	func get_total_duration() -> float:
		return fade_in + hold + fade_out

	func get_weight_at_time(time_spent: float) -> float:
		if time_spent < fade_in:
			return time_spent / fade_in
		elif time_spent < fade_in + hold:
			return 1.0
		elif time_spent < get_total_duration():
			return 1.0 - (time_spent - fade_in - hold) / fade_out
		else:
			return 0.0

			
var overlay_playback: AnimPlayback
var overlay_is_active := false

var overlay_weight := 0.0 # 0-1, is updated according to OverlayTiming
var overlay_global_speed := 1.0

# All timing values are now stored in this single object
var timing: OverlayTiming

# Plays a one-shot or looping overlay on top of whatever is currently running.
# `over_time` governs how quickly the overlay fades in *and* back out.

func set_overlay_anim(anim: AnimationData, fade_in: float = 0.1, hold: float = -1.0, fade_out: float = 0.15, global_speed: float = 1.0):
	overlay_playback = AnimPlayback.new(anim, 0.0, 0.0)
	
	timing = OverlayTiming.new(fade_in, hold, fade_out, overlay_playback)
	
	overlay_global_speed = global_speed
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
	if overlay_is_active and overlay_weight > 0:
		var overlay_transform := animator._calculate_bone_pose(bone_idx, overlay_playback)
		current_transform = current_transform.interpolate_with(overlay_transform, overlay_weight)
	return current_transform


# NOTE: Here in the end of ModifierAnimator._update_time this could be added for looping overlay anims
# Overlay timing
# if is_overlay_active:
# 	overlay_anim_progress += custom_delta * speed_scale
# 	if overlay_anim_progress > overlay_playback.length and overlay_anim_cycling:
# 		overlay_anim_progress = fmod(overlay_anim_progress, overlay_playback.length)
