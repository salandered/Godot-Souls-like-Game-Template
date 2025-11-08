extends RefCounted
class_name A

class _lib:
	const _jump = "jumps-v2-LIB" + "/"
	const jump_v4 = "jump-v4-LIB" + "/"
	const _jump_up_land_ = "jump-up-land-v3-LIB" + "/"
	const _run = "run-v5-LIB" + "/"
	const _ss_loco = "ss-loco-LIB" + "/"
	const _strafe = "strafe-v2-LIB" + "/"
	const _dodge = "dodge-v1-LIB" + "/"
	const _ss_attack = "ss-attack-LIB" + "/"

	const _OS_loco = "OS-loco-v2-LIB" + "/"
	const _OS_fight = "OS-fight-LIB" + "/"
	const _SWS_combo = "SWS-combo-LIB" + "/"
	const _SWS_att = "SWS-att-LIB" + "/"
	const _SWS_loco = "SWS-loco-v2-LIB" + "/"
	const _SWS_loco_p2 = "SWS-loco-p2-LIB" + "/"
	const _EP_p1 = "EP-p1-LIB" + "/"
	const _EP_p2 = "EP-p2-LIB" + "/"

	const all_axe = "all-axe-LIB" + "/"
	const testing = "testing" + "/"
	const axe_rm_jump = "axe-rm-jumps-LIB" + "/"

	const _bit_of_glue = "bit-of-glue-v1-LIB" + "/"
	const start_end_v2 = "start-end-v2" + "/"
	const _fall_stand_up = "fall-stand-up" + "/"


## one time
const death := air.midair # _ss_loco + "C-death-2"


# NOTE: usual loco and combat loco are mixed for now
class loco:
	const idle := _lib.all_axe + "L-combat-idle" # _EP_p1 + "EP-p1-O-idle-combat" # _ss_loco + "B-idle"
	# const combat_walk_start := _lib._SWS_loco_p2 + "SWSlp2-O-walk-start" # _ss_loco + "C-walk"
	const idle_to_sprint := _lib.start_end_v2 + "L RM Idle To Sprint" # :=_SWS_loco_p2 + "SWSlp2-O-sprint-start" #
	const sprint_to_idle := _lib.start_end_v2 + "L RM run to stop" # :=_SWS_loco_p2 + "SWSlp2-O-sprint-start" #
	const run := _lib._run + "B-Jog-Forward-v2" # "SWSl-O-run-F" # _run + "B-Jog-Forward-v2"
	const sprint := _lib._run + "B-Fast-Run-v2" # _SWS_loco + "SWSl-O-sptrint-F" # _run + "B-Fast-Run-v2"

	const turn_180_R := _lib._ss_loco + "RMR ss 180 turn R"
	const turn_180_L := _lib._ss_loco + "RMR ss 180 turn L"

	# const turn_90_to_run_R := _lib._ss_loco + "RMR Turn 90 To Run R"
	# const turn_90_to_run_L := _lib._ss_loco + "RMR Turn 90 To Run L"

	const fast_turn_180_R := _lib._ss_loco + "RMR ss 180 fast turn R"
	const fast_turn_180_L := _lib._ss_loco + "RMR ss 180 fast turn L"

class strafe:
	# const combat_walk_f := _lib._strafe + "walk f2" # _EP_p1 + "EP-p1-O-Walk-Combat-B" #
	# const combat_walk_b := _lib._strafe + "walk b2" # _EP_p1 + "EP-p1-O-Walk-Combat-B" #
	const combat_run_f := _lib.all_axe + "L-combat-run"
	const combat_run_b := _lib.all_axe + "L-combat-run-B" # "C-run-back"

	## NOTE: use commented anims for slow strafing 
	const strafe_L := _lib._strafe + "B-strafe-run-L" # "A-strafe-L" # "SWSl-O-run-L-blended"
	const strafe_R := _lib._strafe + "B-strafe-run-R-strange" # "A-strafe-R" # "SWSl-O-run-R-blended"

class dodge:
	const dodge_R := _lib._dodge + "A-Standing-Dodge-R"
	const dodge_L := _lib._dodge + "A-Standing-Dodge-L"
	const dodge_F := _lib._dodge + "A-standing-dodge-F"
	const dodge_B := _lib._dodge + "A-Standing-Dodge-B"

	const dodge_R_head := _lib._dodge + "B-Dodging-head-R"
	const dodge_L_head := _lib._dodge + "B-Dodging-head-L"

