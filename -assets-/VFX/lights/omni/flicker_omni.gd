@tool
class_name FlickerOmni
extends BaseOmni

# region Exports

@export_group("Animation & Effects")
@export var speed_scale: float = 1.0:
	set(value):
		speed_scale = value
		if is_node_ready(): _apply_playing_anim_settings()

## if true, will be used as multiplier to set energy/radius
@export var play_animation: bool = true:
	set(value):
		play_animation = value
		if is_node_ready(): _apply_playing_anim_settings()

@export var move_speed_scale: float = 1.0:
	set(value):
		move_speed_scale = value
		if is_node_ready(): _apply_playing_anim_settings()

@export var play_move_animation: bool = false:
	set(value):
		play_move_animation = value
		if is_node_ready(): _apply_playing_anim_settings()

@export_group("Animated params. DO NOT EDIT")
@export var _animated_energy_strength: float = 1.0:
	set(value):
		_animated_energy_strength = value
		if is_node_ready():
			_apply_light_settings()

@export var _animated_range_strength: float = 1.0:
	set(value):
		_animated_range_strength = value
		if is_node_ready():
			_apply_light_settings()

# endregion

@onready var flicker_animator: AnimationPlayer = %FlickerAnimator
@onready var move_animator: AnimationPlayer = %MoveAnimator


class AnimID:
	const flicker = "flicker_fuck"
	const omni_move = "omni_move"


func _ready_implementation() -> void:
	_apply_playing_anim_settings()


# region Apply Functions


func _apply_light_settings() -> void:
	super._apply_light_settings()
	
	if omni_light_3d:
		omni_light_3d.light_energy = energy * _animated_energy_strength
		omni_light_3d.omni_range = radius * _animated_range_strength


func _apply_playing_anim_settings() -> void:
	if play_animation:
		_play_anim(flicker_animator, AnimID.flicker, speed_scale)
	if play_move_animation:
		_play_anim(move_animator, AnimID.omni_move, move_speed_scale)


func _play_anim(animator: AnimationPlayer, anim_id: String, speed_scale_: float) -> void:
	if not animator: return
	
	if play_animation and animator.has_animation(anim_id):
		if not animator.is_playing() or animator.current_animation != anim_id:
			animator.play(anim_id)
			var anim_length := animator.get_animation(anim_id).length
			animator.seek(randf_range(0.0, anim_length))
		animator.speed_scale = speed_scale_
	else:
		animator.stop()


# endregion
