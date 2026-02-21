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
	const deaths = "deaths" + "/"


## prefix AA- means we use it. Helps to identify in animation player list


## one time
const death_b: StringName = _lib.deaths + "Falling B Death" # "Standing Death F"


# NOTE: usual loco and combat loco are mixed for now
class loco:
	const idle: StringName = _lib.all_axe + "AA-L-combat-idle" # _EP_p1 + "EP-p1-O-idle-combat" # _ss_loco + "B-idle"
	# const idle : StringName = _lib.testing + "Idle"
	# const combat_walk_start : StringName = _lib._SWS_loco_p2 + "SWSlp2-O-walk-start" # _ss_loco + "C-walk"
	const idle_to_sprint: StringName = _lib.start_end_v2 + "AA-L RM Idle To Sprint" # : StringName =_SWS_loco_p2 + "SWSlp2-O-sprint-start" #
	const sprint_to_idle: StringName = _lib.start_end_v2 + "AA-L RM run to stop" # : StringName =_SWS_loco_p2 + "SWSlp2-O-sprint-start" #
	const run: StringName = _lib._run + "AA-B-Jog-Forward-v2" # "SWSl-O-run-F" # _run + "B-Jog-Forward-v2"
	const sprint: StringName = _lib._run + "AA-B-Fast-Run-v2" # _SWS_loco + "SWSl-O-sptrint-F" # _run + "B-Fast-Run-v2"

	const turn_180_L: StringName = _lib._ss_loco + "AA-RMR ss 180 turn L"
	const turn_180_R: StringName = _lib._ss_loco + "AA-RMR ss 180 turn R"

	# const turn_90_to_run_L : StringName = _lib._ss_loco + "RMR Turn 90 To Run L"
	# const turn_90_to_run_R : StringName = _lib._ss_loco + "RMR Turn 90 To Run R"

	const fast_turn_180_L: StringName = _lib._ss_loco + "AA-RMR ss 180 fast turn L"
	const fast_turn_180_R: StringName = _lib._ss_loco + "AA-RMR ss 180 fast turn R"

class strafe:
	# const combat_walk_f : StringName = _lib._strafe + "walk f2" # _EP_p1 + "EP-p1-O-Walk-Combat-B" #
	# const combat_walk_b : StringName = _lib._strafe + "walk b2" # _EP_p1 + "EP-p1-O-Walk-Combat-B" #
	const combat_run_f: StringName = _lib.all_axe + "AA-L-combat-run"
	const combat_run_b: StringName = _lib.all_axe + "AA-L-combat-run-B" # "C-run-back"

	## NOTE: use commented anims for slow strafing 
	const strafe_R: StringName = _lib._strafe + "AA-B-strafe-run-R-strange" # "A-strafe-R" # "SWSl-O-run-R-blended"
	const strafe_L: StringName = _lib._strafe + "AA-B-strafe-run-L" # "A-strafe-L" # "SWSl-O-run-L-blended"

class dodge:
	const dodge_L: StringName = _lib._dodge + "AA-Standing-Dodge-L"
	const dodge_R: StringName = _lib._dodge + "AA-Standing-Dodge-R"
	const dodge_F: StringName = _lib._dodge + "AA-standing-dodge-F"
	const dodge_B: StringName = _lib._dodge + "AA-Standing-Dodge-B"

	const dodge_L_head: StringName = _lib._dodge + "AA-B-Dodging-head-L"
	const dodge_R_head: StringName = _lib._dodge + "AA-B-Dodging-head-R"

class air:
	# todo jump-roll A-Quick-Roll-To-Run
	const midair: StringName = _lib.jump_v4 + "AA-Midair-Hok" # TODO: change rotation of anim
	# const jump_run : StringName = _lib.axe_rm_jump + "LL-jump-running_start" # _jump_up_land_HPG + "B-UP-ss-jump-run-RP" # _OS_loco + "OSl-jump-place-start"
	# const landing_run : StringName = _lib.axe_rm_jump + "LL-jump-running_start" # _jump_up_land_HPG + "B-LAND-ss-jump-run-RP" # _OS_loco + "OSl-jump-place-end"
	const jump_sprint: StringName = _lib.jump_v4 + "AA-RM-Run-Jump-all"
	const landing_sprint: StringName = _lib.jump_v4 + "AA-RM-Run-Jump-ver-land"
	# const hard_fall : StringName = # _jump_up_land_HPG + "C-fall-HW-hard-land-idle-trim-pin"

