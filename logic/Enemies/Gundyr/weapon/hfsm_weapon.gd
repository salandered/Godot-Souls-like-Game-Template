extends WeaponOh
class_name HFSMWeapon


func get_hit_data():
	return holder.get_lowest_active_state().pack_hit_data(self)
