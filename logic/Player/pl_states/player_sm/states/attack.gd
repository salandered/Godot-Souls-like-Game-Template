extends PlayerState
class_name AttackState

## TODO: should be less then attack DURATION for achiving its effect
@export var RELEASES_PRIORITY: float # 1.2

@export_group("enemy communication")
# in reality is a dynamic parameter, but for now I just return the maximum attacking radius
# when looking forward, ie root bone Z delta 
# plus the length of the weapon in "the extremum pose"
# (eye-measured in animator's interface)
@export var attack_radius: float

@export var extremum_timing: float
@export var posttracking_radius: float


var hit_damage = 10 # will be a function of player stats in the future

func check_transition(input: InputPackage) -> PLVerdict:
	var best_input = best_input_that_can_be_paid(input)
	if current_action.works_longer_than(current_action.DURATION):
		return best_input
	# TODO: works not as intended wo idle state !! also RELEASES_PRIORITY should be dependent on current_action.DURATION! and sometimes turned off
	# if current_action.works_longer_than(RELEASES_PRIORITY):
	# 	print_.psm_check_trans(state_name, "works longer than " + str(RELEASES_PRIORITY) + " => choosing best input")
	# 	# this reads as: if we are at the end of attack anim (> RELEASES_PRIORITY but < DURATION) 
	# 	# and there is a best input which is not idle, we can switch to it. so we run or make new attack not waiting for exact end of the current attack
	# 	# but if best is idle, we better wait for the end (and then blend to idle because what else to do)
	# 	if best_input.next_state != "idle":
	# 		return best_input
	return PLVerdict.new("")
	
	
func update(_input: InputPackage, delta):
	# move_with_root(delta)
	player.model.active_weapon.is_attacking = current_action.weapon_hurts()

func move_with_root(delta: float) -> void:
	var delta_pos := player_sm.full_body_animator.get_root_velocity()
	player.velocity = player.get_quaternion() * delta_pos

	if not player.is_on_floor():
		player.velocity.y -= u.gravity * delta
		forced_state = PS.midair


func pack_hit_data(weapon: BaseWeapon) -> HitData:
	var hit = HitData.new()
	hit.damage = hit_damage
	hit.hit_state_animation = current_action.anim_name
	hit.is_parryable = current_action.is_parryable()
	hit.weapon = player.model.active_weapon
	return hit


func on_exit_state():
	player.model.active_weapon.hitbox_ignore_list.clear()
	player.model.active_weapon.is_attacking = false


## what for?
func time_til_priority_release() -> float:
	return RELEASES_PRIORITY - current_action.get_progress()
