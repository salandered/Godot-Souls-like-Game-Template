extends BaseMechAttackState


func initialise_attack_state_implementation() -> void:
	hit_damage = 25


func get_anim_active_weapon_ids() -> Array[String]:
	return [WeaponID.fighter_h_arm]


func on_exit_attack_state_implementation() -> void:
	me.varm_position = me.VArmPos.RIGHT
