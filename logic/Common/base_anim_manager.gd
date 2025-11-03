@tool
@icon("res://-assets-/x_misc/x_icons/node-colors/purple.png")
@abstract
class_name BaseAnimatorManager
extends Node


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
