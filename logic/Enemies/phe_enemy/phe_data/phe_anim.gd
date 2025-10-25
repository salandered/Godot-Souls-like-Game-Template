extends RefCounted
class_name PHEA


class _lib:
	const _legacy = "legacy" + "/"
	const _axe_all = "axe" + "/"
	const _axe_pl = "axe-from-player" + "/"
	const _not_axe = "BG-not-axe" + "/"


class unsorted:
	const big_react := _lib._axe_all + "big react"
	const small_react := _lib._axe_all + "react small"
	const sleep := _lib._not_axe + "sleep"
	const awaken := _lib._not_axe + "awakening"
	const death := _lib._not_axe + "death"
	

class loco:
	const combat_idle := _lib._axe_pl + "L-combat-idle"
	const walk_forward := _lib._axe_all + "unarmed walk forward"
	const strafe_right := _lib._axe_all + "strafe R"
	const strafe_left := _lib._axe_all + "strafe L"
	const run_forward := _lib._axe_all + "unarmed run forward" # OR combat run forward


class attack:
	const scare_off := _lib._not_axe + "scare-off" # OR axe scare off
	const gap_closer := _lib._axe_all + "RM gap closer" # OR wo attack: unarmed jump running
	## too high but one is ok
	const attack_360_high := _lib._axe_all + "at 360 finite"
	const attack_360_low := _lib._axe_all + "at 360 finite lower"

	const attack_up := _lib._axe_all + "at low up finite"
	const attack_down := _lib._axe_all + "at downward finite"
	
	const club_part_1 := _lib._not_axe + "ADD One Hand Club part1"
	const club_part_2 := _lib._not_axe + "ADD One Hand Club Combo part2"
	const club_part_3_4 := _lib._not_axe + "ADD One Hand Club Combo part3"
	
	const fancy_attack := _lib._not_axe + "ADD great sword jump attack"

	## later: too high
	# const axe_slice_1 := _lib._axe_all + "at RL 1 finite"
	# const axe_slice_2 := _lib._axe_all + "slash_4"
	# const combo_slices12 := _lib._axe_all + "combo 2 at"
	# etc from axe

class legacy:
	const phase_switch := _lib._legacy + "phase_switch"
	const gapclose_2 := _lib._legacy + "gapclose_2"


var list_of_animations: Array[AnimationData] = [
	## unsorted
	AnimationData.new(unsorted.big_react),
	AnimationData.new(unsorted.small_react),
	AnimationData.new(unsorted.sleep),
	AnimationData.new(unsorted.awaken),
	AnimationData.new(unsorted.death),
	
	## loco
	AnimationData.new(loco.combat_idle),
	AnimationData.new(loco.walk_forward),
	AnimationData.new(loco.strafe_right),
	AnimationData.new(loco.strafe_left),
	AnimationData.new(loco.run_forward),

	## attacks
	AnimationData.new(attack.scare_off),
	AnimationData.new(attack.gap_closer),
	AnimationData.new(attack.attack_360_high),
	AnimationData.new(attack.attack_360_low),
	AnimationData.new(attack.attack_up),
	AnimationData.new(attack.attack_down),
	AnimationData.new(attack.club_part_1, 0.6),
	AnimationData.new(attack.club_part_2, 0.5),
	AnimationData.new(attack.club_part_3_4, 0.5),
	AnimationData.new(attack.fancy_attack),
	

	## legacy
	AnimationData.new(legacy.phase_switch),
	AnimationData.new(legacy.gapclose_2),
	
]
