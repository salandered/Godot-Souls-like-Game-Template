extends BasePlayerState

var hit_damage = 100


func update(input_: InputPackage, delta):
	if curr_state_action.works_between(2.2, 3.6): # turn into parameter
		get_player().model.active_weapon.set_is_attacking(true)
	else:
		get_player().model.active_weapon.set_is_attacking(false)


# func pack_hit_data(weapon: BaseWeapon) -> HitData:
# 	var hit = HitData.new()
# 	hit.damage = hit_damage
# 	hit.state_anim = current_action.anim_id
# 	hit.is_parryable = current_action.is_parryable()
# 	hit.weapon = player.model.active_weapon
# 	return hit


func on_exit_state() -> void:
	get_player().model.active_weapon.hitbox_ignore_list.clear()
	get_player().model.active_weapon.set_is_attacking(false)
