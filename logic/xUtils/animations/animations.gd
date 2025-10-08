extends RefCounted
class_name A

# LIBS

class lib:
	const _jump = "jumps-v2-LIB" + "/"
	const jump_v4 = "jump-v4-LIB" + "/"
	const _jump_up_land_ = "jump-up-land-v3-LIB" + "/"
	const _run = "run-v5-LIB" + "/"
	const _ss_loco = "ss-loco-LIB" + "/"
	const _strafe = "strafe-v2-LIB" + "/"
	const _ss_attack = "ss-attack-LIB" + "/"
	const _ff = "global-fair" + "/" # TODO: remove

	const _OS_loco = "OS-loco-v2-LIB" + "/"
	const _OS_fight = "OS-fight-LIB" + "/"
	const _SWS_combo = "SWS-combo-LIB" + "/"
	const _SWS_loco = "SWS-loco-v2-LIB" + "/"
	const _SWS_loco_p2 = "SWS-loco-p2-LIB" + "/"
	const _EP_p1 = "EP-p1-LIB" + "/"
	const _EP_p2 = "EP-p2-LIB" + "/"

	const all_axe = "all-axe-LIB" + "/"
	const axe_rm_jump = "axe-rm-jumps-LIB" + "/"

	const _bit_of_glue = "bit-of-glue-v1-LIB" + "/"
	const start_end_v2 = "start-end-v2" + "/"


# -- MOVE ANIM  NOTE: usual loco and combat loco are mixed for now


const idle := lib.all_axe + "L-combat-idle" # _EP_p1 + "EP-p1-O-idle-combat" # _ss_loco + "B-idle"

const walk := lib._ss_loco + "C-walk" # _EP_p1 + "EP-p1-O-Walk-Combat" # _ss_loco + "C-walk"
# const combat_walk_start := lib._SWS_loco_p2 + "SWSlp2-O-walk-start" # _ss_loco + "C-walk"
const idle_to_sprint := lib.start_end_v2 + "L RM Idle To Sprint" # :=_SWS_loco_p2 + "SWSlp2-O-sprint-start" #
const idle_turn_to_run_L := lib.start_end_v2 + "L RM Turn To Running L"
const sprint_to_idle := lib.start_end_v2 + "L RM run to stop" # :=_SWS_loco_p2 + "SWSlp2-O-sprint-start" #
const walk_back := lib._ss_loco + "C-walk-back" # _EP_p1 + "EP-p1-O-Walk-Combat-B" #
const run := lib._run + "B-Jog-Forward-v2" # "SWSl-O-run-F" # _run + "B-Jog-Forward-v2"
const sprint := lib._run + "B-Fast-Run-v2" # _SWS_loco + "SWSl-O-sptrint-F" # _run + "B-Fast-Run-v2"

const turn_180_R := lib._ss_loco + "RMR ss 180 turn R"
const turn_180_L := lib._ss_loco + "RMR ss 180 turn L"

const fast_turn_180_R := lib._ss_loco + "RMR ss 180 fast turn R"
const fast_turn_180_L := lib._ss_loco + "RMR ss 180 fast turn L"

# strafe
# const run_L := lib._SWS_loco + "SWSl-O-run-L-blended" # _strafe + "A-ss-strafe-L"
const run_R := lib._SWS_loco + "SWSl-O-run-R-blended" # _strafe + "A-ss-strafe-R"

# air
# todo jump-roll A-Quick-Roll-To-Run
const midair := lib.jump_v4 + "Midair-Hok" # TODO: change rotation of anim
# const jump_run := lib.axe_rm_jump + "LL-jump-running_start" # _jump_up_land_HPG + "B-UP-ss-jump-run-RP" # _OS_loco + "OSl-jump-place-start"
const small_jump_run := lib.axe_rm_jump + "LL-jump-running"
# const landing_run := lib.axe_rm_jump + "LL-jump-running_start" # _jump_up_land_HPG + "B-LAND-ss-jump-run-RP" # _OS_loco + "OSl-jump-place-end"
const jump_sprint := lib.jump_v4 + "RM-Run-Jump-all"
const landing_sprint := lib.jump_v4 + "RM-Run-Jump-ver-land"
const jump_idle := lib._bit_of_glue + "A-Idle-Jumping-ver3"
# const hard_fall := # _jump_up_land_HPG + "C-fall-HW-hard-land-idle-trim-pin"

#
const roll := lib.jump_v4 + "RM-Sprint-to-Roll" # _OS_fight + "OS-evade-forward" # todo
const death := midair # _ss_loco + "C-death-2"


# -- FIGHT 
const longsword_1 := lib.all_axe + "aIP-attack-slice-RL" # _ff + "longsword_1" # _SWS_combo + "SWSc-O-combo-1-all" #
const longsword_2 := lib.all_axe + "aIP-attack-slice-LR-cut" # "Ex-attack-second-slice-cut" # _SWS_combo + "SWSc-O-combo-2-slash-2" # _ff + "longsword_2"

const withdraw := midair # _jump + "C-fall-HW" # TODO
const block_forward := lib._ss_attack + "C-block-forward" # _OS_fight + "OS-block-left" # _ss_attack + "C-block-forward"
# const block_to_idle := _ss_attack + "C-block-to-idle"

const block_reaction := midair # _ff + "block_reaction" # _OS_fight + "OS-hit-react" # _ff + "block_reaction"
const hit_reaction := block_reaction # _ss_attack + "C-body-impact" # _ss_attack + "C-leg-kick" # shield_throw # _ss_attack + "C-body-impact"
const pushback := midair # todo
const staggered := midair # _ss_attack + "B-head-impact"

const parry := midair # _ff + "parry"
const parried := midair # _ff + "parried"
const riposte_attack := longsword_1
# -- FIGHT END

const shield_throw := midair # _ff + "shield_throw"
const shield_throw_reload := midair # _ff + "shield_throw_reload"
const idle_longsword := midair # _ff + "idle_longsword"


#--------------


const fake_anim := "fake anim"

#--------------
const SET_full_body := "full_body"

#-------------------
