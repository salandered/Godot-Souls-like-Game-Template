extends Node
class_name OverlayFeature


# --- Overlay / impact animation ------------------------------------------
# var overlay_anim_cycling: bool = false

# var is_overlay_active: bool = false
# var overlay_blend_duration: float # seconds
# var overlay_blend_time_spent: float = 0 # seconds
# var overlay_blending_percentage: float = 0 # [0 ; 1]

var overlay_anim: AnimationData
var overlay_anim_progress := 0.0
var overlay_is_active := false

var overlay_fade_in := 0.1 # seconds
var overlay_hold := 0.0 # seconds at full weight
var overlay_fade_out := 0.15 # seconds
var overlay_weight := 0.0 # 0‥1, updated each frame
var overlay_local_speed := 1.0

# Plays a one-shot or looping overlay on top of whatever is currently running.
# `over_time` governs how quickly the overlay fades in *and* back out.
# region: some version
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
# endregion
func set_overlay_anim(_overlay_anim: AnimationData, fade_in: float = 0.1, hold: float = -1.0, fade_out: float = 0.15, local_speed: float = 1.0):
	overlay_anim = _overlay_anim
	overlay_fade_in = max(fade_in, 0.01)
	overlay_fade_out = max(fade_out, 0.01)
	overlay_hold = overlay_anim.duration - overlay_fade_in - overlay_fade_out if hold < 0 else hold
	
	overlay_anim_progress = 0
	overlay_local_speed = local_speed # new var; see §3
	overlay_is_active = true
	overlay_weight = 0


# We use the custom_delta time value we just got and add it to blending_time_counter, 
# and then we update blending_percentage value. 
func _update_blend_values(custom_delta):
	# Overlay fade-in / hold / fade-out
	if overlay_is_active:
		overlay_anim_progress += custom_delta * overlay_local_speed

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


func apply_overlay(bone_idx: int, current_transform: Transform3D, animator: ModifierAnimator) -> Transform3D:
	# --- Overlay on top of current_transform ---------------------------------------------------
	if overlay_is_active and overlay_weight > 0:
		var overlay_transform := animator._calculate_bone_pose(bone_idx, overlay_anim, overlay_anim_progress)
		current_transform = current_transform.interpolate_with(overlay_transform, overlay_weight)
	return current_transform


# func _update_time():
	# NOTE: Here in the end of ModifierAnimator._update_time this was commented. Consifer in the future.
	# Overlay timing
	# if is_overlay_active:
	# 	overlay_anim_progress += custom_delta * speed_scale
	# 	if overlay_anim_progress > overlay_anim.length and overlay_anim_cycling:
	# 		overlay_anim_progress = fmod(overlay_anim_progress, overlay_anim.length)
