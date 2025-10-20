extends RefCounted
class_name PS # player states and actions

# STATES
# fight 
const withdraw := "withdraw"
const shield_throw := "shield_throw"
const shield_throw_reload := "shield_throw_reload"

const block := "block"
const block_reaction := "block_reaction"
const pushback := "pushback"
const staggered := "staggered"
const parry := "parry"
const parried := "parried"
const riposte := "riposte"

## attacks
const longsword_1 := "longsword_1"
const longsword_2 := "longsword_2"

const axe_slice_1 := "axe_slice_1"
const axe_slice_2 := "axe_slice_2"
const attack_from_run := "attack_from_run"

# move
# TODO const walk := "test/walk"

const for_double := "for_double"


const idle := "idle"
const run := "run"
const strafe := "strafe"
const sprint := "sprint"
const dodge := "dodge"
const small_jump_run := "jump_run"
const jump_sprint := "jump_sprint"
const midair := "midair"
const landing_run := "landing_run"
const landing_sprint := "landing_sprint"
const roll := "roll"
const death := "death"

# ACTIONS
class Act:
	const double := "action_double👭🏻"

	const withdraw := "action_withdraw🖊️"
	const shield_throw := "action_shield_throw🖊️"
	const shield_throw_reload := "action_shield_throw_reload🖊️"
	
	## attacks
	const longsword_1 := "action_longsword_1🗡"
	const longsword_2 := "action_longsword_2🗡"
	const axe_slice_1 := "action_axe_slice_1🗡"
	const axe_slice_2 := "action_axe_slice_2🗡"
	const attack_from_run := "action_attack_from_run🗡"
	

	const block := "action_block🖊️"
	const block_reaction := "action_block_reaction🖊️"
	const pushback := "action_pushback🖊️"
	const staggered := "action_staggered🖊️"
	const parry := "action_parry🖊️"
	const parried := "action_parried🖊️"
	const riposte := "action_riposte🖊️"

	# const idle := "action_run_idle🖊️"

	const small_jump_run := "action_small_jump_run🖊️"
	const jump_sprint := "action_jump_sprint🖊️"
	const midair := "action_midair🖊️"
	const landing_run := "action_landing_run🖊️"
	const landing_sprint := "action_landing_sprint🖊️"
	const roll := "action_roll🖊️"
	const dodge := "action_dodge🖊️"
	const death := "action_death🖊️"


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
