@tool
@icon("uid://u8wgfhnl4x54")

@abstract
class_name BaseDevVisualise
extends Node3DSystem


@export var _character: BaseStaticCharacter
@export var _char_type: DVS.CharacterType = DVS.CharacterType.UNKNOWN

@export_group("Working Settings")
@export var preview_in_editor := false

## completely turn off while initialising in game
## does NOT affect the editor
@export var _enabled := true


var _time_elapsed := 0.0


## INITIALISATION
# region


func _get_character_type() -> DVS.CharacterType:
	if _character:
		return _character.char_type
	else:
		return _char_type
	

func _ready() -> void:
	if not Engine.is_editor_hint():
		if not _enabled:
			set_enabled(false)
			return
		## wait a little before kicking in 
		await FrameUtils.wait_process_frames(4)

	_initialise_implementation_both_editor_and_game()

	if not Engine.is_editor_hint():
		_initialise_implementation_in_game()

		if not __perform_validation(true):
			__log_warn_soft("won't be working")
		else:
			# SigUtils.safe_connect_pairs([
					# [visibility_changed, _on_visibility_changed],
				# ])
			if _get_character_type() != DVS.CharacterType.UNKNOWN:
				SigUtils.safe_connect_pairs([
					[GlobalUIInfo.SIG_dvc_value_changed_section_char_dv, _on_SIG_dvc_value_changed_section_char_dv]
				])
		
		set_enabled(false) # WARNING: temporary disable on start always

# endregion


# func _on_visibility_changed():
	# set_enabled(visible)


func set_enabled(value: bool):
	if not value:
		process_mode = Node.PROCESS_MODE_DISABLED
		reset_visuals()
	else:
		process_mode = Node.PROCESS_MODE_INHERIT
	visible = value


@abstract func reset_visuals() -> void


## TEMPLATE
# region
#---------
# func _initialise_implementation_both_editor_and_game() -> void:
# 	super._initialise_implementation_both_editor_and_game()

# func _initialise_implementation_in_game() -> void:
# 	super._initialise_implementation_in_game()
#---------
# endregion


## called before the validation
func _initialise_implementation_both_editor_and_game() -> void:
	pass

## called before the validation
func _initialise_implementation_in_game() -> void:
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


## SIG

func _on_SIG_dvc_value_changed_section_char_dv(payload: Dictionary[String, Variant]):
	var parsed_payload := SigPayloadParser.safe_get_SIG_dvc_value_changed_section_char_dv_payload(
		payload,
		)
	if not parsed_payload:
		return
	if parsed_payload.char_type != _get_character_type():
		return
	__log_("_on_SIG_dvc_value_changed_section_char_dv", parsed_payload.char_dv_type)
	_on_SIG_dvc_value_changed_section_char_dv_imp(parsed_payload)


@abstract func _on_SIG_dvc_value_changed_section_char_dv_imp(payload: SigPayloadParser.DVValueChangedSectionCharDVPayload) -> void


## LOGS

func pp_name() -> String:
	return "🖌️" + str(_char_type) + ObjUtils.construct_obj_pp_name(self )


func __LOG_B() -> bool:
	return false