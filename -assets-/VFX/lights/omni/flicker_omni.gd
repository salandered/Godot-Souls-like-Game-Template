@tool
class_name FlickerOmni
extends BaseOmni

# region Exports

## Radius and Energy are handled by the AnimationPlayer
@export_group("Light Settings")


@export_group("Animation & Effects")
@export var speed_scale: float = 1.0:
	set(value):
		speed_scale = value
		if is_node_ready(): _apply_animation_settings()

@export var play_animation: bool = true:
	set(value):
		play_animation = value
		if is_node_ready(): _apply_animation_settings()


# endregion

@onready var animation_player: AnimationPlayer = %AnimationPlayer


class AnimID:
	const flicker = "flicker"


func _ready_implementation() -> void:
	_apply_animation_settings()


# region Apply Functions

func _apply_animation_settings() -> void:
	if not animation_player: return
	
	if play_animation and animation_player.has_animation(AnimID.flicker):
		if not animation_player.is_playing() or animation_player.current_animation != AnimID.flicker:
			animation_player.play(AnimID.flicker)
		animation_player.speed_scale = speed_scale
	else:
		animation_player.stop()


# endregion
