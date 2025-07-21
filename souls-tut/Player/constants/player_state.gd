class_name PlayerState extends RefCounted

const idle := "idle"
const run := "run"
const sprint := "sprint"
const jump_run := "jump_run"
const midair := "midair"
const landing_run := "landing_run"
const jump_sprint := "jump_sprint"
const landing_sprint := "landing_sprint"
const slash_1 := "slash_1"
const slash_2 := "slash_2"
const slash_3 := "slash_3"

const states_priority: Dictionary = {
	idle: 1,
	run: 2,
	sprint: 3,
	jump_run: 10,
	midair: 10,
	landing_run: 10,
	jump_sprint: 10,
	landing_sprint: 10,
	slash_1: 15,
	slash_2: 15,
	slash_3: 15
}
