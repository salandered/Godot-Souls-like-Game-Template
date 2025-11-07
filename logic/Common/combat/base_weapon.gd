@tool
@icon("res://-assets-/x_misc/x_icons/red/icon_sword.png")
extends Node3D
class_name BaseWeapon

## Weapon consists of
# - WeaponHurtBox (area3D) - PACKED SCENE
#     - collision of area3D IS NOT in packed scene
#     - note that godot wants u to change its shape via Shape, not Scale 
# - Weapon visual mesh - optional (e.g. not visuals for leg kick)
## Also
# - Scene in owner tree should have group.
# - see description of properties below
# - see SmithSword implementation for basic approach to all this

## assigned by the holder (owner)
@export var holder: BaseCharacter

## assigned by specific implementation
var weapon_hurt_box: WeaponHurtBox
var weapon_visuals: MeshInstance3D = null
var weapon_name: String = "no_weapon_name_please_add"

## To get a hit only once per attack.
## Hitbox A on contact: 
##    - if A not on the list, writes itself to the list
##    - Further contacts of A with this weapon will be ignored
## Usually is cleared by attack states on_exit()
var _contact_hitbox_list: Array[Hitbox_]

## does it hurt right now, usually is managed by state
var _is_attacking: bool = false


## manipulated by combat 
var _hit_data: HitData = null


func _ready() -> void:
	assert(weapon_hurt_box is Area3D, "Weapon is missing an Area3D node named 'WeaponArea'.")
	assert(weapon_hurt_box.get_child(0), "The 'WeaponArea' must have a CollisionShape3D child.")
	assert(holder, "Set holder!")
	
	weapon_hurt_box.base_weapon = self
	weapon_hurt_box.collision_layer = Collision.Layers.WEAPON_AREA
	weapon_hurt_box.collision_mask = Collision.Mask.WEAPON_AREA_MASK

	if not weapon_visuals:
		print_.note(false, "Note: Weapon", pp.in_q(weapon_name), "has no visuals")


func is_attacking() -> bool:
	return _is_attacking


func set_is_attacking(is_attacking_: bool) -> void:
	_is_attacking = is_attacking_


## can be null
func get_hit_data() -> HitData:
	return _hit_data


func set_hit_data(hit_data: HitData):
	_hit_data = hit_data


func reset_hit_data():
	_hit_data = null


## CONTACT HITBOX LIST MANAGEMENT
# region

func is_in_contact_hitbox_list(hitbox: Hitbox_) -> bool:
	return hitbox in _contact_hitbox_list


func add_hitbox_to_contact_list(hitbox: Hitbox_) -> void:
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
		% [str(get_instance_id()), weapon_name, holder.name, pp.list_(_contact_hitbox_list), str(_is_attacking), str(_hit_data)]


func __log_(...parts: Array):
	print_.weapon(weapon_name, pp.list_(parts))


# endregion
