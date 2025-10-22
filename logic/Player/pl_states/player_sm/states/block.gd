extends PlayerState

@export var block_coefficient: float = 0.5
@export var block_sector: float = 3.14


func check_transition(input_: InputPackage) -> PLVerdict:
	if not player.is_on_floor():
		return PLVerdict.new(PS.midair)
	return best_next_state_from_input(input_)


# Overrides react_on_hit to handle blocking via stamina (and cuts regen while shielded)
func react_on_hit(hit: HitData):
	# get horizontal hit direction relative to player facing
	var weapon_position := hit.weapon.global_position
	var our_position := player.global_position
	our_position.y = weapon_position.y # ignore vertical difference
	var hit_direction := our_position.direction_to(weapon_position)
	var face_direction := player.basis.z

	# if hit comes from shielded side, block: pay stamina instead of health
	if face_direction.angle_to(hit_direction) < block_sector / 2:
		print(" ~~~ blocked a hit")
		# resources.pay_block_cost(hit.damage, block_coefficient)
		try_force_state("block_reaction")
	else:
		# unblocked hit: fall back to default reaction
		super.react_on_hit(hit)


# func update_resources(_delta: float):
# 	pass # normally would be some routine, but we only regenerate stamina now, so empty method

# func _animate():
# 	animator_set = "full_body_torso"
# 	print_.prefix("SKM", "block animate '" + animator_set + "' animation " + animation + "| settings_switch_time " + str(settings_switch_time))
# 	if animation_settings.current_animation == animator_set:
# 		torso_animator.play(animation, animation_blend_time)
# 		# animator_manager.play(animation, animation_blend_time)
# 	else:
# 		torso_animator.play(animation, 0)
# 		animator_manager.play(animation, 0)
# 	# animation_settings.play(animator_set, settings_switch_time)