class air:
	# todo jump-roll A-Quick-Roll-To-Run
	const midair := _lib.jump_v4 + "Midair-Hok" # TODO: change rotation of anim
	# const jump_run := _lib.axe_rm_jump + "LL-jump-running_start" # _jump_up_land_HPG + "B-UP-ss-jump-run-RP" # _OS_loco + "OSl-jump-place-start"
	# const landing_run := _lib.axe_rm_jump + "LL-jump-running_start" # _jump_up_land_HPG + "B-LAND-ss-jump-run-RP" # _OS_loco + "OSl-jump-place-end"
	const jump_sprint := _lib.jump_v4 + "RM-Run-Jump-all"
	const landing_sprint := _lib.jump_v4 + "RM-Run-Jump-ver-land"
	# const hard_fall := # _jump_up_land_HPG + "C-fall-HW-hard-land-idle-trim-pin"

class attack:
	const axe_slice_1 := _lib.all_axe + "aIP-attack-slice-RL" # _ff + "axe_slice_1" # _SWS_combo + "SWSc-O-combo-1-all" #
	const axe_slice_2 := _lib.all_axe + "aIP-attack-slice-LR-cut" # "Ex-attack-second-slice-cut" # _SWS_combo + "SWSc-O-combo-2-slash-2" # _ff + "axe_slice_2"
	const attack_from_run := _lib._SWS_att + "SWS-O-bit-stab"
	const attack_from_dodge := _lib._SWS_att + "SWS-O-stab"
	
	const sword_slash_1 := _lib._ss_attack + "B-slash-R-L-RM-1"
	const sword_slash_2 := _lib._ss_attack + "B-slash-L-R-RM-2"

class react:
	const block_reaction := air.midair # _ff + "block_reaction" # _OS_fight + "OS-hit-react" # _ff + "block_reaction"
	const hit_reaction := _lib._ss_attack + "C-body-impact" # _ss_attack + "C-leg-kick" # shield_throw # _ss_attack + "C-body-impact"
	const head_B_large = _lib._ss_attack + "B-head-impact"
	const react_from_R = _lib.all_axe + "react large from right"
	const react_from_L = _lib.all_axe + "react large from left"
	const react_gut = _lib.all_axe + "react large gut"
	const dodge_F_hit = _lib.testing + "OS-hit-react-forward"
	const hit_B_large_rm = _lib.testing + "OS-hit-react-back"
	const hit_push_b_rm := _lib._fall_stand_up + "hit push B rm"


class fall_stand_up:
	const stand_up_to_r_rm := _lib._fall_stand_up + "Stand Up to R RM"
	const cool_stand_up := _lib._fall_stand_up + "cool stand-up"
	const cool_stand_up_rm := _lib._fall_stand_up + "cool stand-up RM"
	const fall_b_funny_rm := _lib._fall_stand_up + "fall B funny RM"
	const fall_b_w_roll_rm_y := _lib._fall_stand_up + "fall B w roll RM y"
	const fall_b_w_roll_rm_yx_jic := _lib._fall_stand_up + "fall B w roll RM yx (jic)"
	const slip_fall_f_rm_y := _lib._fall_stand_up + "slip fall F RM y"
	const stand_up_vertical_adj := _lib._fall_stand_up + "stand up (vertical adj)"
	const stand_up_hstrange := _lib._fall_stand_up + "stand up Hstrange"
	const stand_up_simple := _lib._fall_stand_up + "stand up simple"
	const thrown_r_rm := _lib._fall_stand_up + "soccer throw R RM"
	const thrown_l_rm := _lib._fall_stand_up + "soccer throw L RM"
	const thrown_r_small_rm := _lib._fall_stand_up + "soccer fall R small"
	const thrown_l_small_rm := _lib._fall_stand_up + "soccer fall L small"


# later
const roll := _lib.jump_v4 + "RM-Sprint-to-Roll" # _OS_fight + "OS-evade-forward" # todo
const withdraw := air.midair # _jump + "C-fall-HW" # TODO
const block_forward := _lib._ss_attack + "C-block-forward" # _OS_fight + "OS-block-left" # _ss_attack + "C-block-forward"
# const block_to_idle := _ss_attack + "C-block-to-idle"

const pushback := air.midair # todo
const staggered := air.midair # _ss_attack + "B-head-impact"

const parry := air.midair # _ff + "parry"
const parried := air.midair # _ff + "parried"
const riposte_attack := attack.axe_slice_1

const shield_throw := air.midair # _ff + "shield_throw"
const shield_throw_reload := air.midair # _ff + "shield_throw_reload"
