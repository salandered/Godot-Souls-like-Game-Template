extends Node

## Works via Auto-Load.

var input_gatherer: InputGatherer
var current_input: InputPackage

func _ready() -> void:
	input_gatherer = InputGatherer.new()
	
	# process input before other nodes
	process_priority = -100 # seems like its safe and sound, but keep an eye on that

func _process(delta: float) -> void:
	current_input = input_gatherer.gather_input(delta)


	if Input.is_action_just_pressed(RawAction.force_quit):
		get_tree().quit()
		return # Don't process input if quitting
