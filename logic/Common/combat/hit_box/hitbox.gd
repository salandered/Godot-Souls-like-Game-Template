@tool
@icon("res://-assets-/x_misc/x_icons/red/hit_box_3d.svg")
extends Area3D

## Area which CAN BE damaged. Opposed to an area which DAMAGES.
class_name Hitbox_

## Docs
## MUST have 'holder' assigned

@export var holder: BaseCharacter


func _ready() -> void:
	collision_layer = Collision.Layers.HITBOX_AREA
	collision_mask = Collision.Mask.HITBOX_AREA_MASK
	
	area_entered.connect(on_contact)
	
	print_.hit_box(name, "--- Hitbox_ ready ---")
	assert(holder, "Set holder!")


func on_contact(incoming_area: Node3D):
	if not incoming_area is WeaponHurtBox:
		return

	var _weapon_area := incoming_area as WeaponHurtBox
	var weapon: BaseWeapon = _weapon_area.base_weapon
	
	if _is_weapon_mine(weapon):
		return
	if not weapon._is_attacking:
		return
	if weapon.is_in_contact_hitbox_list(self):
		return
	weapon.add_hitbox_to_contact_list(self)

	__log_("on_contact", pp.s("Contact with weapon", pp.in_q(weapon.weapon_name), "by", pp.in_q(weapon.holder.name)))

	var hit_data := weapon.get_hit_data()
	if not hit_data:
		__log_(em.warn + "weapon hit data is null")
		return
		
	__log_("Calling apply_hit with hit data", hit_data)
	holder.apply_hit(hit_data)


func _is_weapon_mine(weapon: BaseWeapon) -> bool:
	if weapon.holder == holder:
		return true
	return false
	# note: comparing holders is enough for now but we want also to control
	# certain groups of weapons in the future. See Groups.Weapons 

func _to_string() -> String:
	return "name '%s' Holder '%s'" % [name, holder.name]

func __log_(...parts: Array):
	print_.hit_box(holder.name, pp.list_(parts))


# region: alternative implementation
# Scanning all possible contacts. Slower and discouraged by docs, but 
# a signal won't be fired if colliders are already inside one another. 
# If our weapon was inside an enemy when our attack started, we could never connect. 

# func _physics_process(delta):
# 	if has_overlapping_areas():
# 		for area in get_overlapping_areas():
# 			on_area_contact(area)
# func on_area_contact(area : Node3D):
# 	if is_eligible_attacking_weapon(area):
# 		area.hitbox_ignore_list.append(self)
# 		holder.current_state.react_on_hit(area.get_hit_data())
# endregion
