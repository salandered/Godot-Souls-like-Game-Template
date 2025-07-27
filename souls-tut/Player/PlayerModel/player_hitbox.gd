extends Area3D


# old way from controller series, works only for a player
#@onready var model = $"../.." as PlayerModel

# new way for enemies series, now lacks strict typing,
# but works now with anything that has a current_move with .react_on_hit() method, makeshift interface if you will
@export var processor: Node


# new way of defining allied weapons to not trigger on owned weapon etc.
@export var ignored_weapon_groups: Array[String]

func _ready():
	area_entered.connect(on_contact)


func on_contact(area: Node3D):
	# if not String(area.get_path()) == "/root/ProtoLevel/Enemy/Model/Root/Hitbox" and not String(area.get_path()) == "/root/ProtoLevel/Player/Model/Root/Hitbox":
	# 	print("hitbox contacted ", area)
	# 	Print.print_info(area)
	if not String(area.get_path()) == "/root/ProtoLevel/Mob/RightWrist/WeaponSocket/Sword" \
	and not String(processor.get_path()) == "/root/ProtoLevel/Player/Model": # and not String(area.get_path()) == "/root/ProtoLevel/Player/Model/RightWrist/WeaponSocket/SwordOh":
		print("hitbox contacted ", area)
		Print.print_info(area)
		Print.print_info(processor)
	if is_eligible_attacking_weapon(area):
		#print("is_eligible_attacking_weapon ", area.get_hit_data())
		area.hitbox_ignore_list.append(self)
		processor.current_state.react_on_hit(area.get_hit_data())

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
