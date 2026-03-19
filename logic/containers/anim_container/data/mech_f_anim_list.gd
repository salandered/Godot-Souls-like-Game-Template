class_name MFA
extends BaseCharAnimList


## idle
const idle_l: StringName = "idle_l"
const idle_r: StringName = "idle_r"

## attack
const attack_lr: StringName = "attack_lr"
const attack_rl: StringName = "attack_rl"
const attack_up: StringName = "attack_up"
const attack_down: StringName = "attack_down"
const attack_stab: StringName = "attack_stab"
const attack_lr_power: StringName = "attack_lr_power"
const attack_rl_power: StringName = "attack_rl_power"
const attack_stab_power: StringName = "attack_stab_power"

## other


func get_list_of_animations() -> Array[AnimationData]:
	return _list_of_animations


var _list_of_animations: Array[AnimationData] = [
	## idle
	AnimationData.new(idle_l),
	AnimationData.new(idle_r),
	## attack
	AnimationData.new(attack_lr, 1.2),
	AnimationData.new(attack_rl, 1.2),
	AnimationData.new(attack_up, 0.9),
	AnimationData.new(attack_down, 0.9),
	AnimationData.new(attack_stab, 1.0),
	AnimationData.new(attack_lr_power, 1.3),
	AnimationData.new(attack_rl_power, 1.3),
	AnimationData.new(attack_stab_power, 1.1),
]