class attack:
	const axe_slice_1: StringName = _lib.all_axe + "AA-aIP-attack-slice-RL-1" # _ff + "axe_slice_1" # _SWS_combo + "SWSc-O-combo-1-all" #
	const axe_slice_2: StringName = _lib.all_axe + "AA-aIP-attack-slice-LR-cut-2" # "Ex-attack-second-slice-cut" # _SWS_combo + "SWSc-O-combo-2-slash-2" # _ff + "axe_slice_2"
	const axe_slice_3: StringName = _lib.all_axe + "AA-aRM-attack-roll-low-3"
	
	const sword_slash_1: StringName = _lib._ss_attack + "AA-B-slash-R-L-RM-1"
	const sword_slash_2: StringName = _lib._ss_attack + "AA-B-slash-L-R-RM-2"
	const sword_slash_3: StringName = _lib._ss_attack + "AA-D-slash3-combo-part-3"
	
	const stab_attack_1: StringName = _lib._SWS_att + "AA-SWS-O-bit-stab"
	const stab_attack_2: StringName = _lib._SWS_att + "AA-SWS-O-stab"
	

class react:
	# const hit_reaction : StringName = _lib._ss_attack + "AA-C-body-impact" # _ss_attack + "C-leg-kick" # shield_throw # _ss_attack + "C-body-impact"
	const head_B_large: StringName = _lib._ss_attack + "AA-B-head-impact"
	const react_from_L: StringName = _lib.all_axe + "AA-react large from left"
	const react_from_R: StringName = _lib.all_axe + "AA-react large from right"
	const react_gut: StringName = _lib.all_axe + "AA-react large gut"
	# const dodge_F_hit = _lib.testing + "AA-OS-hit-react-forward"
	# const hit_pushback_rm = _lib.testing + "AA-OS-hit-react-back"
	const hit_push_b_rm: StringName = _lib._fall_stand_up + "AA-hit push B rm"
	const react_dodge_B: StringName = _lib._dodge + "AA-E-Dodging-Back-afraid-funny-hands"


class fall_stand_up:
	# const stand_up_to_r_rm : StringName = _lib._fall_stand_up + "Stand Up to R RM"
	# const cool_stand_up : StringName = _lib._fall_stand_up + "cool stand-up"
	# const cool_stand_up_rm : StringName = _lib._fall_stand_up + "cool stand-up RM"
	# const fall_b_funny_rm : StringName = _lib._fall_stand_up + "fall B funny RM"
	# const fall_b_w_roll_rm_y : StringName = _lib._fall_stand_up + "fall B w roll RM y"
	# const fall_b_w_roll_rm_yx_jic : StringName = _lib._fall_stand_up + "fall B w roll RM yx (jic)"
	# const slip_fall_f_rm_y : StringName = _lib._fall_stand_up + "slip fall F RM y"
	# const stand_up_vertical_adj : StringName = _lib._fall_stand_up + "stand up (vertical adj)"
	# const stand_up_hstrange : StringName = _lib._fall_stand_up + "stand up Hstrange"
	# const stand_up_simple : StringName = _lib._fall_stand_up + "stand up simple"
	const thrown_l_rm: StringName = _lib._fall_stand_up + "AA-soccer throw L RM"
	const thrown_r_rm: StringName = _lib._fall_stand_up + "AA-soccer throw R RM"
	const thrown_l_small_rm: StringName = _lib._fall_stand_up + "AA-soccer fall L small"
	const thrown_r_small_rm: StringName = _lib._fall_stand_up + "AA-soccer fall R small"
	const cool_thrown_l_rm: StringName = _lib._fall_stand_up + "Corkscrew Evade L"
	const cool_thrown_r_rm: StringName = _lib._fall_stand_up + "Corkscrew Evade R"


class equip:
	const equip: StringName = _lib.testing + "EP-p1-O-idle-equip"
	const wave: StringName = _lib.testing + "Waving_hands_ok"

# later
# const roll : StringName = _lib.jump_v4 + "RM-Sprint-to-Roll" # _OS_fight + "OS-evade-forward" # todo
# const withdraw : StringName = air.midair # _jump + "C-fall-HW" # TODO
# const block_forward : StringName = _lib._ss_attack + "C-block-forward" # _OS_fight + "OS-block-left" # _ss_attack + "C-block-forward"
# const block_to_idle : StringName = _ss_attack + "C-block-to-idle"


# const parry : StringName = air.midair # _ff + "parry"
# const parried : StringName = air.midair # _ff + "parried"
# const riposte_attack : StringName = attack.axe_slice_1
