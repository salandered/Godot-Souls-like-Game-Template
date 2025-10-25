extends BasePHEAttack
class_name ClubPHEAttack


func initialise() -> void:
	default_sp.ANGULAR_SPEED = 1
	sp_config = SpeedConfig.new(default_sp)
	blend_time.set_by_prev_action({
		PHEState.Leaf.club_part_1: 0.15,
		PHEState.Leaf.club_part_2: 0.15,
		PHEState.Leaf.club_part_3_4: 0.15
	})
	blend_time.set_specific(0.3)


func on_enter_state():
	combat.set_hit_data_to_active_weapon(hit_damage, anim.anim_id)


func on_exit_state():
	combat.reset_active_weapon()


func update(delta):
	e_movement.rotate_towards_player(delta, sp_config, angle_adjustment)
	e_movement.move_with_root(delta)
	manage_weapons()
