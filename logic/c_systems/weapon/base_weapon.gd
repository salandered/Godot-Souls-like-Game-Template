@tool
@icon("res://-assets-/x_icons/red/icon_sword.png")

@abstract
class_name BaseWeapon
## TODO: probably weapon should not be character system.
## 	character system is BaseCombat. Weapons exists as it is. 
##  It can have _holder being assigned or not.
extends Node3DCharacterSystem

## Weapon consists of
# - WeaponHurtBox (area3D) - PACKED SCENE
#     - collision of area3D IS NOT in packed scene
#     - note that godot wants u to change its shape via Shape, not Scale 
# - Weapon visual mesh - optional (e.g. no visuals for leg kick)
# - WeaponSFXParent packed scene

## Also
# - see SmithSword implementation for basic approach to all this

var _holder: BaseCharacter

## managed by implementation
var _weapon_hurt_box: WeaponHurtBox

## To get a hit only once per attack.
## Hitbox A on contact: 
##    - if A not on the list, writes itself to the list
##    - Further contacts of A with this weapon will be ignored
## Usually is cleared by attack states on_exit()
var _contact_hitbox_list: Array[CharacterHitbox] = []

## does it hurt right now, usually is managed by state
var _is_attacking: bool = false


## manipulated by combat 
var _hit_data: HitData = null

var _sfx_system: BaseWeaponSFXSystem

var _signal_container: BaseWeaponSignalContainer


## nullable
var spark_marker: Marker3D

func __hard_dependencies() -> Array[Object]:
	return [
		_weapon_hurt_box,
		_holder ## in the future weapon may exist without holder i suppose
	]

func __soft_dependencies() -> Array[Object]:
	return [
		_signal_container,
		_for_init_weapon_sfx_parent(),
		_sfx_system
	]


func initialise(holder: BaseCharacter) -> void:
	self._holder = holder
	## each weapon has its own signals
	_signal_container = BaseWeaponSignalContainer.new()


	_weapon_hurt_box = get_weapon_hurt_box()
	if _weapon_hurt_box:
		_weapon_hurt_box.initialise(self, _signal_container)
	

	## SFX. Here we r not logging any problems, all be logged using __soft_dependencies etc
	var _weapon_sfx := _for_init_weapon_sfx_parent()
	if _weapon_sfx and _holder: # NOTE: without _holder no SFX
		_sfx_system = _get_weapon_sfx_system(_weapon_sfx)
		if _sfx_system:
			_sfx_system.initialise(
				_signal_container,
				_for_init_asp_container(),
				self,
				{_sfx_system.weapon_additional_data_key: self}
			)


	spark_marker = _find_spark_marker()
	initialise_implementation()
	validate_visuals()


	if not __perform_validation():
		__log_warn_soft("not __perform_validation() => deactivate()")
		deactivate()


## nullable in theory
func _get_weapon_sfx_system(weapon_sfx: WeaponSFXParent) -> BaseWeaponSFXSystem:
	return weapon_sfx.get_sfx_system()

@abstract func _for_init_weapon_sfx_parent() -> WeaponSFXParent
@abstract func _for_init_asp_container() -> BaseWeaponASPConfigContainer

## currently not nullable but it's better to treat is as nullable
func get_holder() -> BaseCharacter:
	return _holder


## additional init or validation if needed
@abstract func initialise_implementation() -> void


@abstract func get_weapon_hurt_box() -> WeaponHurtBox


func pp_name() -> String:
	return pp.s("🗡️ Weapon", get_weapon_id())


@abstract func get_weapon_id() -> String


@abstract func validate_visuals() -> void

func is_attacking() -> bool:
	return _is_attacking


func set_is_attacking(is_attacking_: bool) -> void:
	_is_attacking = is_attacking_


## 

func activate():
	self.visible = true
	process_mode = PROCESS_MODE_INHERIT
	if get_weapon_hurt_box():
		get_weapon_hurt_box().process_mode = PROCESS_MODE_INHERIT
	if _sfx_system:
		_sfx_system.enable()

func deactivate():
	self.visible = false
	process_mode = PROCESS_MODE_DISABLED
	if get_weapon_hurt_box():
		get_weapon_hurt_box().process_mode = PROCESS_MODE_DISABLED
	if _sfx_system:
		_sfx_system.disable()


## HIT DATA
# region

## nullable
func get_hit_data() -> HitData:
	return _hit_data


func set_hit_data(hit_data: HitData):
	_hit_data = hit_data


func reset_hit_data():
	_hit_data = null

# endregion


## CONTACT HITBOX LIST MANAGEMENT
# region

func get_contact_hitbox_list() -> Array[CharacterHitbox]:
	return _contact_hitbox_list


func is_in_contact_hitbox_list(hitbox: CharacterHitbox) -> bool:
	return hitbox in _contact_hitbox_list


func add_hitbox_to_contact_list(hitbox: CharacterHitbox) -> void:
	if is_in_contact_hitbox_list(hitbox):
		__log_error("wanted to add hitbox to contact list. but its there already", "add_hitbox_to_contact_list", "not add", str(hitbox))
		return
	__log_("Added", pp.in_q(hitbox), "to contact list", pp.in_q(_contact_hitbox_list))
	_contact_hitbox_list.append(hitbox)


func reset_contact_hitbox_list() -> void:
	# __log_("Reset contact HitB list from", pp.in_q(_contact_hitbox_list))
	_contact_hitbox_list = []

# endregion


## public
func get_signal_container() -> BaseWeaponSignalContainer:
	return _signal_container
	
## public
@abstract func get_sad_container() -> WeaponSADContainer


## in theory could be nullable
# # @abstract func get_sfx_hit_stream_for_target(target: Node3D) -> AudioStream
# func get_sfx_hit_stream_for_target(target: Node3D) -> AudioStream:
# 	return null


const _SPARK_MARKER_NAME = "SparkMarker"

func _find_spark_marker() -> Marker3D:
	var markers := get_descendants.markers_3d(self)
	for item: Marker3D in markers:
		if item.name == _SPARK_MARKER_NAME:
			return item
	return null


## can be overriden
func get_spark_config() -> ParticlesConfig:
	return ParticlesConfig.new(8, 0.3)


## __LOGS
# region
func __LOG_B():
	return LogToggler.WEAPON_B

func __LOG_INDENT() -> int:
	return 0

func _to_string() -> String:
	var _pp_holder := _holder.pp_name() if _holder else ""
	return "ID '%s' wepName '%s' Holder '%s' Len of ContactHiBList '%d' isAttack '%s' HitData '%s'" \
		% [str(get_instance_id()), pp_name(), pp.in_q(_pp_holder), len(get_contact_hitbox_list()), str(_is_attacking), str(_hit_data)]

# endregion
