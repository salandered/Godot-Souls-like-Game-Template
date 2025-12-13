@tool
@icon("res://-assets-/x_icons/red/icon_sword.png")

@abstract
class_name BaseWeapon
extends BaseNode3DCharacterSystem

## Weapon consists of
# - WeaponHurtBox (area3D) - PACKED SCENE
#     - collision of area3D IS NOT in packed scene
#     - note that godot wants u to change its shape via Shape, not Scale 
# - Weapon visual mesh - optional (e.g. not visuals for leg kick)
# - WeaponSFXParent packed scene

## Also
# - see SmithSword implementation for basic approach to all this

## assigned by the _holder (owner)
@export var _holder: BaseCharacter

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


func get_hard_dependencies() -> Array[Object]:
	return [
		_weapon_hurt_box,
		_weapon_hurt_box.get_child(0), # The _weapon_hurt_box must have a CollisionShape3D
		_holder
	]

func get_soft_dependencies() -> Array[Object]:
	return [
		_signal_container,
		_for_init_weapon_sfx_parent(),
		_sfx_system
	]


func _ready() -> void:
	## each weapon has its own signals
	_signal_container = BaseWeaponSignalContainer.new()


	_weapon_hurt_box = get_weapon_hurt_box()
	if _weapon_hurt_box:
		_weapon_hurt_box.initialise(self, _signal_container)
	if not get_weapon_visuals(): # its ok while aura is in wip
		pass
		# print_.note(false, "Note: Weapon", pp.in_q(get_weapon_id()), "has no visuals")
	

	## SFX. Here we r not logging any problems, all be logged using get_soft_dependencies etc
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

	initialise_implementation()
	__validate_dependencies()

## nullable in theory
func _get_weapon_sfx_system(weapon_sfx: WeaponSFXParent) -> BaseWeaponSFXSystem:
	return weapon_sfx.get_sfx_system()

@abstract func _for_init_weapon_sfx_parent() -> WeaponSFXParent
@abstract func _for_init_asp_container() -> BaseWeaponASPConfigContainer

## nullable but hard checked
func get_holder() -> BaseCharacter:
	return _holder


## additional init or validation if needed
@abstract func initialise_implementation() -> void


@abstract func get_weapon_hurt_box() -> WeaponHurtBox


func pp_name() -> String:
	return pp.s("🗡️ Weapon", get_weapon_id())


@abstract func get_weapon_id() -> String


## could be nullable (aura weapon)
@abstract func get_weapon_visuals() -> MeshInstance3D


func is_attacking() -> bool:
	return _is_attacking


func set_is_attacking(is_attacking_: bool) -> void:
	_is_attacking = is_attacking_


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


## __LOGS
# region

func __LOG_B():
	return LogToggler.WEAPON_B

func __LOG_INDENT() -> int:
	return 0

func _to_string() -> String:
	return "ID '%s' wepName '%s' Holder '%s' Len of ContactHiBList '%d' isAttack '%s' HitData '%s'" \
		% [str(get_instance_id()), pp_name(), _holder.pp_name(), len(get_contact_hitbox_list()), str(_is_attacking), str(_hit_data)]

# endregion
