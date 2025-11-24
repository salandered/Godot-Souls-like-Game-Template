@abstract
class_name BaseCharacter
extends CharacterBody3D


func _ready() -> void:
	# 'Moving Platfrom' from UI
	# by default uses all, it's a known problem with RigidBodies at least (see Collision)
	platform_floor_layers = (
		Collision.Layers.ENVIRONMENT_COL |
		Collision.Layers.PLAYER_COL |
		Collision.Layers.OTHER_CHAR_COL
	)

	initialise()

## abstract so u dont forget to use it instead of _ready()
@abstract func initialise() -> void


## should not be null but can't guarantee
@abstract func get_current_state() -> BaseCharacterState


@abstract func react_on_hit(hit_data: HitData) -> void


@abstract func reset_position() -> void


@abstract func pretty_name() -> String
