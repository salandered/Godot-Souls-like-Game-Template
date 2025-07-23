extends Node
class_name StatesDataRepository

@onready var state_database = $StatesDatabase


# "ask them about the hypothetical parameter status at a given time if it was playing"
# called from player state

func get_vulnerable(animation: String, timecode: float) -> bool:
	var data = state_database.get_animation(animation)
	var track = data.find_track("StatesDatabase:is_vulnerable", Animation.TYPE_VALUE)
	return state_database.get_boolean_value(animation, track, timecode)

func get_interruptable(animation: String, timecode: float) -> bool:
	var data = state_database.get_animation(animation)
	var track = data.find_track("StatesDatabase:is_interruptable", Animation.TYPE_VALUE)
	return state_database.get_boolean_value(animation, track, timecode)

func get_parryable(animation: String, timecode: float) -> bool:
	var data = state_database.get_animation(animation)
	var track = data.find_track("StatesDatabase:is_parryable", Animation.TYPE_VALUE)
	return state_database.get_boolean_value(animation, track, timecode)
