extends BaseMechAttackState


func initialize_attack_state_implementation() -> void:
	hit_damage = 24


func get_anim_active_weapon_ids() -> Array[StringName]:
	return [WeaponID.fighter_h_arm]


func on_exit_attack_state_implementation() -> void:
	me.varm_position = me.VArmPos.RIGHT
