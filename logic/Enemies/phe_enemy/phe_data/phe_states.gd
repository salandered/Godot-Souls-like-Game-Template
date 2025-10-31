extends RefCounted
class_name PHEState

const _TOP = "_TOP"
const life := "life"

const still_life_phase := "still_life_phase"
const combat_loco := "combat_loco"
const combat_phase := "combat_phase"
const attack_club_series := "attack_club_series🏏"
const attack_pick_single := "attack_pick_single"

const phase_2 := "phase_2"


class Leaf:
	const sleep := "sleep"
	const awaken := "awaken"
	const death := "death"

	## loco
	const combat_idle := "combat_idle"
	const orbit := "orbit"
	const slow_pursue := "slow_pursue"
	const pursue := "pursue"
	const dodge := "dodge"

	## attack
	const scare_off := "scare_off✷"
	const gap_closer_attack := "gap_closer_attack⁀➴"
	const club_part_1 := "club_part_1🏏"
	const club_part_2 := "club_part_2🏏"
	const club_part_3_4 := "club_part_3_4🏏"
	const fancy_attack := "fancy_attack"

	const attack_360_high := "attack_360_high"
	const attack_360_low := "attack_360_low"
	const attack_up := "attack_up"
	const attack_down := "attack_down"

	const phase_switch := "phase_switch"
