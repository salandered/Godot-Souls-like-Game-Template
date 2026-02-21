class_name Leg
extends RefCounted

# 🦜
# LEGS BEHAVIOR
class Beh:
	const idle := &"l_behavior_idle"
	const run := &"l_behavior_run"
	const strafe := &"l_behavior_strafe🚶🏻‍♀️"
	const sprint := &"l_behavior_sprint"
	const double := &"l_behavior_double"


# LEGS ACTION
class Act:
	const idle := &"la_idle🧍"
	const run := &"la_run🏃"

	const strafe := &"la_strafe🚶🏻‍♀️"
	const turn_180 := &"la_turn_180 ↻"
	const fast_turn_180 := &"la_fast_turn_180 ↻💨"
	const sprint_to_idle := &"la_sprint_to_idle✏️"
	const run_to_idle := &"la_run_to_idle🏃🧍"
	const idle_to_sprint := &"la_idle_to_sprint✏️"
	const run_to_sprint := &"la_run_to_sprint✏️"
	const sprint := &"la_sprint🏃💨"
	const double := &"la_double👯"

	# const walk_start := "la_action_walk_start✏️"
	# const turn_90_to_run := "la_turn_90_to_run_R ↪🏃" # from idle
	# const l_action_jump_start := "la_action_jump_start"
	# const l_action_midair := "la_action_midair"
