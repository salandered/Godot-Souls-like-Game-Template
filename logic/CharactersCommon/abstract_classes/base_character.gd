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


@abstract func get_prev_state_name() -> String


@abstract func react_on_hit(hit_data: HitData) -> void


@abstract func reset_position() -> void


## pretty name
## Basic use case: prefix for logging. 
## Should not be treated as ID in any sense! It's just cosmetics.

@abstract func pp_character_name() -> String


@abstract func is_player() -> bool


# region __LOGS

## are logs turned on. warn logs are always turned on.
# @abstract func __LOG_B() -> bool
func __LOG_B() -> bool:
	return true

## just indent 
# @abstract func __LOG_INDENT() -> int
func __LOG_INDENT() -> int:
	return 0
	

func __log_(_prefix: Variant, ...parts: Array):
	if __LOG_B():
		print_.prefix(pp.s(pp_character_name(), _prefix), pp.list_(parts), 10)

func __log_warn(crucial: bool, what: String, where: String, fallback: String, ...context: Array):
	print_.warn(crucial, what, pp.s(pp_character_name(), "|", where), fallback, pp.list_(context))

# endregion
