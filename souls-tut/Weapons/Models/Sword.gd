extends WeaponOh
class_name SwordOh


func _ready():
	base_damage = 10
	basic_attacks = {
		InputPackageCombatAction.light_attack_pressed: PlayerState.slash_1
	}


func get_hit_data():
	return holder.current_move.form_hit_data(self)
