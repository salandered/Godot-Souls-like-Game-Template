extends RefCounted
class_name Leg


# LEGS BEHAVIOR
class Beh:
	const idle := "legs_behavior_idle"
	const run := "legs_behavior_run"
	const sprint := "legs_behavior_sprint"
	const double := "legs_behavior_double"
# const legs_behavior_air := "legs_behavior_air"


# LEGS ACTION
class Act:
	const idle := "legs_action_idle🧍"
	const run := "legs_action_run🏃"
	const walk_start := "legs_action_walk_start✏️"
	const idle_to_sprint := "legs_action_idle2sprint🧍🏃💨"
	const run_to_sprint := "legs_action_run2sprint✏️"
	const sprint := "legs_action_sprint🏃💨"
	# const legs_action_jump_start := "legs_action_jump_start"
	# const legs_action_midair := "legs_action_midair"
	const land := "legs_action_land✏️"
	const double := "legs_action_double👯"
