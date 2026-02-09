@tool
class_name PlayerConfig
extends AnimatableEntityConfig


static var air_states: Array[String] = [PS.dodge, PS.jump_sprint, PS.jump_sprint, PS.midair]

## may be not fully invincible, but some part of them
static var invincible_states: Array[String] = [PS.dodge, PS.death, PS.thrown, PS.pushback]

static var attack_states: Array[String] = [
	PS.axe_slice_1, PS.axe_slice_2, PS.axe_slice_3,
	PS.stab_attack_1, PS.stab_attack_2,
	PS.sword_slash_1, PS.sword_slash_2, PS.sword_slash_3
]
