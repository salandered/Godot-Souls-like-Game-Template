@tool
@icon("uid://caaobedt2p7i6")

@abstract
class_name BaseDevVisualiseProcess
extends DVCSignalEnabledNode3D


@export_group("Working Settings")
@export var preview_in_editor := false

## completely turn off while initialising in game
## does NOT affect the editoPpr
@export var _enabled := true


var _time_elapsed := 0.0


## INITIALISATION
# region


func _initialise_implementation_in_game() -> void:
	if not _enabled:
		__shut_down()

# endregion


func set_enabled(value: bool):
	super.set_enabled(value)
	if not value:
		process_mode = Node.PROCESS_MODE_DISABLED
		reset_visuals()
	else:
		process_mode = Node.PROCESS_MODE_INHERIT


@abstract func reset_visuals() -> void


# endregion


## PROCESS

## visualises only if returns true
@abstract func _conditions_to_visualise() -> bool


func _process_before_visalisation(delta: float) -> void:
	pass

## calls to draw something should be here
@abstract func _process_visualisation(delta: float) -> void

func _process_after_visalisation(delta: float) -> void:
	pass


## try not to override but use abstract methods
func _process(delta: float) -> void:
	## won't be running in editor if not preview_in_editor
	if Engine.is_editor_hint() and not preview_in_editor:
		return
 	
	_process_before_visalisation(delta)

	if _conditions_to_visualise():
		_process_visualisation(delta)

	_process_after_visalisation(delta)

	_time_elapsed += delta


## LOGS


func __LOG_B() -> bool:
	return false