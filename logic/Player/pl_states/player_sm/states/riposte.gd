extends PlayerState

var hit_damage = 100


func update(_input: InputPackage, _delta):
	if current_action.works_between(2.2, 3.6): # later will be turned into a backend animation parameter
		player.model.active_weapon.is_attacking = true
	else:
		player.model.active_weapon.is_attacking = false


func pack_hit_data(weapon: BaseWeapon) -> HitData:
	var hit = HitData.new()
	hit.damage = hit_damage
	hit.hit_state_animation = current_action.animation
	hit.is_parryable = current_action.is_parryable()
	hit.weapon = player.model.active_weapon
	return hit


func on_exit_state():
	player.model.active_weapon.hitbox_ignore_list.clear()
	player.model.active_weapon.is_attacking = false
