extends RefCounted
class_name SEA


const idle := "idle"
const run := "run"
const walk := "basics/walk"
const attack_1 := "slash_1"

const death := "death"

const strafe_R := "gundyr/strafe_right"
const strafe_L := "gundyr/strafe_left"

const midair := "basics/midair"


# raw
const strafe_idle := "ss/idle"
const strafe_forward := "walk"
const strafe_back := "walk"

const sprint := "sprint"
const landing_run := "landing_run"
const landing_sprint := "landing_sprint"
const jump_sprint := "jump_sprint"
const longsword_1 := "longsword_1"
const longsword_2 := "longsword_2"
const parry := "parry"


static func to_backend_lazy(animation: String) -> String:
	return animation + "_params"