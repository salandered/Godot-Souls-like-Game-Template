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
const _ff = "global-fair" + "/"

# ANIMATOR SETS
const SET_full_body := "full_body"
const SET_full_body_torso := "full_body_torso"
const SET_torso_legs := "torso_legs"


# -- MOVE ANIM

# peaceful move
# const walk := "walk"
const midair := _jump + "B-Fall-loop-HOK"
const jump_run := _jump_up_land_HPG + "B-UP-ss-jump-run-RP"
const jump_sprint := jump_run

const landing_run := _jump_up_land_HPG + "B-LAND-ss-jump-run-RP"
const landing_sprint := landing_run
const hard_fall := _jump_up_land_HPG + "C-fall-HW-hard-land-idle-trim-pin"

const roll := _ff + "roll"
const death := _ss_loco + "C-death-2"


# combat move
const combat_idle := _ss_loco + "B-idle"
const combat_walk := _ss_loco + "C-walk"
const combat_walk_back := _ss_loco + "C-walk-back"

const combat_run := _run + "B-Jog-Forward-v2"
const combat_sprint := _run + "B-Fast-Run-v2"

# strafe
const strafe_L := _strafe + "A-ss-strafe-L"
const strafe_R := _strafe + "A-ss-strafe-R"
const strafe_idle := combat_idle
const strafe_forward := combat_walk
const strafe_back := combat_walk_back

# -- MOVE ANIM END

# -- FIGHT 
const withdraw := _jump + "C-fall-HW" # TODO

const block_forward := _ss_attack + "C-block-forward"
const block_to_idle := _ss_attack + "C-block-to-idle"
const block_reaction := _ff + "block_reaction"
const pushback := _ff + "pushback"
const staggered := _ss_attack + "B-head-impact"
const parry := _ff + "parry"
const parried := _ff + "parried"
const riposte_attack := longsword_1
# -- FIGHT END

# TODO: old longsword_ anim + param RM -> translate to new Skeleton and Root.
#       then this anims can be used 
const longsword_1 := _ff + "longsword_1"
const longsword_2 := _ff + "longsword_2"
# and may be these ones
const shield_throw := _ff + "shield_throw"
const shield_throw_reload := _ff + "shield_throw_reload"
const idle_longsword := _ff + "idle_longsword"
#  "sprint" ?
# jump_sprint?