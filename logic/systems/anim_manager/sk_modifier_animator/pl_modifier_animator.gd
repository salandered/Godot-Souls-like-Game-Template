class_name PlayerModifierAnimator
extends SkeletonModifier3DSystem


@export var config: PlayerConfig

@onready var skeleton := get_skeleton()
@onready var root_animator: PlayerRootAnimator = %RootAnimator

var native_animator: AnimationPlayer ## built-in AnimationPlayer with anim data

var bone_mask: Array

## for animation non related effects like slow-mo
## note that animation may have it's own speed scale. They will be multiplied.
var global_speed_scale := 1.0
var _dev_hard_speed_scale := false


# region: DOCS
## Should not be called directly. PlAnimatorManager uses this.
## TODO: Consider "weighted blend system"
## Maintain a list of active AnimPlaybacks, each with a weight (0.0 to 1.0)
## when set_anim_to_play is called:
##   - Mark all existing playbacks in the list to fade out
##   - Add new AnimPlayback to the list with weight 0.0, marked to fade in
## In _update_blend_values:
##   - Decrease the weight of all fading-out playbacks towards 0.0 over the blend dur
##   - Increase the weight of the fading-in playback towards 1.0 over the blend dur
##   - Remove playbacks from the list when their weight reaches 0
## In _update_skeleton:
##   - Calculate the pose for each active playback in the list.
##   - Calculate the total weight of all active playbacks.
##   - Compute the final pose 
##     (weighted average blend of all calculated poses, using their normalized weights (weight/total_weight))
# endregion


var curr_blend_playback := BlendPlayback.new() # The active B->A blend
var prev_blend_playback := BlendPlayback.new() # The interrupted C->B blend
var prev_prev_blend_playback := BlendPlayback.new() # The twice-interrupted D->C blend

var curr_playback: AnimPlayback # Animation A
var prev_playback: AnimPlayback # Animation B
var prev_prev_playback: AnimPlayback # Animation C
var prev_prev_prev_playback: AnimPlayback # Animation D

var _bone_idx_to_track: Dictionary[int, String] = {}


func __hard_dependencies() -> Array:
	return [
		skeleton,
		root_animator,
		native_animator
	]


func initialize(native_animator_: AnimationPlayer) -> void:
	add_to_group(Groups.Dev.SK_ANIM_MANAGER)

	self.native_animator = native_animator_
	
	BoneTools.validate_skeleton(skeleton)

	## NOTE: root is not animated here. See PlayerRootAnimator
	bone_mask = BoneMask.get_full_body_no_root()

	# cache all bone track paths as a dict
	_bone_idx_to_track = BoneTools.calculate_bone_idx_to_track(skeleton)


	root_animator.initialize(_bone_idx_to_track[BoneIdx.ROOT_0])

	__perform_validation(true)


func set_anim_to_play(anim: AnimationData, blend_for: float = 0, start_time_offset: float = 0):
	# shift anim playbacks down
	prev_prev_prev_playback = prev_prev_playback
	prev_prev_playback = prev_playback
	prev_playback = curr_playback
	curr_playback = AnimPlayback.new(anim, 0.0, start_time_offset)

	# shift blend playbacks down
	prev_prev_blend_playback = prev_blend_playback
	prev_blend_playback = curr_blend_playback
	curr_blend_playback = BlendPlayback.new()

	if blend_for > 0:
		curr_blend_playback.start(blend_for)

	if __LOG_B(): __log_("set_anim_to_play", __print_debug.log_state(self ))


var delta_: float

func _process_modification():
	if not __validation_ok():
		return
		
	delta_ = get_process_delta_time()
	
	_update_time(delta_)
	_update_blend_values(delta_)
	_update_skeleton(delta_)


func _update_time(custom_delta: float):
	#  update curr animation (A)
	curr_playback.time_spent += custom_delta * _get_effective_speed_scale(curr_playback)
	if curr_playback.time_spent > curr_playback.anim.duration and curr_playback.anim.is_looping:
		curr_playback.time_spent = fmod(curr_playback.time_spent, curr_playback.anim.duration)

	#  update prev animation (B)
	# NOTE: curr_blend_playback.is_blending is omitted! useing prev_playback in managers as if it still runs
	if prev_playback:
		if prev_playback.time_spent < prev_playback.anim.duration:
			prev_playback.time_spent += custom_delta * _get_effective_speed_scale(prev_playback)
		
		if curr_blend_playback.is_blending and prev_playback.time_spent > prev_playback.anim.duration and prev_playback.anim.is_looping:
			prev_playback.time_spent = fmod(prev_playback.time_spent, prev_playback.anim.duration)

	# update C
	if prev_prev_playback and prev_blend_playback.is_blending:
		if prev_prev_playback.time_spent < prev_prev_playback.anim.duration:
			prev_prev_playback.time_spent += custom_delta * _get_effective_speed_scale(prev_prev_playback)
		
		if prev_blend_playback.is_blending and prev_prev_playback.time_spent > prev_prev_playback.anim.duration and prev_prev_playback.anim.is_looping:
			prev_prev_playback.time_spent = fmod(prev_prev_playback.time_spent, prev_prev_playback.anim.duration)

	# update D
	if prev_prev_prev_playback and prev_prev_blend_playback.is_blending:
		if prev_prev_prev_playback.time_spent < prev_prev_prev_playback.anim.duration:
			prev_prev_prev_playback.time_spent += custom_delta * _get_effective_speed_scale(prev_prev_prev_playback)

		if prev_prev_blend_playback.is_blending and prev_prev_prev_playback.time_spent > prev_prev_prev_playback.anim.duration and prev_prev_prev_playback.anim.is_looping:
			prev_prev_prev_playback.time_spent = fmod(prev_prev_prev_playback.time_spent, prev_prev_prev_playback.anim.duration)


func _update_blend_values(custom_delta: float):
	curr_blend_playback.update(custom_delta) # new B->A blend
	prev_blend_playback.update(custom_delta) # interrupted C->B blend
	prev_prev_blend_playback.update(custom_delta) # twice-interrupted D->C blend


func _update_skeleton(custom_delta: float):
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
					if __PRINT_MAX_BLEND and __LOG_B(): print_.dev(em.mark, "4 animations!", __print_debug.log_blend_state(self ))
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
	

func _get_effective_speed_scale(playback: AnimPlayback) -> float:
	var r := global_speed_scale * playback.anim.speed_scale
	if config:
		r *= config.SPEED_SCALE_COEF
	return r


func set_global_speed_scale(new_scale: float):
	if _dev_hard_speed_scale:
		return
	if __LOG_B(): __log_("set_global_speed_scale", "new scale set:", new_scale)
	global_speed_scale = new_scale


func reset_global_speed_scale():
	if _dev_hard_speed_scale:
		return
	if __LOG_B(): __log_("reset_global_speed_scale", "scale reset to 1")
	set_global_speed_scale(1.0)


func get_global_speed_scale() -> float:
	return global_speed_scale


## __LOGS
# region

const __PRINT_MAX_BLEND: bool = false


func __LOG_B() -> bool:
	if eu.is_release():
		return false
	return false

func __LOG_INDENT() -> int:
	return 0

# endregion
