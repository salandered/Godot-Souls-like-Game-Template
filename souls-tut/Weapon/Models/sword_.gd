extends WeaponOh
class_name SwordOh


func _ready():
	super._ready()
	print(weapon_name)
	print("WeaponOh: SwordOh ready")
	print(holder)
	print("COLLISION LAYER AND MASK:")
	print_.collisions(self)
	print("")

	base_damage = 10
	basic_attacks = {
		InDataCombatAction.light_attack_pressed: PlayerState.longsword_1
	}


func get_hit_data():
	if holder == null:
		print("Holder is nil")
	return holder.current_state.pack_hit_data(self)
