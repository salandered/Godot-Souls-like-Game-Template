extends PlayerState
class_name AttackState

@export var RELEASES_PRIORITY: float

@export_group("enemy communication")
# in reality is a dynamic parameter, but for now I just return the maximum attacking radius
# when looking forward, ie root bone Z delta 
# plus the length of the weapon in "the extremum pose"
# (eye-measured in animator's interface)
@export var attack_radius: float
@export var extremum_timing: float
@export var posttracking_radius: float


var hit_damage = 10 # will be a function of player stats in the future

# this strange construction is here because our animation asset has a long tail transitioning to idle,
# think of it as of "custom perfect blending" to idle
# so after a certain point we want to release priority, but to anything except idle
func check_transition(input: InputPackage) -> String:
	var best_input = best_input_that_can_be_paid(input)
	if current_action.works_longer_than(RELEASES_PRIORITY):
		# todo: or best_input != "idle", what?
		if current_action.works_longer_than(_get_DURATION()) or best_input != "idle":
			return best_input
	return "okay"
	
	
func update(_input: InputPackage, delta):
	move_player(delta)
	player.model.active_weapon.is_attacking = current_action.right_weapon_hurts()


func move_player(delta: float):
	var delta_pos = current_action.get_root_position_delta(delta)
	delta_pos.y = 0
	player.velocity = player.get_quaternion() * delta_pos / delta
	if not player.is_on_floor():
		player.velocity.y -= ProjectSettings.get_setting("physics/3d/default_gravity") * delta
		has_forced_state = true
		forced_state = "midair"

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


func time_til_priority_release() -> float:
	return RELEASES_PRIORITY - current_action.get_progress()
