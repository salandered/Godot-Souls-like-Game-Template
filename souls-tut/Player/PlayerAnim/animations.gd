extends RefCounted
class_name A


const run := "run"
const idle_longsword := "idle_longsword"


const strafe_R := "ss_strafe/strafe_R"
const strafe_L := "ss_strafe/strafe_L"
const strafe_idle := "ss/idle"
const strafe_forward := "walk"
const strafe_back := "walk"

# raw


const sprint := "sprint"
const midair := "midair"
const landing_run := "landing_run"
const landing_sprint := "landing_sprint"
const jump_sprint := "jump_sprint"
const longsword_1 := "longsword_1"
const longsword_2 := "longsword_2"
const parry := "parry"


static func to_backend_lazy(animation: String) -> String:
	return animation + "_params"