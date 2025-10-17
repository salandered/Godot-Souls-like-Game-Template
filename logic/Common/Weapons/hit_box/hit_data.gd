extends Resource
class_name HitData

# var is_parryable: bool
var damage: float
var state_anim: String
var weapon: BaseWeapon
# var effects: Dictionary


func initialise(
	# is_parryable_: bool = false,
	damage_: float,
	state_anim_: String,
	weapon_: BaseWeapon,
	# effects_: Dictionary = {}
) -> void:
	# is_parryable = is_parryable_
	damage = damage_
	state_anim = state_anim_
	weapon = weapon_
	# effects = effects_

func _to_string() -> String:
	return pp.s("HitData: dmg", damage, "state_anim", state_anim, "weapon", weapon)
