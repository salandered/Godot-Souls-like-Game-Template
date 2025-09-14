extends Area3D

## I call it Hitbox
class_name Hitbox_


## works with anything that has a current_state with .react_on_hit() method
@export var processor: Node


@export var ignored_weapon_groups: Array[String]

func _ready():
	collision_layer = Collision.Layers.HITBOX_AREA
	collision_mask = Collision.Mask.HITBOX_AREA_MASK
	
	print("Hitbox_ ready")
	print(processor, processor.get_path())
	print(ignored_weapon_groups)
	print_.collisions(self)
	print("")
	area_entered.connect(on_contact)


func on_contact(area: Node3D):
	# print("Hitbox contacted ", area.name)
	if is_eligible_attacking_weapon(area):
		print_.prefix("HB", "is_eligible_attacking_weapon " + str(area.get_hit_data()), 6)
		area.hitbox_ignore_list.append(self)


		if not __safe_checks():
			return

		processor.current_state.react_on_hit(area.get_hit_data())


func is_eligible_attacking_weapon(area: Node3D) -> bool:
	if not area is BaseWeapon:
		return false
	
	var weapon: BaseWeapon = area
	

	if _not_ignored_weapon(weapon) \
		and not weapon.hitbox_ignore_list.has(self) \
		and weapon.is_attacking:
		return true
		
	return false


func _not_ignored_weapon(area: Node3D) -> bool:
	for group in ignored_weapon_groups:
		if area.is_in_group(group):
			return false
	return true


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
