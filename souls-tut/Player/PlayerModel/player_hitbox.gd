extends Area3D


class_name Hitbox_ # Hurtbox on Ep. 6

# old way from controller series, works only for a player
#@onready var model = $"../.." as PlayerModel

# new way for enemies series, now lacks strict typing,
# but works now with anything that has a current_state with .react_on_hit() method, makeshift interface if you will
@export var processor: Node


# new way of defining allied weapons to not trigger on owned weapon etc.
@export var ignored_weapon_groups: Array[String]

func _ready():
	area_entered.connect(on_contact)


func on_contact(area: Node3D):
	# if not String(area.get_path()) == "/root/ProtoLevel/Enemy/Model/Root/Hitbox" and not String(area.get_path()) == "/root/ProtoLevel/Player/Model/Root/Hitbox":
	# 	print("hitbox contacted ", area)
	# 	Print.print_info(area)
	# if not String(area.get_path()) == "/root/ProtoLevel/Mob/RightWrist/WeaponSocket/Sword" \
	# and not String(processor.get_path()) == "/root/ProtoLevel/Player/Model": # and not String(area.get_path()) == "/root/ProtoLevel/Player/Model/RightWrist/WeaponSocket/SwordOh":
	# 	print("hitbox contacted ", area)
	# 	Print.print_info(area)
	# 	Print.print_info(processor)
	if is_eligible_attacking_weapon(area):
		#print("is_eligible_attacking_weapon ", area.get_hit_data())
		area.hitbox_ignore_list.append(self)
		processor.current_state.react_on_hit(area.get_hit_data())


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
# 		processor.current_move.react_on_hit(area.get_hit_data())
# endregion

## we need a way to know contact was made with an enemy weapon
func is_eligible_attacking_weapon(area: Node3D) -> bool:
	if area is WeaponOh \
		and is_not_ignored(area) \
		and not area.hitbox_ignore_list.has(self) \
		and area.is_attacking:
		return true
	return false


func is_not_ignored(area: Node3D) -> bool:
	for group in ignored_weapon_groups:
		if area.is_in_group(group):
			return false
	return true
