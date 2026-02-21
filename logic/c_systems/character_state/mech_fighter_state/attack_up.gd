extends BaseMechAttackState


func initialise_attack_state_implementation() -> void:
	hit_damage = 15

func get_anim_active_weapon_ids() -> Array[StringName]:
	return [WeaponID.fighter_v_arm]
