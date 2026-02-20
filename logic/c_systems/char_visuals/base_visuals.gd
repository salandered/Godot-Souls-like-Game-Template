@tool
@icon("uid://dxj2t2502l71w")

@abstract
class_name BaseVisuals
extends Node3DCharacterSystem


@export var _char_type: DVS.CharacterType = DVS.CharacterType.UNKNOWN

@export var _dv_type: DVS.CharDVType = DVS.CharDVType.HIDE_MESH_VISUALS


func _ready() -> void:
	if u.is_editor():
		return
	await FrameUtils.wait_process_frames(2)

	SigUtils.safe_connect_pairs([
		[GlobalUIInfo.SIG_dvc_b_char_dv_value_changed, _on_SIG_dvc_b_char_dv_value_changed]
	])


func _on_SIG_dvc_b_char_dv_value_changed(payload: Dictionary[String, Variant]):
	var parsed_payload := DVCSIGPayloadParser.parse_dvc_b_char_dv_value_changed(payload)
	if not parsed_payload:
		return
	if parsed_payload.char_type != _char_type:
		return
	if parsed_payload.char_dv_type != _dv_type:
		return

	set_visible_(not parsed_payload.value_as_bool)


func set_visible_(value: bool):
	visible = value