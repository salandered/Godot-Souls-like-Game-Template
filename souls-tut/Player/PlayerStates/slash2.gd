extends BasePlayerState


const TRANSITION_TIMING = 0.65
const COMBO_TIMING = 0.6

var hit_damage = 15

func _ready():
	animation = "slash_2" # "slash_1"
	backend_animation = animation + "_params"
	state_name = PlayerState.slash_1

func default_lifecycle(input: InputPackage):
	if works_longer_than(COMBO_TIMING) and has_queued_state:
		has_queued_state = false
		return queued_state
	elif works_longer_than(TRANSITION_TIMING):
		return best_input_that_can_be_paid(input)
	return "okay"


func update(_input: InputPackage, _delta: float):
	if works_between(0.25, 0.44):
		player.model.active_weapon.is_attacking = true
	else:
		player.model.active_weapon.is_attacking = false


func pack_hit_data(weapon: WeaponOh) -> HitData:
	var hit = HitData.new()
	hit.damage = hit_damage
	hit.hit_state_animation = animation
	hit.is_parryable = is_parryable()
	hit.weapon = player.model.active_weapon
	return hit


func on_exit_state():
	player.model.active_weapon.hitbox_ignore_list.clear()
	player.model.active_weapon.is_attacking = false
