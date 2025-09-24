extends RefCounted
class_name A

# LIBS
const _jump = "jumps-v2-LIB" + "/"
const _jump_up_land_ = "jump-up-land-v3-LIB" + "/"
const _jump_up_land_HPG = "jump-up-land-v3-LIB-HPG" + "/"
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

const _axe_for_player = "axe-for-player-v1-LIB" + "/"
const _axe_slices = "axe-slices-LIB" + "/"

const _bit_of_glue = "bit-of-glue-v1-LIB" + "/"

const _specifics = "_specifics" + "/"


# -- MOVE ANIM  NOTE: usual loco and combat loco are mixed for now
const combat_idle := _ss_loco + "B-idle" # _EP_p1 + "EP-p1-O-idle-combat" # _ss_loco + "B-idle"
const combat_walk := _EP_p1 + "EP-p1-O-Walk-Combat" # _ss_loco + "C-walk"
const combat_walk_start := _SWS_loco_p2 + "SWSlp2-O-walk-start" # _ss_loco + "C-walk"
const combat_run_start := _specifics + "Idle To Sprint_001"
const combat_walk_back := _EP_p1 + "EP-p1-O-Walk-Combat-B" # _ss_loco + "C-walk-back"
const combat_run := _run + "B-Jog-Forward-v2" # "SWSl-O-run-F" # _run + "B-Jog-Forward-v2"
const combat_sprint := _run + "B-Fast-Run-v2" # _SWS_loco + "SWSl-O-sptrint-F" # _run + "B-Fast-Run-v2"

# strafe
const run_L := _SWS_loco + "SWSl-O-run-L-blended" # _strafe + "A-ss-strafe-L"
const run_R := _SWS_loco + "SWSl-O-run-R-blended" # _strafe + "A-ss-strafe-R"

# air
# todo jump-roll A-Quick-Roll-To-Run
const midair := _jump + "B-Fall-loop-HOK" # TODO: change rotation of anim
const jump_run := _OS_loco + "OSl-jump-place-start" # _jump_up_land_HPG + "B-UP-ss-jump-run-RP"
const jump_sprint := jump_run
const landing_run := _OS_loco + "OSl-jump-place-end" # _jump_up_land_HPG + "B-LAND-ss-jump-run-RP"
const landing_sprint := landing_run
const jump_idle := _bit_of_glue + "A-Idle-Jumping-ver3"
# const hard_fall := # _jump_up_land_HPG + "C-fall-HW-hard-land-idle-trim-pin"

#
const roll := _OS_fight + "OS-evade-forward" # todo
const death := midair # _ss_loco + "C-death-2"


# -- FIGHT 
const longsword_1 := _SWS_combo + "SWSc-O-combo-1-all" # _axe_for_player + "Ex-attack-slice-RL" # _ff + "longsword_1"
const longsword_2 := _axe_slices + "Ex-attack-second-slice-cut" # _SWS_combo + "SWSc-O-combo-2-slash-2" # _ff + "longsword_2"

const withdraw := midair # _jump + "C-fall-HW" # TODO
const block_forward := _OS_fight + "OS-block-left" # _ss_attack + "C-block-forward"
# const block_to_idle := _ss_attack + "C-block-to-idle"

const block_reaction := _OS_fight + "OS-hit-react" # _ff + "block_reaction"
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

const PARAM_SUFFIX = "-param"

static func to_backend_anim(anim_name: String) -> String:
	return anim_name + PARAM_SUFFIX

static func from_backend_anim(anim_name: String) -> String:
	# if no suffix, return the string unchanged
	return anim_name.trim_suffix(PARAM_SUFFIX)


#--------------
# ANIMATOR SETS
const SET_full_body := "full_body"
const SET_full_body_torso := "full_body_torso"
const SET_torso_legs := "torso_legs"
