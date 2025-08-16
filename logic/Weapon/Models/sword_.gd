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
		InDataCombatAction.light_attack_pressed: PS.longsword_1
	}


func get_hit_data():
	if not __safe_checks():
		return HitData.blank()
	return holder.current_state.pack_hit_data(self)


func __safe_checks() -> bool:
	if not "current_state" in holder:
		push_error("SwordOh: holder does not have current_state")
		return false
	if not holder.current_state:
		push_error("SwordOh: holder.current_state is null, cannot get hit data")
		return false
	if not holder.current_state.has_method("pack_hit_data"):
		push_error("SwordOh: holder.current_state does not have pack_hit_data method, cannot get hit data")
		return false
	return true
