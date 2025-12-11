@abstract
class_name BaseCharacter
extends CharacterBody3D


## INITIALISATION (OPTIONAL)
# region

var __initialised: bool = false


func __could_not_initialised() -> bool:
	return not __initialised


func __validate_deps_set_init() -> bool:
	var _r := ValidateDependencies.validate_deps_and_set_init_true(self)
	return _r


## returns the result of validation
## NOTE: returns true if only hard deps were met
func __validate_dependencies() -> bool:
	var _r := ValidateDependencies.validate_dependencies(self)
	return _r


func __set_initialised_true() -> bool:
	var _r := ValidateDependencies.set_initialised_true(self)
	return _r


func get_hard_dependencies() -> Array[Object]:
	return []

func get_soft_dependencies() -> Array[Object]:
	return []

# endregion


func _ready() -> void:
	# 'Moving Platfrom' from UI
	# by default uses all, it's a known problem with RigidBodies at least (see Collision)
	platform_floor_layers = (
		Collision.Layers.ENVIRONMENT_COL |
		Collision.Layers.PLAYER_COL |
		Collision.Layers.OTHER_CHAR_COL
	)

	## methods in list can be overidden
	initialise()


## abstract so u dont forget to use it instead of _ready()
@abstract func initialise() -> void


## should not be null but can't guarantee
@abstract func get_current_state() -> BaseCharacterState


@abstract func get_prev_state_name() -> String


@abstract func react_on_hit(hit_data: HitData) -> void


@abstract func reset_position() -> void


## Character states. 
## TODO: was a quick way to make SFX system work. I dont like this API here

@abstract func get_run_state_names() -> Array[String]

@abstract func get_dodge_state_names() -> Array[String]

@abstract func get_sprint_state_names() -> Array[String]

@abstract func get_power_attacks_state_names() -> Array[String]
#


@abstract func is_player() -> bool


# region __LOGS

## pretty name
## Basic use case: prefix for logging. 
## Should not be treated as ID in any sense! It's just cosmetics.
func pp_name() -> String:
	return u.construct_obj_pp_name(self)


## are logs turned on. warn logs are always turned on.
func __LOG_B() -> bool:
	return true

## just indent 
func __LOG_INDENT() -> int:
	return 0
	

func __log_(_prefix: Variant, ...parts: Array):
	if __LOG_B():
		print_.prefix(pp.s(pp_name(), _prefix), pp.list_(parts), __LOG_INDENT())

func __log_warn_soft(what: String, where: String = "", fallback: String = "", ...context: Array):
	error_.warn(what, pp.s(pp_name(), "|", where), fallback, WL.WARN, pp.list_(context))

func __log_warn(what: String, where: String = "", fallback: String = "", ...context: Array):
	error_.warn(what, pp.s(pp_name(), "|", where), fallback, WL.PUSH_WARN, pp.list_(context))

func __log_error(what: String, where: String = "", fallback: String = "", ...context: Array):
	error_.warn(what, pp.s(pp_name(), "|", where), fallback, WL.PUSH_ERROR, pp.list_(context))


# endregion
