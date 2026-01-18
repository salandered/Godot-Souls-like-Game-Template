@abstract
class_name BaseCharacter
extends CharacterBody3DCharacterSystem


var _sig_container: BaseCharacterSignalContainer
var _combat: BaseCombat
var _movement: BaseCharacterMovement
var _anim_params_container: BaseAnimParamsContainer
var _sfx_system: CharacterSFXSystem


## not nullable after init
func get_sig_container() -> BaseCharacterSignalContainer:
	return _sig_container

## not nullable after init
func get_combat() -> BaseCombat:
	return _combat

## not nullable after init
func get_movement() -> BaseCharacterMovement:
	return _movement

func get_anim_params_container() -> BaseAnimParamsContainer:
	return _anim_params_container

func get_sfx_system() -> CharacterSFXSystem:
	return _sfx_system


##

signal SIG_land_wave(char_glob_position: Vector3, anim: String)


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

	var base_anim_params_container_r := get_descendants.base_anim_params_container(self)
	if not error_.len_one(base_anim_params_container_r):
		_anim_params_container = base_anim_params_container_r[0]

	var native_player := _for_init_native_player()

	if native_player and _anim_params_container:
		anim_container._accept_animations(
			_for_init_anim_list().get_list_of_animations(),
			native_player,
			_anim_params_container.get_track_prefixes(),
			_anim_params_container.get_all_params(),
			_for_init_required_markers())

		_for_init_anim_manager().initialise(native_player, anim_container)

	var visuals := _for_init_visuals()
	if visuals:
		visuals.accept_model_data(self)

	var bones := _for_init_bones()
	if bones:
		bones.accept_bones()
	
	var base_combat_r := get_descendants.base_combat(self)
	if not error_.len_one(base_combat_r):
		_combat = base_combat_r[0]
		_combat.initialise(self, _for_init_active_weapon_id_list())

		var hit_boxes := get_descendants.char_hit_boxes(self)
		for item: CharacterHitbox in hit_boxes:
			item.initialise(_combat)
		__log_(em.pin, "initted", len(hit_boxes), "hitboxes for", pp_name())
	

	var base_movement_r := get_descendants.base_character_movement(self)
	if not error_.len_one(base_movement_r):
		_movement = base_movement_r[0]
		_movement.initialise(self)

	
	var sfx_system_r := get_descendants.character_sfx_system(self)
	if not error_.len_one(sfx_system_r):
		_sfx_system = sfx_system_r[0]
	if _sfx_system:
		_sfx_system.initialise(
			_sig_container,
			asp_config_container,
			self,
			{_sfx_system.character_additional_data_key: self}
			)
	
		_for_init_anim_sfx_sig_emitter().initialise(sad_container, _sig_container)
	
		if _combat:
			_initialise_weapons_sfx()


func _initialise_weapons_sfx():
	## NOTE: unlike character sfx, where sfx_system is tied to pl_anim_sfx_sig_emitter,
	##       for weapon we manage emitter here on character side, while its sfx system 
	##       is managed by weapon itself. This is done because anim knowledge is on player side. 
	##       Weapon wouldn't know when to play anim based sounds.
	## NOTE: when character will be able to switch weapons, this part should be re-called on switch
	var _weapon_id_to_emitter := _for_init_weapon_id_to_emitter()
	var _weapons := _combat._get_all_registered_weapons()
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
@abstract func _for_init_required_markers() -> Dictionary[String, Array]
## anim
@abstract func _for_init_native_player() -> AnimationPlayer
@abstract func _for_init_anim_manager() -> BaseAnimatorManager
##
@abstract func _for_init_visuals() -> BaseVisuals
@abstract func _for_init_bones() -> BaseCharBones
@abstract func _for_init_active_weapon_id_list() -> Array[String]
## sfx
@abstract func _for_init_asp_config_container() -> BaseCharacterASPConfigContainer
@abstract func _for_init_anim_sfx_sig_emitter() -> BaseAnimSFXSignalEmitter
@abstract func _for_init_weapon_id_to_emitter() -> Dictionary[String, BaseAnimSFXSignalEmitter]


## should not be null but can't guarantee
@abstract func get_current_state() -> BaseCharacterState


@abstract func get_prev_state_name() -> String


@abstract func react_on_hit(hit_data: HitData) -> void


@abstract func reset_position(y_offset: float = 0.0) -> void


## Character states.
## TODO: was a quick way to make SFX system work. I dont like this API here
##     - > delete

@abstract func get_run_state_names() -> Array[String]

@abstract func get_dodge_state_names() -> Array[String]

@abstract func get_sprint_state_names() -> Array[String]

@abstract func get_idle_state_names() -> Array[String]

@abstract func get_power_attacks_state_names() -> Array[String]
#


@abstract func get_player() -> Princess


# region __LOGS

## pretty name
## Basic use case: prefix for logging. 
## Should not be treated as ID in any sense! It's just cosmetics.
func pp_name() -> String:
	return u.construct_obj_pp_name(self)


## are logs turned on. warn logs are always turned on.
func __LOG_B() -> bool:
	return false

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
