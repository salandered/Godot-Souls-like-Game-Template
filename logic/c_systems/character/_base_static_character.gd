@abstract
class_name BaseStaticCharacter
extends CharacterBody3DSystem


var char_type: DVS.CharacterType = DVS.CharacterType.UNKNOWN

var _anim_params_container: BaseAnimParamsContainer
var _anim_container: AnimContainer
var _native_player: AnimationPlayer
var _anim_manager: BaseAnimatorManager
var _combat: BaseCombat
var _look_at_char_marker: LookAtCharacterMarker


@export var dev_tag: StringName = ""

## not nullable after init
func get_combat() -> BaseCombat:
	return _combat


func get_anim_params_container() -> BaseAnimParamsContainer:
	return _anim_params_container


func get_look_at_char_marker() -> LookAtCharacterMarker:
	return _look_at_char_marker


func get_animator_manager() -> BaseAnimatorManager:
	return _anim_manager

##


func __hard_dependencies() -> Array:
	return [
		_anim_params_container,
		_anim_container,
		_native_player,
		_anim_manager,
		_combat,
	]

func __soft_dependencies() -> Array:
	return [
		_look_at_char_marker,
	]


func _ready() -> void:
	if not u.is_editor():
		_initialise_static_char()
		initialise_static_char_implementation()


func _initialise_static_char() -> void:
	_look_at_char_marker = ArrayUtils.get_only_one_or_null(get_descendants.look_at_character_markers(self ))

	_initialise_anim_systems()

	_initialise_combat()


func _initialise_anim_systems() -> void:
	_anim_params_container = ArrayUtils.get_only_one_or_null(get_descendants.base_anim_params_containers(self ))

	_native_player = _for_init_native_player()

	_anim_container = ArrayUtils.get_only_one_or_null(get_descendants.anim_container((self )))

	if _native_player and _anim_params_container:
		_anim_container._accept_animations(
			_for_init_anim_list().get_list_of_animations(),
			_native_player,
			_anim_params_container.get_track_prefixes(),
			_anim_params_container.get_all_params(),
			_for_init_required_markers())

	if _native_player and _anim_container:
		_anim_manager = ArrayUtils.get_only_one_or_null(get_descendants.base_anim_managers(self ))
		if _anim_manager:
			_anim_manager.initialise(_native_player, _anim_container)


func _initialise_combat() -> void:
	_combat = ArrayUtils.get_only_one_or_null(get_descendants.base_combat(self ))
	if _combat:
		_combat.initialise(self , _for_init_active_weapon_id_list())


##

@abstract func initialise_static_char_implementation() -> void


##
@abstract func _for_init_native_player() -> AnimationPlayer
@abstract func _for_init_anim_list() -> BaseCharAnimList
@abstract func _for_init_required_markers() -> Dictionary[StringName, Array]
@abstract func _for_init_active_weapon_id_list() -> Array[StringName]

##
@abstract func react_on_hit(hit_data: HitData) -> void

@abstract func is_invincible() -> bool

##
@abstract func get_player() -> Princess

## should not be null but can't guarantee
@abstract func get_current_state() -> BaseCharacterState

@abstract func get_prev_state_name() -> StringName

@abstract func is_player() -> bool


##

## Character states.
## TODO: was a quick way to make SFX system work. I dont like this API here
##     - > delete

@abstract func get_run_state_names() -> Array[StringName]

@abstract func get_dodge_state_names() -> Array[StringName]

@abstract func get_sprint_state_names() -> Array[StringName]

@abstract func get_idle_state_names() -> Array[StringName]

@abstract func get_power_attacks_state_names() -> Array[StringName]
#
