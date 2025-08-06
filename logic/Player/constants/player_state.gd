class_name PlayerState extends RefCounted

# TODO: unite all this and @onready var states with one structure
# move
const idle := "idle"
const run := "run"
const sprint := "sprint"
const jump_run := "jump_run"
const midair := "midair"
const landing_run := "landing_run"
const jump_sprint := "jump_sprint"
const landing_sprint := "landing_sprint"


const strafe := "strafe"


# combat
const slash_1 := "slash_1"
const longsword_1 := "longsword_1"

const slash_2 := "slash_2"
const longsword_2 := "longsword_2"

const slash_3 := "slash_3"
const staggered := "staggered"
const parry := "parry"
const riposte := "riposte"
const parried := "parried"
const death := "death"


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
# 	sorted.sort_custom(PlayerState._priority_sort)
	
# 	return sorted

# ## For now assumes that states not empty
# static func prioritized(states: Array) -> String:
# 	if states.is_empty():
# 		push_error("states empty")
# 	var sorted = sort_by_priority(states)
# 	return sorted[0]
