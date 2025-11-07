@tool
@icon("res://-assets-/x_misc/x_icons/red/hit_box_3d.svg")
extends Area3D

## Area which CAN BE damaged. Opposed to an area which DAMAGES.
class_name Hitbox_

## Docs
##  - MUST have 'combat' assigned
## 
##  - Character can have any number of hitboxes. 
##    Hitbox takes HitData from incoming weapon and passes to BaseCombat.
##    BaseCombat processes any HitData instance only once using unique ID.
##    => as long as weapon has the same HitData while contacting with hitboxes, the hit will be processed just once
##    
##  - Multiple registers on contacting same Hitbox_ with the same HurtBox is prevented
##    by 'add_hitbox_to_contact_list' logic. It stores contacted hitbox on a weapon side.
##    It also means that u can have any number of hurt boxes on a weapon.
##    Technically the mechanic of processing any hitbox only once at BaseCombat side makes 'contact_list' less important
##    But the weapon knowing what it hits and other character's BaseCombat knowing what hits was applied 
##    are two separate bounded contexts (like, player and an enemy)
##    So it cleaner this way. Also faster.
##
## About _physics_process implementation
# region: 
## Used to be 'area_entered.connect(on_area_contact)'
## but signal won't be fired if colliders are already inside one another. 
## If the weapon is inside a hit box when attack started, it won't register. 
## So we switched to _physics_process.
## Consider other approaches in case of perf issues...
# endregion


@export var combat: BaseCombat


func _ready() -> void:
	collision_layer = Collision.Layers.HITBOX_AREA
	collision_mask = Collision.Mask.HITBOX_AREA_MASK
	# 
	print_.hit_box(name, "--- Hitbox_ ready ---")
	assert(combat, "Set combat system!")


func _physics_process(delta):
	if has_overlapping_areas():
		for area in get_overlapping_areas():
			on_area_contact(area)


func on_area_contact(incoming_area: Node3D):
	if not incoming_area is WeaponHurtBox:
		return

	# prints("contact", incoming_area, incoming_area.name, incoming_area.get_class())
	var _weapon_area := incoming_area as WeaponHurtBox
	var weapon: BaseWeapon = _weapon_area.base_weapon
	if not weapon:
		__log_warn("weapon is null", "on_area_contact", "return")
		return

	if _is_weapon_mine(weapon):
		return

	
	__log_extra("contact after _is_weapon_mine", incoming_area, weapon)
	if not weapon.is_attacking():
		# if combat is PlayerCombat:
		# 	print_.prefix_s("contact", incoming_area, incoming_area.name, incoming_area.get_class())
		# __log_extra("Not attacking")
		return

	__log_extra("contact after weapon.is_attacking():", incoming_area, weapon)

	## NOTE: addint to contact list only after other checks
	if weapon.is_in_contact_hitbox_list(self):
		__log_("is_in_contact_hitbox_list true", weapon._contact_hitbox_list, self)
		return
	weapon.add_hitbox_to_contact_list(self)

	__log_("on_area_contact", pp.s("Contact with weapon", pp.in_q(weapon.weapon_name), "by", pp.in_q(weapon.holder.name)))

	var hit_data := weapon.get_hit_data()
	if not hit_data:
		__log_warn("weapon hit data is null", "on_area_contact", "return")
		return

	if combat is PlayerCombat:
		prints("contact", em.crucial_x2, "/n", em.crucial_x2)
		
	__log_("Calling apply_hit with hit data", hit_data)
	combat.apply_hit(hit_data)


func _is_weapon_mine(weapon: BaseWeapon) -> bool:
	if weapon.holder == combat.get_character():
		return true
	return false
	# note: comparing holders is enough for now but we want also to control
	# certain groups of weapons in the future. See Groups.Weapons 

func _to_string() -> String:
	return "name '%s' of Combat '%s'" % [name, combat.get_combat_name()]


var __EXTRA_LOG_B: bool = false


func __log_(...parts: Array):
	# if not combat.is_player():
	print_.hit_box(name, pp.list_(parts))

func __log_extra(...parts: Array):
	# if not combat.is_player():
	if __EXTRA_LOG_B:
		print_.hit_box(name, pp.list_(parts))


func __log_warn(what: String, where: String, fallback: String, ...context: Array):
	print_.warn(false, what, "HitBox " + self.name + " " + where, fallback, pp.list_(context))
