extends BaseSEState


@export var animation_length: float
@export var hit_damage: int = 20


# func check_transition(delta: float) -> SEVerdict:
# 	# if we are in attack, we better attack
# 	if distance_to_player() > me.fight_distance:
# 		print_.se_check_trans(state_name, "player too far => backtrack")
# 		return SEVerdict.new(SEState.backtrack)
# 	if distance_to_player() > me.attack_distance:
# 		print_.se_check_trans(state_name, "player too far => follow")
# 		return SEVerdict.new(SEState.follow)
# 	if works_longer_than(fatigue):
# 		print_.se_check_trans(state_name, ">fatigue " + str(fatigue) + " " + str(get_progress()) + " => idle")
# 		return SEVerdict.new(SEState.idle)

# 	print_.se_check_trans(state_name, "still attack")
# 	return SEVerdict.new(SEState.attack) # not me.CURRENT! upd: why?


# func on_enter_state()-> void:
# 	print_.se(state_name + " on_enter", "")
# 	iteration_commitment = animation_length
# 	combat.set_hit_data(hit_damage, anim_id)


# func on_exit_state() -> void:
# 	combat.reset_active_weapon()

	
# func update(delta):
# 	_rotate_towards_player()
# 	_manage_weapon()


# func _manage_weapon():
# 	if works_between(0.3786, 0.7185):
# 		combat.update_is_attacking(true)
# 	else:
# 		combat.update_is_attacking(false)

# # see MM3 video for ideas about tracking
# func _rotate_towards_player():
# 	if works_less_than(0.2):
# 		e_movement.look_at_player(true)
