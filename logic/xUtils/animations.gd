extends RefCounted
class_name A


# LIBS
# -anim-jumps-all1-LIB/C-fall-HW-param
const _ss_strafe_LIB = "ss_strafe/"
const _ss_LIB = "ss/"
const _jump_LIB = "jumps-v1-LIB/"

# ANIMATOR SETS
const SET_full_body := "full_body"
const SET_full_body_torso := "full_body_torso"
const SET_torso_legs := "torso_legs"


# raw but used
const idle_longsword := "idle_longsword"
const strafe_R := _ss_strafe_LIB + "strafe_R"
const strafe_L := _ss_strafe_LIB + "strafe_L"
const strafe_idle := _ss_LIB + "idle"
const strafe_forward := _ss_LIB + "walk"
const strafe_back := _ss_LIB + "walk"

# fight 
const withdraw := _jump_LIB + "C-fall-HW"
const shield_throw := "shield_throw"
const shield_throw_reload := "shield_throw_reload"
const longsword1 := "longsword_1"
const longsword2 := "longsword_2"
const block := "block"
const block_reaction := "block_reaction"
const pushback := "pushback"
const staggered := "staggered"
const parry := "parry"
const parried := "parried"
const riposte := "riposte"

# move
const idle := "idle"
const walk := _ss_LIB + "walk"
const run := "run"
# const strafe := "strafe"
const sprint := "sprint"
const jump_run := _jump_LIB + "C-jump-idle-UP-HW"
const jump_sprint := "jump_sprint"
const midair := "midair"
const landing_run := "landing_sprint"
const landing_sprint := "landing_sprint"
const roll := "roll"
const death := "death"


# raw

const longsword_1 := "longsword_1"
const longsword_2 := "longsword_2"


static func to_backend_lazy(animation: String) -> String:
	return animation + "-param"