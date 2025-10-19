extends PlayerAction
class_name BaseAttackAction


## ENEMY COMMUNICATION
var attack_radius: float # approximate and static for now
var extremum_timing: float
var posttracking_radius: float


var hit_damage = 10


func on_enter_action(input_: InputPackage):
	player_sm.combat.set_hit_data(hit_damage, anim.anim_id)


func update(input_: InputPackage, delta):
	if tracks_input_vector():
		pm().rotate_with_input_vector_simple(input_, delta)
	pm().move_with_root(delta)
	player_sm.combat.update_is_attacking(weapon_hurts())


func on_exit_action():
	player_sm.combat.reset_active_weapon()


# func time_til_priority_release() -> float:
# 	return RELEASES_PRIORITY - time_spent()
