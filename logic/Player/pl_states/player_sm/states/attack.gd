extends PlayerState
class_name AttackState

## TODO: should be less then attack DURATION for achieving its effect
@export var RELEASES_PRIORITY: float # 1.2

@export_group("enemy communication")
@export var attack_radius: float # approximate and static for now

@export var extremum_timing: float
@export var posttracking_radius: float


var hit_damage = 10


func on_enter_state(input_: InputPackage):
	combat.set_hit_data(hit_damage, current_action.anim.anim_id)


func check_transition(input_: InputPackage) -> PLVerdict:
	if not player.is_on_floor():
		return PLVerdict.new(PS.midair)

	var verdict = best_next_state_from_input(input_)
	
	if current_action.passed_marker(Marker.Name.ALLOWS_SWITCH):
		# this reads as: if we are at the end of attack anim (> ALLOWS_SWITCH but < DURATION)
		# and there is a best input which is not idle, we can switch to it. 
		# => we dont wait for the exact end of the current anim
		if verdict.next_state != PS.idle:
			print_.psm_check_trans(state_name, pp.s("passed marker", Marker.Name.ALLOWS_SWITCH, "=> chose best non idle input"))
			return verdict

	if current_action.time_remaining() <= 0.0:
		print_.psm_check_trans(state_name, pp.s("time_remaining < 0.0 => choosing best input"))
		return verdict
	
	return PLVerdict.new("")
	
	
func update(input_: InputPackage, delta):
	if not depends_on_legs and current_action.tracks_input_vector():
		current_action.pm().rotate_with_input_vector_simple(input_, delta)
	current_action.pm().move_with_root(delta)
	combat.update_is_attacking(current_action.weapon_hurts())


func on_exit_state():
	combat.reset_active_weapon()


## what for?
func time_til_priority_release() -> float:
	return RELEASES_PRIORITY - current_action.time_spent()
