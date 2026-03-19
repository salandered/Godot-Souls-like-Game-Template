@tool
@icon("res://assets/x_icons/white/icon_gear.png")
class_name AnimatableEntityConfig
extends NodeLogger


@export var SPEED_SCALE_COEF: float = 1.0
@export var speed_scale_coef_mutable: bool = true

@export var key_f_value: DTS.KeyFValueChanger = DTS.KeyFValueChanger.UNKNOWN


func _ready() -> void:
	if eu.is_release():
		return
	if eu.is_editor():
		return
	

	if key_f_value == DTS.KeyFValueChanger.UNKNOWN:
		return

	if not speed_scale_coef_mutable:
		return

	await FrameUtils.wait_process_frames(self , 6)
	SigUtils.safe_connect_pairs([
			[GlobalUIInfo.SIG_dtc_fvalue_changed, _on_SIG_dtc_fvalue_changed],
		])
	__log_("safe_connect_pairs")


## TODO: should be moved to separate mode, not using dev code inside Config
func _on_SIG_dtc_fvalue_changed(payload: Dictionary[StringName, Variant]):
	var parsed_payload := DTCSIGPayloadParser.parse_untyped_dtc_value_changed(
		payload,
		DTS.KeyFValueChanger
		)
	if not parsed_payload or not parsed_payload.value is float:
		return
	var dtc_key := parsed_payload.key
	var value := parsed_payload.value as float
	match dtc_key:
		key_f_value:
			__log_("_on_SIG_dtc_fvalue_changed", key_f_value, value, typeof(value))
			SPEED_SCALE_COEF = value
			__log_("SPEED_SCALE_COEF", SPEED_SCALE_COEF)


##

func __LOG_B() -> bool:
	return false
