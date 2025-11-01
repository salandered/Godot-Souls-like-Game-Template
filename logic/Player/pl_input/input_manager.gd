extends Node

## Works via Auto-Load

var _input_gatherer: InputGatherer
var _current_input: InputPackage

func _ready() -> void:
	_input_gatherer = InputGatherer.new()
	
	# process input before other nodes
	process_priority = -100 # seems like its safe and works, but keep an eye


func get_current_input() -> InputPackage:
	return _current_input

func _process(delta: float) -> void:
	_current_input = _input_gatherer.gather_input(delta)


	if Input.is_action_just_pressed(RawAction.force_quit):
		get_tree().quit()
		return # Don't process input if quitting
