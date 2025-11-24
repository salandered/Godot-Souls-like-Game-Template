extends RefCounted
## Stands for Phase Enemy State
## 'Phase' means HSM state (that happened)
class_name PHES

const _TOP = "_TOP"
const life := "life"

const still_life_phase := "still_life_phase"
const combat_phase := "combat_phase"
const death_phase := "death_phase"
const combat_loco := "combat_loco"
const combat_attacking := "combat_attacking"
const attack_club_series := "attack_club_series🏏"
const attack_pick_single := "attack_pick_single"
const attack_360_series := "attack_360_series"
const dodge_back_series := "dodge_back_series"
const dodge_playful := "dodge_playful"
const attack_from_dodge_b := "attack_from_dodge_b"
const attack_with_dodge_f := "attack_with_dodge_f"


class Leaf:
	const sleep := "sleep"
	const awaken := "awaken"
	const death := "death"
	const phase_switch := "phase_switch🕹️"

	## loco
	const combat_idle := "combat_idle"
	const orbit := "orbit"
	const pursue := "pursue"
	const dodge_B := "dodge_B"
	const dodge_F := "dodge_F"
	const dodge_L := "dodge_L"
	const dodge_R := "dodge_R"
	const jump_towards := "jump_towards"

	## attack
	const scare_off := "scare_off✷"
	const club_part_1 := "club_part_1🏏"
	const club_part_2 := "club_part_2🏏"
	const club_part_3_4 := "club_part_3_4🏏"
	
	const gap_closer := "gap_closer⁀➴"
	const sword_slide := "sword_slide"
	const power_up := "power_up"
	const stab_low := "stab_low"

	const attack_360_high := "attack_360_high"
	const attack_360_low := "attack_360_low"
	const attack_up := "attack_up"
	const attack_down := "attack_down"

	## react
	const pushback := "pushback"