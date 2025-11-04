extends PlayerAction
class_name BaseAttackAction


## DOCS
## important to manage weapon via player_sm.combat


## experimental usage with enemy communication
var attack_radius: float = 1.0


var hit_damage: float = 10


func on_enter_action(input_: InputPackage):
	player_sm.combat.set_hit_data_to_weapon(hit_damage, anim.anim_id)


func update(input_: InputPackage, delta):
	if tracks_input_vector():
		pm().rotate_with_input_vector(input_, delta, SpeedConfig.new(default_sp))
	pm().move_with_root(delta)

	player_sm.combat.update_is_attacking(weapon_hurts())


func on_exit_action():
	player_sm.combat.reset_active_weapon()
