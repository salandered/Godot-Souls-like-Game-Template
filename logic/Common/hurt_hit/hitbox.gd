@tool
@icon("res://-assets-/x_misc/x_icons/hit_box_3d.svg")
extends Area3D

## Area which CAN BE damaged. Opposed to an area which DAMAGES.
## I call it Hitbox
class_name Hitbox_


## DANGER: should have .current_state with .react_on_hit() method
## TODO: switch to signals?
@export var processor: Node


@export var ignored_weapon_groups: Array[String]

func _ready():
	collision_layer = Collision.Layers.HITBOX_AREA
	collision_mask = Collision.Mask.HITBOX_AREA_MASK
	
	area_entered.connect(on_contact)
	print("--- Hitbox_ ready ---")
	print(processor, processor.get_path())
	print(ignored_weapon_groups)
	print_.collisions(self, 0, true, LogL.NOTSET)


func on_contact(area: Node3D):
	if not area is WeaponHurtBox:
		return

	var _weapon_area = area as WeaponHurtBox
	var weapon: BaseWeapon = _weapon_area.base_weapon
	
	if is_weapon_mine(weapon):
		return

	if not weapon.is_attacking:
		return
	
	if weapon.hitbox_ignore_list.has(self):
		return

	print_.h_box(processor.name, "Area leaded to weapon '" + weapon.weapon_name + "' by '" + weapon.holder.name + "'")

	weapon.hitbox_ignore_list.append(self)

	if not __safe_checks():
		return

	processor.current_state.react_on_hit(weapon.get_hit_data())


func is_weapon_mine(weapon: BaseWeapon) -> bool:
	# todo: just compare holders of weapon and owner
	for group in ignored_weapon_groups:
		if weapon.is_in_group(group):
			return true
	return false


func __safe_checks() -> bool:
	if not "current_state" in processor:
		push_error("Hitbox_: processor does not have current_state")
		return false
	if not processor.current_state:
		push_error("Hitbox_: processor.current_state is null, cannot get hit data")
		return false
	if not processor.current_state.has_method("react_on_hit"):
		push_error("Hitbox_: processor.current_state does not have react_on_hit method, cannot get hit data")
		return false
	return true

# IMPLEMENTATION GUNDYR
# func _physics_process(_delta):
# 	if has_overlapping_areas():
# 		for area in get_overlapping_areas():
# 			on_contact(area)

# region TODO: episode 6 implementation
# `Hurtbox` and `Weapon` moved from signals of contact to scanning all possible contacts. 
# Slower and discouraged by documentation, but docs forgets that a signal won't be fired if the collider is already inside one another when it is activated. 
# This didn't behave as expected, as if our weapon was inside an enemy when our attack started, we could never connect. Now `Hurtbox` works as expected and logs all intersections.
#  		- example: our weapon was inside an enemy when our attack started, we could never connect
# func _physics_process(_delta):
# 	if has_overlapping_areas():
# 		for area in get_overlapping_areas():
# 			on_area_contact(area)
# func on_area_contact(area : Node3D):
# 	#print(area.name)
# 	if is_eligible_attacking_weapon(area):
# 		area.hitbox_ignore_list.append(self)
# 		processor.current_state.react_on_hit(area.get_hit_data())
# endregion

# on_contact debug
	# if not String(area.get_path()) == "/root/ProtoLevel/Enemy/Model/Root/Hitbox" and not String(area.get_path()) == "/root/ProtoLevel/Player/Model/Root/Hitbox":
	# 	print("hitbox contacted ", area)
	# 	print_.print_info(area)
	# if not String(area.get_path()) == "/root/ProtoLevel/Mob/RightWrist/WeaponSocket/Sword" \
	# and not String(processor.get_path()) == "/root/ProtoLevel/Player/Model": # and not String(area.get_path()) == "/root/ProtoLevel/Player/Model/RightWrist/WeaponSocket/SwordOh":
	# 	print("hitbox contacted ", area)
	# 	print_.print_info(area)
	# 	print_.print_info(processor)
