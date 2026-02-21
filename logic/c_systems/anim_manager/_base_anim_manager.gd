@tool
@icon("res://-assets-/x_icons/node-colors/purple.png")
@abstract
class_name BaseAnimatorManager
extends NodeSystem


var _native_player: AnimationPlayer
var _anim_container: AnimContainer


func __hard_dependencies() -> Array:
	return [
		_native_player,
		_anim_container
	]

	
func initialise(native_player_: AnimationPlayer, anim_container_: AnimContainer) -> void:
	self._anim_container = anim_container_
	self._native_player = native_player_

	initialise_implementation()
	__perform_validation()


@abstract func initialise_implementation() -> void


func get_native_player() -> AnimationPlayer:
	return _native_player


## SET ANIMATIONS TO PLAY ▶️

## speed_scale_coef adds to any speed scale mechanic 
@abstract func set_anim_to_play(anim_id: StringName, blend_for: float, start_time_offset: float) -> void


## GET DATA

## GET CURR ANIM DATA

## Should account for all speed scales (returns real life seconds)
## May start with anim start offset
@abstract func get_curr_anim_effective_time_spent() -> float


## Should account for all speed scales. (returns real life seconds)
## Starts with 0.0
@abstract func get_curr_anim_time_spent() -> float


## Returns the raw, unscaled position. No speed scales, no offset adjustments. 
## Could start with non 0.0. Useful for the work with animation Markers
## Same as AnimationPlayer's 'current_animation_position()'
@abstract func get_curr_anim_position_unscaled() -> float


## Returns the raw, unscaled duration.
## Reference: native Animation.length
@abstract func get_curr_anim_duration_unscaled() -> float


## Should account for all speed scales (returns real life seconds)
@abstract func get_curr_anim_effective_duration() -> float


## nullable
@abstract func get_curr_anim() -> AnimationData


## GLOBAL SPEED SCALE

@abstract func set_global_speed_scale(new_scale: float) -> void


@abstract func reset_global_speed_scale() -> void


@abstract func get_global_speed_scale() -> float


##


## __LOG


func __log_new_anim(prev_anim: AnimationData, new_anim: AnimationData):
	var _prev_anim_name := "-x-"
	if prev_anim:
		_prev_anim_name = pp.in_q(prev_anim.anim_name)
	var _curr_anim_name := "-x-"
	if new_anim:
		_curr_anim_name = pp.in_q(new_anim.anim_name)
	var _msg := pp.s("set_anim_to_play:",
		_curr_anim_name,
		"curr glob-sp-scale", get_global_speed_scale(),
		"  ", pp.in_br("from prev " + _prev_anim_name))
	__log_("", _msg)


func __LOG_INDENT() -> int:
	return 12