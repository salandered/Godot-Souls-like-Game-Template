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

func check_transition(input: InputPackage) -> String:
	var best_input = best_input_that_can_be_paid(input)
	if current_action.works_longer_than(RELEASES_PRIORITY):
		# this reads as: if we are at the end of attack anim (> RELEASES_PRIORITY but < DURATION) 
		# and there is a best input which is not idle, we can switch to it. so we run or make new attack not waiting for exact end of the current attack
		# but if best is idle, we better wait for the end (and then blend to idle because what else to do)
		if current_action.works_longer_than(current_action.DURATION) or best_input != "idle":
			return best_input
	return "okay"
	
	
func update(_input: InputPackage, delta):
	root_movement(delta)
	player.model.active_weapon.is_attacking = current_action.right_weapon_hurts()


func root_movement(delta: float):
	var delta_pos = current_action.get_root_position_delta(delta)
	delta_pos.y = 0
	player.velocity = player.get_quaternion() * delta_pos / delta
	if not player.is_on_floor():
		player.velocity.y -= gravity * delta
		has_forced_state = true
		forced_state = PS.midair

func pack_hit_data(weapon: WeaponOh) -> HitData:
	var hit = HitData.new()
	hit.damage = hit_damage
	hit.hit_state_animation = current_action.animation
	hit.is_parryable = current_action.is_parryable()
	hit.weapon = player.model.active_weapon
	return hit


func on_exit_state():
	player.model.active_weapon.hitbox_ignore_list.clear()
	player.model.active_weapon.is_attacking = false


## what for?
func time_til_priority_release() -> float:
	return RELEASES_PRIORITY - current_action.get_progress()
