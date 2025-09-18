extends BaseHSMEState


@export var hit_damage: float = 30


func check_transition(_delta) -> VerdictHSM:
	return VerdictHSM.new()


func pack_hit_data(weapon: BaseWeapon) -> HitData:
	var hit = HitData.new()
	hit.damage = hit_damage
	hit.hit_state_animation = animation
	# hit.is_parryable = is_parryable()
	hit.weapon = weapon
	return hit


func update(_delta):
	manage_weapons()


func on_exit():
	deactivate_weapons()
