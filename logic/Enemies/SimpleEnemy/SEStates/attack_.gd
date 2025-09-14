extends BaseSEState


@export var animation_length: float
@export var hit_damage: int = 20

func check_transition(delta: float) -> String:
	# if we are in attack, we better attack
	print_.prefix("SE", "attack_: check_transition")

	if distance_to_player() > me.fight_distance:
		print_.prefix("SE", "attack decision: player too far, backtrack")
		return SEState.backtrack
	if distance_to_player() > me.attack_distance:
		print_.prefix("SE", "attack decision: player too far, backtrack")
		return SEState.follow
	if works_longer_than(fatigue):
		print_.prefix("SE", "attack decision: fatigue " + str(fatigue) + " " + str(get_progress()) + " => idle")
		return SEState.idle

	print_.prefix("SE", "attack decision: still attack")
	return SEState.attack # not me.CURRENT!


func update(delta):
	rotate_towards_player()
	manage_weapon()


func manage_weapon():
	if works_between(0.3786, 0.7185):
		right_weapon.is_attacking = true
	else:
		right_weapon.is_attacking = false


func on_enter_state():
	print("on_enter_state for attack, hb ignore ", right_weapon.hitbox_ignore_list, " reseted")
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
# for better approach (smooth and easily editable turns) you can watch my MM3 video about tracking
# and controller series ep.4 for backend animations framework
func rotate_towards_player():
	if works_less_than(0.2):
		var grounded_player_pos = player.global_position; grounded_player_pos.y = me.global_position.y
		u.safe_look_at(me, grounded_player_pos)
