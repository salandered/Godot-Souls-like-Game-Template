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


func _initialise_sfx_configs() -> Dictionary[String, SFXStreamConfig]:
	var list_: Array[SFXStreamConfig] = [
		## fs
		_get_footstep_config(),
		_get_footstep_light_config(),
		_get_footstep_scrape_config(),
		##
		_get_launch_config(),
		_get_land_config(),
		_get_whoosh_config(),
		##
		_get_move_noise_config()
	]
	var _sfx_configs: Dictionary[String, SFXStreamConfig] = {}
	for item in list_:
		_sfx_configs[item.sfx_type] = item
	return _sfx_configs
		

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


## pretty name
## Basic use case: prefix for logging. 
## Should not be treated as ID in any sense! It's just cosmetics.
@abstract func pp_name() -> String


@abstract func is_player() -> bool


## SFX


func _get_footstep_config() -> SFXStreamConfig:
	return SFXStreamConfig.new(SFXConstants.Type_.footstep, -3.0, 0.0, 0.0)

func _get_footstep_light_config() -> SFXStreamConfig:
	return SFXStreamConfig.new(SFXConstants.Type_.footstep_light, -6.0, 0.0, 0.0)

func _get_footstep_scrape_config() -> SFXStreamConfig:
	return SFXStreamConfig.new(SFXConstants.Type_.footstep_scrape, -6.0, 0.0, 0.0)

func _get_launch_config() -> SFXStreamConfig:
	return SFXStreamConfig.new(SFXConstants.Type_.launch, -2.0, 0.0, 0.0)

func _get_land_config() -> SFXStreamConfig:
	return SFXStreamConfig.new(SFXConstants.Type_.land, -2.0, 0.0, 0.0)

func _get_whoosh_config() -> SFXStreamConfig:
	return SFXStreamConfig.new(SFXConstants.Type_.whoosh, -3.0, 0.0, 0.0)

func _get_move_noise_config() -> SFXStreamConfig:
	return SFXStreamConfig.new(SFXConstants.Type_.move_noise, -3.0, 0.0, 0.0)


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
		print_.prefix(pp.s(pp_name(), _prefix), pp.list_(parts), 10)

func __log_warn_soft(what: String, where: String = "", fallback: String = "", ...context: Array):
	error_.warn(what, pp.s(pp_name(), "|", where), fallback, WarnLevel.WARN, pp.list_(context))

func __log_warn(what: String, where: String = "", fallback: String = "", ...context: Array):
	error_.warn(what, pp.s(pp_name(), "|", where), fallback, WarnLevel.PUSH_WARNING, pp.list_(context))

func __log_error(what: String, where: String = "", fallback: String = "", ...context: Array):
	error_.warn(what, pp.s(pp_name(), "|", where), fallback, WarnLevel.PUSH_ERROR, pp.list_(context))


# endregion
