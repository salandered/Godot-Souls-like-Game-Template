extends RefCounted
class_name PHEA


class _lib:
	const _legacy = "legacy" + "/"
	const _axe_all = "axe" + "/"
	const _axe_pl = "axe-from-player" + "/"
	const _not_axe = "BG-not-axe" + "/"
	const _some_from_pl = "some-from-pl" + "/"


const big_react := _lib._axe_all + "big react"
const small_react := _lib._axe_all + "react small"
const sleep := _lib._not_axe + "sleep"
const awaken := _lib._not_axe + "awakening"
const death := _lib._not_axe + "death"
const phase_switch := _lib._legacy + "phase_switch"
const phase_switch_loop := _lib._legacy + "phase_switch_loop"


class loco:
	## dodge
	const dodge_B := _lib._some_from_pl + "A-Standing-Dodge-B"
	const dodge_F := _lib._some_from_pl + "A-standing-dodge-F"
	const dodge_L := _lib._some_from_pl + "A-Standing-Dodge-L"
	const dodge_R := _lib._some_from_pl + "A-Standing-Dodge-R"

	## walk/run/idles
	const combat_idle := _lib._axe_pl + "L-combat-idle"
	const combat_idle_stupid := _lib._some_from_pl + "D-look-at-sword--stupid"
	const walk_forward := _lib._axe_pl + "L-walk"
	const combat_walk_forward := _lib._axe_pl + "L-combat-walk"
	const run_forward := _lib._axe_pl + "L-run"
	const combat_run_forward := _lib._axe_pl + "L-combat-run"

	const strafe_right := _lib._axe_pl + "L-combat-walk-R"
	const strafe_left := _lib._axe_pl + "L-combat-walk-L"
	const jump_towards := _lib._some_from_pl + "LL-jump-running"

class attack:
	const scare_off := _lib._not_axe + "scare-off" # OR axe scare off
	const gap_closer := _lib._not_axe + "ADD great sword jump attack"
	const power_gap_closer := _lib._axe_all + "RM gap closer" # OR wo attack: unarmed jump running
	## too high but one is ok
	const attack_360_high := _lib._axe_all + "at 360 finite"
	const attack_360_low := _lib._axe_all + "at 360 finite lower"

	const attack_up := _lib._axe_all + "at low up finite"
	const attack_down := _lib._axe_all + "at downward finite"
	
	const club_part_1 := _lib._not_axe + "ADD One Hand Club Combo part 1B"
	const club_part_2 := _lib._not_axe + "ADD One Hand Club Combo part2"
	const club_part_3_4 := _lib._not_axe + "ADD One Hand Club Combo part3"
	
	const sword_slide := _lib._not_axe + "ADD great sword slide attack"


var list_of_animations: Array[AnimationData] = [
	## unsorted
	AnimationData.new(big_react),
	AnimationData.new(small_react),
	AnimationData.new(sleep),
	AnimationData.new(phase_switch, 0.7),
	AnimationData.new(phase_switch_loop),
	AnimationData.new(awaken),
	AnimationData.new(death),
	
	## loco
	AnimationData.new(loco.dodge_B),
	AnimationData.new(loco.dodge_F),
	AnimationData.new(loco.dodge_R),
	AnimationData.new(loco.dodge_L),
	AnimationData.new(loco.combat_idle),
	AnimationData.new(loco.combat_idle_stupid),
	AnimationData.new(loco.walk_forward),
	AnimationData.new(loco.combat_walk_forward),
	AnimationData.new(loco.strafe_right),
	AnimationData.new(loco.strafe_left),
	AnimationData.new(loco.run_forward),
	AnimationData.new(loco.combat_run_forward),
	AnimationData.new(loco.jump_towards),

	## attacks
	AnimationData.new(attack.scare_off, 1.1),
	AnimationData.new(attack.power_gap_closer),
	AnimationData.new(attack.gap_closer),
	AnimationData.new(attack.attack_360_high),
	AnimationData.new(attack.attack_360_low),
	AnimationData.new(attack.attack_up),
	AnimationData.new(attack.attack_down),
	AnimationData.new(attack.club_part_1, 0.6),
	AnimationData.new(attack.club_part_2, 0.6),
	AnimationData.new(attack.club_part_3_4, 0.7),
	
	AnimationData.new(attack.sword_slide),
	
	## legacy

	
]
