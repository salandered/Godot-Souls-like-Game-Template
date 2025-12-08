extends RefCounted
class_name PS # player states and actions

# STATES
# fight 


## attacks
const axe_slice_1 := "axe_slice_1"
const axe_slice_2 := "axe_slice_2"
const attack_from_run := "attack_from_run"
const attack_from_dodge := "attack_from_dodge"

const sword_slash_1 := "sword_slash_1"
const sword_slash_2 := "sword_slash_2"
const sword_slash_3 := "sword_slash_3"

## loco
const idle := "idle"
const run := "run"
const strafe := "strafe"
const sprint := "sprint"

## air
const dodge := "dodge"
const jump_sprint := "jump_sprint"
const midair := "midair"
const landing_sprint := "landing_sprint"


##
const death := "death"
const for_double := "for_double"
const pushback := "pushback"
const thrown := "thrown"
# const stand_up := "stand_up"


# ACTIONS
class Act:
	const double := "pla_double👭🏻"

	## one time 
	const pushback := "pla_pushback🖊️"
	const thrown := "pla_thrown🖊️"
	# const stand_up := "pla_stand_up"
	const death := "pla_death🖊️"

	
	## attacks
	const axe_slice_1 := "pla_axe_slice_1🗡"
	const axe_slice_2 := "pla_axe_slice_2🗡"
	const attack_from_run := "pla_attack_from_run🗡"
	const attack_from_dodge := "pla_attack_from_dodge🗡"
	
	const sword_slash_1 := "pla_sword_slash_1🗡"
	const sword_slash_2 := "pla_sword_slash_2🗡"
	const sword_slash_3 := "pla_sword_slash_3🗡"


	## air
	const jump_sprint := "pla_jump_sprint🖊️"
	const midair := "pla_midair🖊️"
	const landing_sprint := "pla_landing_sprint🖊️"
	const dodge := "pla_dodge🤸"
	

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
