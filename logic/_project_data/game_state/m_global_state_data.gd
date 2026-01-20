class_name M_GlobalStateData
extends Resource

@export var first_version_opened : String
@export var last_version_opened : String
@export var last_unix_time_opened : int
@export var states : Dictionary

## A container resource for persistent game data.
##
## This resource acts as the root object for the save file. It stores metadata 
## (versions, time) and a dictionary of sub-states (other Resources), 
## handling their initialization and retrieval to ensure data integrity.


func get_or_create_state(key_name : String, state_type_path : String) -> Resource:
	var new_state : Resource
	var new_state_script = load(state_type_path)
	if new_state_script is GDScript:
		new_state = new_state_script.new()
	if key_name in states:
		var saved_state : Resource = states[key_name]
		var saved_script = saved_state.get_script()
		var new_script = new_state.get_script()
		if saved_script and new_script and saved_script == new_script:
			return saved_state
	states[key_name] = new_state
	return new_state

func has_state(key_name : String) -> bool:
	return key_name in states
