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
const jump_sprint := "jump_sprint"
const midair := "midair"
const landing_run := "landing_run"
const landing_sprint := "landing_sprint"
const roll := "roll"
const death := "death"

# ACTIONS
class Act:
	const double := "pla_double👭🏻"

	const withdraw := "pla_withdraw🖊️"
	const shield_throw := "pla_shield_throw🖊️"
	const shield_throw_reload := "pla_shield_throw_reload🖊️"
	
	## attacks
	const longsword_1 := "pla_longsword_1🗡"
	const longsword_2 := "pla_longsword_2🗡"
	const axe_slice_1 := "pla_axe_slice_1🗡"
	const axe_slice_2 := "pla_axe_slice_2🗡"
	const attack_from_run := "pla_attack_from_run🗡"
	

	const block := "pla_block🖊️"
	const block_reaction := "pla_block_reaction🖊️"
	const pushback := "pla_pushback🖊️"
	const staggered := "pla_staggered🖊️"
	const parry := "pla_parry🖊️"
	const parried := "pla_parried🖊️"
	const riposte := "pla_riposte🖊️"

	# const idle := "action_run_idle🖊️"

	const jump_sprint := "pla_jump_sprint🖊️"
	const midair := "pla_midair🖊️"
	const landing_sprint := "pla_landing_sprint🖊️"
	const roll := "pla_roll🖊️"
	const dodge := "pla_dodge🤸"
	const death := "pla_death🖊️"


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
