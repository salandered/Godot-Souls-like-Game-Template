extends Node

## AutoLoad ##

## Probably should be renamed to PlayerInputManager


var _input_gatherer: InputGatherer
var _current_input: InputPackage
var _is_input_enabled: bool = true


func _ready() -> void:
	_input_gatherer = InputGatherer.new()

	_is_input_enabled = true
	
	# process input before other nodes
	process_priority = -100 # check if ok


func set_input_enabled(enabled: bool) -> void:
	_is_input_enabled = enabled
	

func get_current_input() -> InputPackage:
	return _current_input


func _process(delta: float) -> void:
	if not _is_input_enabled:
		_current_input = InputPackage.new()
		return

	_current_input = _input_gatherer.gather_input(delta)

	_process_quit()


func _process_quit():
	if eu.is_release():
		return

	if Input.is_action_just_pressed(RawAction.DEV_force_quit):
		get_tree().quit()
