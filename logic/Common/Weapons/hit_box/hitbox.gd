@tool
@icon("res://-assets-/x_misc/x_icons/red/hit_box_3d.svg")
extends Area3D

## Area which CAN BE damaged. Opposed to an area which DAMAGES.
class_name Hitbox_


@export var holder: BaseCharacterBody3D

@export var ignored_weapon_groups: Array[String]


func _ready() -> void:
	collision_layer = Collision.Layers.HITBOX_AREA
	collision_mask = Collision.Mask.HITBOX_AREA_MASK
	
	area_entered.connect(on_contact)
	
	print_.h_box("", "--- Hitbox_ ready ---")
	print_.h_box("", "ignored_weapon_groups " + str(ignored_weapon_groups))
	# print_.collisions(self, 0, true, LogL.NOTSET)


func on_contact(area: Node3D):
	if not area is WeaponHurtBox:
		return

	var _weapon_area := area as WeaponHurtBox
	var weapon: BaseWeapon = _weapon_area.base_weapon
	
	if _is_weapon_mine(weapon):
		return
	if not weapon.is_attacking:
		return
	if weapon.hitbox_ignore_list.has(self):
		return

	print_.h_box(holder.name, pp.s("Area leaded to weapon", pp.in_q(weapon.weapon_name), "by", pp.in_q(weapon.holder.name)))

	weapon.hitbox_ignore_list.append(self)

	var _hit_data := weapon.get_hit_data()
	if not _hit_data:
		print_.h_box(holder.name, em.warn + "weapon hit data is null")
	else:
		print_.h_box(holder.name, "Calling react_on_hit with hit data: " + str(_hit_data))
		holder.react_on_hit(_hit_data)


func _is_weapon_mine(weapon: BaseWeapon) -> bool:
	# note: we could've just compared holders of weapon and hitbox
	# but then we wouldn't be able to ignore certain groups of weapons
	for group in ignored_weapon_groups:
		if weapon.is_in_group(group):
			return true
	return false


# region: alternative implementation
# Scanning all possible contacts. Slower and discouraged by docs, but 
# a signal won't be fired if the colliders are already inside one another. 
# If our weapon was inside an enemy when our attack started, we could never connect. 
# Now `Hurtbox` works as expected and logs all intersections.
#  		- example: our weapon was inside an enemy when our attack started, we could never connect
# func _physics_process(delta):
# 	if has_overlapping_areas():
# 		for area in get_overlapping_areas():
# 			on_area_contact(area)
# func on_area_contact(area : Node3D):
# 	#print(area.name)
# 	if is_eligible_attacking_weapon(area):
# 		area.hitbox_ignore_list.append(self)
# 		holder.current_state.react_on_hit(area.get_hit_data())
# endregion

# on_contact debug
	# if not String(area.get_path()) == "/root/ProtoLevel/Enemy/Model/Root/Hitbox" and not String(area.get_path()) == "/root/ProtoLevel/Player/Model/Root/Hitbox":
	# 	print("hitbox contacted ", area)
	# 	print_.print_info(area)
	# if not String(area.get_path()) == "/root/ProtoLevel/Mob/RightWrist/WeaponSocket/Sword" \
	# and not String(holder.get_path()) == "/root/ProtoLevel/Player/Model": # and not String(area.get_path()) == "/root/ProtoLevel/Player/Model/RightWrist/WeaponSocket/SwordOh":
	# 	print("hitbox contacted ", area)
	# 	print_.print_info(area)
	# 	print_.print_info(holder)
