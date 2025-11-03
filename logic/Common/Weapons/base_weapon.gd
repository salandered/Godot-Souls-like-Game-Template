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
@export var holder: BaseCharacterBody3D

## assigned by specific implementation
var weapon_hurt_box: WeaponHurtBox
var weapon_visuals: MeshInstance3D = null
var weapon_name: String = "no_weapon_name_needs_fix"

## To get a hit only once per attack.
## If hitbox doesn't find itself in the list
##    - it registers the contact
##    - writes itself into the list to ignore all further contacts
## Usually is cleared by attack states on_exit
var hitbox_ignore_list: Array[Area3D]

## does it hurt right now, usually is managed by state
var is_attacking: bool = false


## manipulated by combat 
var _hit_data: HitData = null


func _ready() -> void:
	weapon_hurt_box.base_weapon = self
	weapon_hurt_box.collision_layer = Collision.Layers.WEAPON_AREA
	weapon_hurt_box.collision_mask = Collision.Mask.WEAPON_AREA_MASK

	if not weapon_visuals:
		print_.note(false, "Note: Weapon", pp.in_q(weapon_name), "has no visuals")

	assert(weapon_hurt_box is Area3D, "Weapon is missing an Area3D node named 'WeaponArea'.")
	assert(weapon_hurt_box.get_child(0), "The 'WeaponArea' must have a CollisionShape3D child.")


## can be null
func get_hit_data() -> HitData:
	return _hit_data


func set_hit_data(hit_data: HitData):
	_hit_data = hit_data


func reset_hit_data():
	_hit_data = null


func __pp_holder() -> String:
	return holder.name
