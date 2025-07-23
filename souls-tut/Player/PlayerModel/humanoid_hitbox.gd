extends Area3D

@onready var model = $"../.." as PlayerModel


func _ready():
	area_entered.connect(on_contact)


func on_contact(area: Node3D):
	if not String(area.get_path()) == "/root/ProtoLevel/Enemy/Model/Root/Hitbox" and not String(area.get_path()) == "/root/ProtoLevel/Player/Model/Root/Hitbox":
		print("hitbox contacted ", area)
		Print.print_info(area)
	if is_eligible_attacking_weapon(area):
		print("is_eligible_attacking_weapon ", area.get_hit_data())
		area.hitbox_ignore_list.append(self)
		model.current_state.react_on_hit(area.get_hit_data())

## we need a way to know contact was made with an enemy weapon
func is_eligible_attacking_weapon(area: Node3D) -> bool:
	if area is WeaponOh \
		and area != model.active_weapon \
		and not area.hitbox_ignore_list.has(self) \
		and area.is_attacking:
		return true
	return false
