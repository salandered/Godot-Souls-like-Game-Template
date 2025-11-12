@tool
@icon("res://-assets-/x_misc/x_icons/red/icon_sword.png")

@abstract
class_name BaseWeapon
extends Node3D

## Weapon consists of
# - WeaponHurtBox (area3D) - PACKED SCENE
#     - collision of area3D IS NOT in packed scene
#     - note that godot wants u to change its shape via Shape, not Scale 
# - Weapon visual mesh - optional (e.g. not visuals for leg kick)
## Also
# - see SmithSword implementation for basic approach to all this

## assigned by the holder (owner)
@export var holder: BaseCharacter

## managed by implementation
var _weapon_hurt_box: WeaponHurtBox
var _weapon_name: String = "no_weapon_name_please_add"

## To get a hit only once per attack.
## Hitbox A on contact: 
##    - if A not on the list, writes itself to the list
##    - Further contacts of A with this weapon will be ignored
## Usually is cleared by attack states on_exit()
var _contact_hitbox_list: Array[CharacterHitbox]

## does it hurt right now, usually is managed by state
var _is_attacking: bool = false


## manipulated by combat 
var _hit_data: HitData = null


func _ready() -> void:
	_weapon_hurt_box = get_weapon_hurt_box()
	assert(_weapon_hurt_box, "No _weapon_hurt_box provided for " + get_weapon_name())
	assert(_weapon_hurt_box.get_child(0), "The _weapon_hurt_box must have a CollisionShape3D. " + get_weapon_name())
	assert(holder, "Set holder! for " + get_weapon_name())
	
	_weapon_hurt_box.base_weapon = self
	_weapon_hurt_box.collision_layer = Collision.Layers.WEAPON_AREA
	_weapon_hurt_box.collision_mask = Collision.Masks.WEAPON_AREA_MASK

	_weapon_name = get_weapon_name()

	if not get_weapon_visuals():
		print_.note(false, "Note: Weapon", pp.in_q(get_weapon_name()), "has no visuals")

	initialise()


## additional init or validation if needed
@abstract func initialise() -> void


@abstract func get_weapon_hurt_box() -> WeaponHurtBox


@abstract func get_weapon_name() -> String

## could be nullable (aura weapon)
@abstract func get_weapon_visuals() -> MeshInstance3D


func is_attacking() -> bool:
	return _is_attacking


func set_is_attacking(is_attacking_: bool) -> void:
	_is_attacking = is_attacking_


## nullable
func get_hit_data() -> HitData:
	return _hit_data


func set_hit_data(hit_data: HitData):
	_hit_data = hit_data


func reset_hit_data():
	_hit_data = null


## CONTACT HITBOX LIST MANAGEMENT
# region

func is_in_contact_hitbox_list(hitbox: CharacterHitbox) -> bool:
	return hitbox in _contact_hitbox_list


func add_hitbox_to_contact_list(hitbox: CharacterHitbox) -> void:
	if is_in_contact_hitbox_list(hitbox):
		print_.warn(false, "wanted to add hitbox to contact list. but its there already", "add_hitbox_to_contact_list", "not add", str(hitbox))
		return
	__log_("Added", pp.in_q(hitbox), "to contact list", pp.in_q(_contact_hitbox_list))
	_contact_hitbox_list.append(hitbox)


func reset_contact_hitbox_list() -> void:
	__log_("Reset contact HitB list from", pp.in_q(_contact_hitbox_list))
	_contact_hitbox_list = []

# endregion


## __LOGS
# region

func __pp_holder() -> String:
	return holder.name


func _to_string() -> String:
	return "ID '%s' wepName '%s' Holder '%s' ContactHiBList '%s' isAttack '%s' HitData '%s'" \
		% [str(get_instance_id()), _weapon_name, holder.name, pp.list_(_contact_hitbox_list), str(_is_attacking), str(_hit_data)]


func __log_(...parts: Array):
	print_.weapon(_weapon_name, pp.list_(parts))


# endregion
