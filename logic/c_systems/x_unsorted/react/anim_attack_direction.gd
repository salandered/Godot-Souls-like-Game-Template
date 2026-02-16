class_name AnimAttackDirection
extends RefCounted


## todo: think of some smart system which detects, where we collided to know about direction
## 
## from the character point of view. Examples:
## slash from right to left - Dir is LEFT
## slash up - Dir is UP
static var any_attack_to_direction: Dictionary[String, AttackDirection.Dir] = {
	## phe
	PHEA.attack.attack_360_high: AttackDirection.Dir.RIGHT,
	PHEA.attack.attack_360_low: AttackDirection.Dir.RIGHT,
	PHEA.attack.attack_down: AttackDirection.Dir.DOWN,
	PHEA.attack.attack_up: AttackDirection.Dir.UP,
	PHEA.attack.club_part_1: AttackDirection.Dir.LEFT,
	PHEA.attack.club_part_2: AttackDirection.Dir.RIGHT,
	PHEA.attack.club_part_3_4: AttackDirection.Dir.LEFT,
	PHEA.attack.power_gap_closer: AttackDirection.Dir.DOWN,
	PHEA.attack.sword_slide: AttackDirection.Dir.LEFT,
	PHEA.attack.scare_off: AttackDirection.Dir.STAB,
	PHEA.attack.power_up: AttackDirection.Dir.UP,
	PHEA.attack.stab_low: AttackDirection.Dir.STAB,
	PHEA.phase_switch: AttackDirection.Dir.STAB,
	## sit
	SITSKA.sit_attack: AttackDirection.Dir.STAB,
	## mech
	MFA.attack_lr: AttackDirection.Dir.RIGHT,
	MFA.attack_rl: AttackDirection.Dir.LEFT,
	MFA.attack_up: AttackDirection.Dir.UP,
	MFA.attack_down: AttackDirection.Dir.DOWN,
	MFA.attack_stab: AttackDirection.Dir.STAB,
	MFA.attack_lr_power: AttackDirection.Dir.RIGHT,
	MFA.attack_rl_power: AttackDirection.Dir.LEFT,
	MFA.attack_stab_power: AttackDirection.Dir.STAB,
	## player
	A.attack.axe_slice_1: AttackDirection.Dir.LEFT,
	A.attack.axe_slice_2: AttackDirection.Dir.RIGHT,
	A.attack.axe_slice_3: AttackDirection.Dir.RIGHT,
	A.attack.stab_attack_1: AttackDirection.Dir.STAB,
	A.attack.stab_attack_2: AttackDirection.Dir.STAB,
	A.attack.sword_slash_1: AttackDirection.Dir.LEFT,
	A.attack.sword_slash_2: AttackDirection.Dir.UP, # technically should be RIGHT
	A.attack.sword_slash_3: AttackDirection.Dir.DOWN
	}


static func get_direction_from_anim(
	anim_id: String,
	default_value: AttackDirection.Dir = AttackDirection.Dir.RIGHT
) -> AttackDirection.Dir:
	var _r: AttackDirection.Dir = DictUtils.safe_get_dict_key(
		any_attack_to_direction,
		anim_id,
		default_value,
		WL.SILENT)
	return _r
