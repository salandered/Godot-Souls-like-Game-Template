extends RefCounted
class_name Leg

# 🦜
# LEGS BEHAVIOR
class Beh:
	const idle := "l_behavior_idle"
	const run := "l_behavior_run"
	const strafe := "l_behavior_strafe🚶🏻‍♀️"
	const sprint := "l_behavior_sprint"
	const double := "l_behavior_double"
# const l_behavior_air := "l_behavior_air"


# LEGS ACTION
class Act:
	const idle := "l_action_idle🧍"
	const run := "l_action_run🏃"

	const strafe := "l_action_strafe🚶🏻‍♀️"
	const vert_locked_walk := "l_vert_locked_walk✏️"
	const vert_locked_run := "l_vert_locked_run✏️"

	const turn_180 := "l_turn_180 ↻"
	const fast_turn_180 := "l_fast_turn_180 ↻💨"
	const sprint_to_idle := "l_action_sprint_to_idle🏃💨🧍"
	const run_to_idle := "l_action_run_to_idle🏃🧍"
	const idle_to_sprint := "l_action_idle2sprint🧍🏃💨"
	const run_to_sprint := "l_action_run2sprint✏️"
	const sprint := "l_action_sprint🏃💨"
	const land := "l_action_land✏️"
	const double := "l_action_double👯"

	# const walk_start := "l_action_walk_start✏️"
	# const turn_90_to_run := "l_turn_90_to_run_R ↪🏃" # from idle
	# const l_action_jump_start := "l_action_jump_start"
	# const l_action_midair := "l_action_midair"