extends RefCounted
class_name PS # player states and actions

# STATES
# fight 
const withdraw := "withdraw"
const shield_throw := "shield_throw"
const shield_throw_reload := "shield_throw_reload"
const longsword_1 := "longsword_1"
const longsword_2 := "longsword_2"
const block := "block"
const block_reaction := "block_reaction"
const pushback := "pushback"
const staggered := "staggered"
const parry := "parry"
const parried := "parried"
const riposte := "riposte"

# move
# TODO const walk := "test/walk"
const idle := "idle"
const run := "run"
const strafe := "strafe"
const sprint := "sprint"
const jump_run := "jump_run"
const jump_sprint := "jump_sprint"
const midair := "midair"
const landing_run := "landing_run"
const landing_sprint := "landing_sprint"
const roll := "roll"
const death := "death"

# ACTIONS
const action_withdraw := "action_withdraw🖊️"
const action_shield_throw := "action_shield_throw🖊️"
const action_shield_throw_reload := "action_shield_throw_reload🖊️"
const action_longsword_1 := "action_longsword_1🖊️"
const action_longsword_2 := "action_longsword_2🖊️"
const action_block := "action_block🖊️"
const action_block_reaction := "action_block_reaction🖊️"
const action_pushback := "action_pushback🖊️"
const action_staggered := "action_staggered🖊️"
const action_parry := "action_parry🖊️"
const action_parried := "action_parried🖊️"
const action_riposte := "action_riposte🖊️"

const action_idle := "action_run_idle🖊️"
const action_sprint_idle := "action_sprint_idle🖊️"
const action_walk := "action_walk🖊️"

const action_strafe := "action_strafe🖊️"
const action_sprint := "action_sprint🖊️"
const action_jump_run := "action_jump_run🖊️"
const action_jump_sprint := "action_jump_sprint🖊️"
const action_midair := "action_midair🖊️"
const action_landing_run := "action_landing_run🖊️"
const action_landing_sprint := "action_landing_sprint🖊️"
const action_roll := "action_roll🖊️"
const action_death := "action_death🖊️"


# const states_priority: Dictionary = {
# 	idle: 1,
# 	run: 2,
# 	sprint: 3,
# 	jump_run: 10,
# 	midair: 10,
# 	landing_run: 10,
# 	jump_sprint: 10,
# 	landing_sprint: 10,
# 	slash_1: 15,
# 	slash_2: 15,
# 	slash_3: 15,
# 	parry: 20,
# 	riposte: 25,
# 	parried: 100,
# 	staggered: 100,
# 	death: 200
# }

# static func _priority_sort(a: String, b: String):
# 	if states_priority[a] > states_priority[b]:
# 		return true
# 	else:
# 		return false

# ## For now assumes that states not empty
# static func sort_by_priority(states: Array) -> Array:
# 	if states.is_empty():
# 		push_error("states empty")
# 	var sorted = states.duplicate()
# 	sorted.sort_custom(PS._priority_sort)
	
# 	return sorted

# ## For now assumes that states not empty
# static func prioritized(states: Array) -> String:
# 	if states.is_empty():
# 		push_error("states empty")
# 	var sorted = sort_by_priority(states)
# 	return sorted[0]
