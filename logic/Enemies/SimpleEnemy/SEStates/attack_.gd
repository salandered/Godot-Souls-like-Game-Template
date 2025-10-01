extends BaseSEState


@export var animation_length: float
@export var hit_damage: int = 20

func check_transition(delta: float) -> Verdict:
	# if we are in attack, we better attack
	if distance_to_player() > me.fight_distance:
		print_.se_check_trans(state_name, "player too far => backtrack")
		return Verdict.new(SEState.backtrack)
	if distance_to_player() > me.attack_distance:
		print_.se_check_trans(state_name, "player too far => follow")
		return Verdict.new(SEState.follow)
	if works_longer_than(fatigue):
		print_.se_check_trans(state_name, ">fatigue " + str(fatigue) + " " + str(get_progress()) + " => idle")
		return Verdict.new(SEState.idle)

	print_.se_check_trans(state_name, "still attack")
	return Verdict.new(SEState.attack) # not me.CURRENT! upd: why?


func update(delta):
	_rotate_towards_player()
	_manage_weapon()


func _manage_weapon():
	if works_between(0.3786, 0.7185):
		right_weapon.is_attacking = false # TODO TODO DANGER: should be true for working
	else:
		right_weapon.is_attacking = false


func on_enter_state():
	print_.se(state_name + " on_enter", "weapon hb ignore " + str(right_weapon.hitbox_ignore_list) + " reset", 1, LogL.FORCE_PRINT)
	iteration_commitment = animation_length
	right_weapon.hitbox_ignore_list.clear()
	right_weapon.is_attacking = false
	# print_.collisions(right_weapon)


func pack_hit_data(weapon: BaseWeapon) -> HitData:
	var hit = HitData.new()
	hit.damage = hit_damage
	hit.hit_state_animation = animation
	hit.weapon = weapon
	return hit


# wanna be a tracking window
# for better approach (smooth and easily editable turns) see MM3 video about tracking
# and controller series ep.4 for backend animations framework
func _rotate_towards_player():
	if works_less_than(0.2):
		look_at_player(true)
