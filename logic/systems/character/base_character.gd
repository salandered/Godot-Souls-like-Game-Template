@abstract
class_name BaseCharacter
extends CharacterBody3D


var _sig_container: BaseCharacterSignalContainer
var _combat: BaseCombat

## not nullable after init
func get_sig_container() -> BaseCharacterSignalContainer:
	return _sig_container

## not nullable after init
func get_combat() -> BaseCombat:
	return _combat


func _ready() -> void:
	# 'Moving Platfrom' from UI
	# by default uses all, it's a known problem with RigidBodies at least (see Collision)
	platform_floor_layers = (
		Collision.Layers.ENVIRONMENT_COL |
		Collision.Layers.PLAYER_COL |
		Collision.Layers.OTHER_CHAR_COL
	)

	_initialise_common_char()
	initialise()


func _initialise_common_char() -> void:
	_sig_container = _for_init_sig_container()
	var sad_container := _for_init_sad_container()
	var asp_config_container := _for_init_asp_config_container()

	var anim_container := _for_init_anim_container()
	var anim_params_container := _for_init_anim_params_container()

	var native_player := _for_init_native_player()

	if native_player:
		anim_container._accept_animations(
			_for_init_anim_list().get_list_of_animations(),
			native_player,
			anim_params_container.get_track_prefixes(),
			anim_params_container.get_all_params(),
			_for_init_required_markers())

		_for_init_anim_manager().initialise(native_player, anim_container)

	var visuals := _for_init_visuals()
	if visuals:
		visuals.accept_model_data(self)

	var bones := _for_init_bones()
	if bones:
		bones.accept_bones()
	
	var _r := get_descendants.base_combat(self)
	if not error_.len_one(_r):
		_combat = _r[0]
		_combat.initialise()

		var hit_boxes := get_descendants.char_hit_boxes(self)
		for item: CharacterHitbox in hit_boxes:
			item.initialise(_combat)
		prints(em.pin, "initted", len(hit_boxes), "hitboxes for", pp_name())
	

	_for_init_movement().initialise(self)

	
	var sfx_system := _for_init_sfx_system()
	if sfx_system:
		sfx_system.initialise(
			_sig_container,
			asp_config_container,
			self,
			{sfx_system.character_additional_data_key: self}
			)
	
		_for_init_anim_sfx_sig_emitter().initialise(sad_container, _sig_container)
	
		## NOTE: unlike character sfx, where sfx_system is tied to pl_anim_sfx_sig_emitter,
		##       for weapon we manage emitter here on character side, while its sfx system 
		##       is managed by weapon itself. This is done because anim knowledge is on player side. 
		##       Weapon wouldn't know when to play anim based sounds.
		## NOTE: when character will be able to switch weapons, this part should be re-called on switch
		if _combat:
			var _weapon_id_to_emitter := _for_init_weapon_id_to_emitter()
			var _weapons := _combat.get_all_weapons()
			for weapon: BaseWeapon in _weapons:
				var _emitter: BaseAnimSFXSignalEmitter = _weapon_id_to_emitter.get(weapon.get_weapon_id())
				if not error_.null_object(_emitter):
					_emitter.initialise(weapon.get_sad_container(), weapon.get_signal_container())
					

## abstract so u dont forget to use it instead of _ready()
@abstract func initialise() -> void


## cont
@abstract func _for_init_sig_container() -> BaseCharacterSignalContainer
@abstract func _for_init_sad_container() -> BaseCharacterSADContainer
## anim cont
@abstract func _for_init_anim_container() -> AnimContainer
@abstract func _for_init_anim_list() -> BaseCharAnimList
@abstract func _for_init_anim_params_container() -> BaseAnimParamsContainer
@abstract func _for_init_required_markers() -> Dictionary[String, Array]
## anim
@abstract func _for_init_native_player() -> AnimationPlayer
@abstract func _for_init_anim_manager() -> BaseAnimatorManager
##
@abstract func _for_init_visuals() -> BaseVisuals
@abstract func _for_init_bones() -> BaseCharBones
@abstract func _for_init_movement() -> BaseCharacterMovement
## sfx
@abstract func _for_init_sfx_system() -> CharacterSFXSystem
@abstract func _for_init_asp_config_container() -> BaseCharacterASPConfigContainer
@abstract func _for_init_anim_sfx_sig_emitter() -> BaseAnimSFXSignalEmitter
@abstract func _for_init_weapon_id_to_emitter() -> Dictionary[String, BaseAnimSFXSignalEmitter]


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

@abstract func get_player() -> Princess


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
