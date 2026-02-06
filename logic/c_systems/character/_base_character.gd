@abstract
class_name BaseCharacter
extends BaseStaticCharacter


var _sig_container: BaseCharacterSignalContainer

var _movement: BaseCharacterMovement
var _sfx_system: CharacterSFXSystem
var _look_at_manager: BaseLookAtManager
var _area_awareness: BaseAreaAwareness
var _bones: BaseCharBones
var _visuals: BaseVisuals


## not nullable after init
func get_sig_container() -> BaseCharacterSignalContainer:
	return _sig_container


## not nullable after init
func get_movement() -> BaseCharacterMovement:
	return _movement


func get_sfx_system() -> CharacterSFXSystem:
	return _sfx_system


func get_look_at_manager() -> BaseLookAtManager:
	return _look_at_manager


func get_area_awareness() -> BaseAreaAwareness:
	return _area_awareness


##

signal SIG_land_wave(char_glob_position: Vector3, anim: String)


func __hard_dependencies() -> Array:
	var ds: Array[Object] = [
		_sig_container,
		_movement,
		_area_awareness,
		# _bones, ## not ready in enemy
		# _visuals ## not ready in enemy
	]
	return super.__hard_dependencies() + ds

func __soft_dependencies() -> Array:
	var ds: Array[Object] = [
		_sfx_system,
		# _look_at_manager, ## not ready
	]
	return super.__soft_dependencies() + ds


func initialise_static_char_implementation() -> void:
	# 'Moving Platfrom' from UI
	# by default uses all, it's a known problem with RigidBodies at least (see Collision)
	platform_floor_layers = (
		Collision.Layers.ENVIRONMENT_COL |
		Collision.Layers.PLAYER_COL |
		Collision.Layers.OTHER_CHAR_COL
	)

	_initialise_common_char()
	initialise_base_char_implementation()


func _initialise_common_char() -> void:
	_sig_container = _for_init_sig_container()


	_visuals = _for_init_visuals()
	if _visuals:
		_visuals.accept_model_data(self )


	_bones = _for_init_bones()
	if _bones:
		_bones.accept_bones()
	
	
	_initialise_area_awareness()

	if _area_awareness:
		_movement = ArrayUtils.get_only_one_or_null(get_descendants.base_character_movement(self ))
		if _movement:
			_movement.initialise(self , _area_awareness)


	_initialise_char_sfx_systems()
	
	if _combat:
		_initialise_weapons_sfx()


func _initialise_area_awareness() -> void:
	_area_awareness = ArrayUtils.get_only_one_or_null(get_descendants.base_area_awareness(self ))
	if _area_awareness:
		_area_awareness.initialise(self )


func _initialise_char_sfx_systems() -> void:
	var asp_config_container := _for_init_asp_config_container()

	_sfx_system = ArrayUtils.get_only_one_or_null(get_descendants.character_sfx_systems(self ))

	if _sfx_system:
		_sfx_system.initialise(
			_sig_container,
			asp_config_container,
			self ,
			{_sfx_system.character_additional_data_key: self }
		)
	
		var sad_container := _for_init_sad_container()
		if sad_container:
			_for_init_anim_sfx_sig_emitter().initialise(sad_container, _sig_container)


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


##


## abstract so u dont forget to use it instead of _ready()
@abstract func initialise_base_char_implementation() -> void


## cont
@abstract func _for_init_sig_container() -> BaseCharacterSignalContainer
@abstract func _for_init_sad_container() -> BaseCharacterSADContainer
##
@abstract func _for_init_visuals() -> BaseVisuals
@abstract func _for_init_bones() -> BaseCharBones
## sfx
@abstract func _for_init_asp_config_container() -> BaseCharacterASPConfigContainer
@abstract func _for_init_anim_sfx_sig_emitter() -> BaseAnimSFXSignalEmitter
@abstract func _for_init_weapon_id_to_emitter() -> Dictionary[String, BaseAnimSFXSignalEmitter]


@abstract func reset_position(y_offset: float = 0.0) -> void


# region __LOGS


## are logs turned on. warn logs are always turned on.
func __LOG_B() -> bool:
	return false


# endregion
