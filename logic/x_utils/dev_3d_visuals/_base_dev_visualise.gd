@tool
@icon("uid://u8wgfhnl4x54")

@abstract
class_name BaseDevVisualise
extends Node3DSystem


@export_group("Working Settings")
@export var preview_in_editor := false

## completely turn off while initialising in game
## does NOT affect the editor
@export var _enabled := true


var _time_elapsed := 0.0


## INITIALISATION
# region

func _ready() -> void:
	if not Engine.is_editor_hint():
		if not _enabled:
			## hard stop in game if not enabled
			set_enabled(false)
			return
		## wait a little before kicking in 
		await FrameUtils.wait_process_frames(20)

	initialise_implementation_both_editor_and_game()

	if not Engine.is_editor_hint():
		initialise_implementation_in_game()

		if not __perform_validation(true):
			__log_warn_soft("won't be working")

		SigUtils.safe_connect(visibility_changed, _on_visibility_changed)


func _on_visibility_changed():
	set_enabled(visible)


func set_enabled(value: bool):
	if not value:
		process_mode = Node.PROCESS_MODE_DISABLED
		reset_visuals()
	else:
		process_mode = Node.PROCESS_MODE_INHERIT


@abstract func reset_visuals() -> void

## TEMPLATE
# region
#---------
# func initialise_implementation_both_editor_and_game() -> void:
# 	super.initialise_implementation_both_editor_and_game()

# func initialise_implementation_in_game() -> void:
# 	super.initialise_implementation_in_game()
#---------
# endregion


## called before the validation
func initialise_implementation_both_editor_and_game() -> void:
	pass

## called before the validation
func initialise_implementation_in_game() -> void:
	pass


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


## HELPERS


## LOGS

func pp_name() -> String:
	return "🖌️" + ObjUtils.construct_obj_pp_name(self )
