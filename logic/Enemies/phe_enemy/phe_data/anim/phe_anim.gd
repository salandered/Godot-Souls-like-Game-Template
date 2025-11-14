extends RefCounted
class_name PHEA


class _lib:
	const _legacy = "legacy" + "/"
	const _axe_all = "axe" + "/"
	const _axe_pl = "axe-from-player" + "/"
	const _bg_not_axe = "BG-not-axe" + "/"
	const _some_from_pl = "some-from-pl" + "/"
	const _testing = "testing" + "/"


const sleep := _lib._bg_not_axe + "sleep"
const awaken := _lib._bg_not_axe + "awakening"
const death := _lib._bg_not_axe + "ss death"
const phase_switch := _lib._legacy + "phase_switch"
const phase_switch_loop := _lib._legacy + "phase_switch_loop"


class loco:
	const combat_idle := _lib._axe_pl + "L-combat-idle"
	const combat_idle_stupid := _lib._some_from_pl + "D-look-at-sword--stupid"
	const walk_forward := _lib._axe_pl + "L-walk"
	const combat_walk_forward := _lib._axe_pl + "L-combat-walk"
	const run_forward := _lib._axe_pl + "L-run"
	const combat_run_forward := _lib._axe_pl + "L-combat-run"
	const jump_towards := _lib._some_from_pl + "LL-jump-running"

class dodge:
	const dodge_B := _lib._some_from_pl + "A-Standing-Dodge-B"
	const dodge_F := _lib._some_from_pl + "A-standing-dodge-F"
	const dodge_L := _lib._some_from_pl + "A-Standing-Dodge-L"
	const dodge_R := _lib._some_from_pl + "A-Standing-Dodge-R"

class strafe:
	const strafe_right := _lib._axe_pl + "L-combat-walk-R"
	const strafe_left := _lib._axe_pl + "L-combat-walk-L"

class attack:
	const scare_off := _lib._bg_not_axe + "scare-off" # OR axe scare off
	# const gap_closer := _lib._bg_not_axe + "ADD great sword jump attack"
	const power_gap_closer := _lib._axe_all + "RM gap closer" # OR wo attack: unarmed jump running
	## too high but one is ok
	const attack_360_high := _lib._axe_all + "at 360 finite"
	const attack_360_low := _lib._axe_all + "at 360 finite lower"

	const attack_up := _lib._axe_all + "at low up finite"
	const attack_down := _lib._axe_all + "at downward finite"
	
	const club_part_1 := _lib._bg_not_axe + "ADD One Hand Club Combo part 1B"
	const club_part_2 := _lib._bg_not_axe + "ADD One Hand Club Combo part2"
	const club_part_3_4 := _lib._bg_not_axe + "ADD One Hand Club Combo part3"
	
	const sword_slide := _lib._bg_not_axe + "ADD great sword slide attack"
	const power_up := _lib._testing + "EP-p1-O-power-attack-up_2"
	const stab_low := _lib._testing + "OS-stab-3_2"


class react:
	const react_from_L := _lib._axe_pl + "react large from left"
	const react_from_R := _lib._axe_pl + "react large from right"
	const react_gut := _lib._axe_pl + "react large gut"
	const body_impact := _lib._some_from_pl + "C-body-impact"


# class fall_stand_up:
# 	const d_slip_b := _lib._fall_stand_up + "D slip B"
# 	const stand_up_to_r_rm := _lib._fall_stand_up + "Stand Up to R RM"
# 	const cool_stand_up := _lib._fall_stand_up + "cool stand-up"
# 	const cool_stand_up_rm := _lib._fall_stand_up + "cool stand-up RM"
# 	const fall_b_funny_rm := _lib._fall_stand_up + "fall B funny RM"
# 	const fall_b_w_roll_rm_y := _lib._fall_stand_up + "fall B w roll RM y"
# 	const fall_b_w_roll_rm_yx_jic := _lib._fall_stand_up + "fall B w roll RM yx (jic)"
# 	const hit_push_b_rm := _lib._fall_stand_up + "hit push B rm"
# 	const slip_fall_f_rm_xy := _lib._fall_stand_up + "slip fall F RM xy"
# 	const slip_fall_f_rm_y := _lib._fall_stand_up + "slip fall F RM y"
# 	const stand_up_vertical_adj := _lib._fall_stand_up + "stand up (vertical adj)"
# 	const stand_up_hstrange := _lib._fall_stand_up + "stand up Hstrange"
# 	const stand_up_simple := _lib._fall_stand_up + "stand up simple"
# 	const thrown_l_rm := _lib._fall_stand_up + "thrown L RM"
# 	const thrown_r_rm := _lib._fall_stand_up + "thrown R RM"


var list_of_animations: Array[AnimationData] = [
	AnimationData.new(sleep),
	AnimationData.new(phase_switch, 0.7),
	AnimationData.new(phase_switch_loop),
	AnimationData.new(awaken),
	AnimationData.new(death),

	AnimationData.new(react.react_from_L),
	AnimationData.new(react.react_from_R),
	AnimationData.new(react.react_gut),
	AnimationData.new(react.body_impact),
	
	## loco
	AnimationData.new(dodge.dodge_B),
	AnimationData.new(dodge.dodge_F),
	AnimationData.new(dodge.dodge_R),
	AnimationData.new(dodge.dodge_L),
	AnimationData.new(loco.combat_idle),
	AnimationData.new(loco.combat_idle_stupid),
	AnimationData.new(loco.walk_forward),
	AnimationData.new(loco.combat_walk_forward),
	AnimationData.new(strafe.strafe_right),
	AnimationData.new(strafe.strafe_left),
	AnimationData.new(loco.run_forward),
	AnimationData.new(loco.combat_run_forward),
	AnimationData.new(loco.jump_towards),

	## attacks
	AnimationData.new(attack.scare_off, 1.1),
	AnimationData.new(attack.power_gap_closer),
	# AnimationData.new(attack.gap_closer),
	AnimationData.new(attack.attack_360_high),
	AnimationData.new(attack.attack_360_low),
	AnimationData.new(attack.attack_up),
	AnimationData.new(attack.attack_down),
	AnimationData.new(attack.club_part_1, 0.6),
	AnimationData.new(attack.club_part_2, 0.6),
	AnimationData.new(attack.club_part_3_4, 0.7),
	
	AnimationData.new(attack.sword_slide),
	AnimationData.new(attack.power_up, 0.5),
	AnimationData.new(attack.stab_low, 0.5),
	
	## legacy

	
]
