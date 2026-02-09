@tool
@icon("uid://sboavald7fvc")

@abstract
class_name BaseDVCDependentNode3D
extends Node3DSystem


@export var react_to_dvc_signal: bool = true
@export var dvc_section: DVS.DVSection = DVS.DVSection.UNKNOWN


@export_group("B_CHANGER S")
## used if dvc_section B_CHANGER
@export var _key_b_value_changer: DVS.KeyBValueChanger = DVS.KeyBValueChanger.UNKNOWN

@export_group("B_CHAR_DV S")
## used if dvc_section B_CHAR_DV
@export var _char_type: DVS.CharacterType = DVS.CharacterType.UNKNOWN
@export var _dv_type: DVS.CharDVType = DVS.CharDVType.UNKNOWN


## INITIALISATION
# region


func _ready() -> void:
	if not OS.is_debug_build():
		__shut_down()
		return

	if not Engine.is_editor_hint():
		## wait a little before kicking in 
		await FrameUtils.wait_process_frames(4)

	_initialise_implementation_both_editor_and_game()

	if Engine.is_editor_hint():
		return

	## ALL FOLLOWING IS IN GAME
	_initialise_implementation_in_game()

	if not __perform_validation(true):
		__log_warn_soft("won't be working")
		__shut_down()
		return


	if react_to_dvc_signal:
		var sig_pair_to_connect: Array = []
		match dvc_section:
			DVS.DVSection.B_CHAR_DV:
				if _char_type == DVS.CharacterType.UNKNOWN or _dv_type == DVS.CharDVType.UNKNOWN:
					__log_warn_soft("looks like u forgot to specify _char_type or _dv_type", "", "", _char_type, _dv_type)
				sig_pair_to_connect = [GlobalUIInfo.SIG_dvc_b_char_dv_value_changed, _on_SIG_dvc_b_char_dv_value_changed]
			DVS.DVSection.B_CHANGER:
				if _key_b_value_changer == DVS.KeyBValueChanger.UNKNOWN:
					__log_warn_soft("looks like u forgot to specify _key_b_value_changer", "", "", _key_b_value_changer)
				sig_pair_to_connect = [GlobalUIInfo.SIG_dvc_bvalue_changed, _on_SIG_dvc_bvalue_changed]
			_:
				__log_warn_soft("looks like u forgot to specify dvc_section", "", "", dvc_section)

		SigUtils.safe_connect_pairs([
			sig_pair_to_connect
		])
	
	set_enabled(false) # disable on start

# endregion


func set_enabled(value: bool):
	visible = value


func __shut_down():
	visible = false
	process_mode = Node.PROCESS_MODE_DISABLED


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


## SIG

func _on_SIG_dvc_b_char_dv_value_changed(payload: Dictionary[String, Variant]):
	var parsed_payload := DVCSIGPayloadParser.parse_dvc_b_char_dv_value_changed(payload)
	if not parsed_payload:
		return
	if parsed_payload.char_type != _char_type:
		return
	if parsed_payload.char_dv_type != _dv_type:
		return

	set_enabled(parsed_payload.value_as_bool)
	

func _on_SIG_dvc_bvalue_changed(payload: Dictionary[String, Variant]):
	var _r := DVCSIGPayloadParser.safe_bget_value_by_dvc_key(payload, _key_b_value_changer)
	if _r.err:
		return

	set_enabled(_r.value)
	

## LOGS

func pp_name() -> String:
	return "🎨" + super.pp_name()


func __LOG_B() -> bool:
	return false