@tool
@icon("res://-assets-/x_icons/white/icon_gear.png")
class_name AnimatableEntityConfig
extends NodeLogger


## 
@export var SPEED_SCALE_COEF: float = 1.0
@export var speed_scale_coef_mutable: bool = true

@export var key_f_value: DVS.KeyFValueChanger = DVS.KeyFValueChanger.UNKNOWN


func _ready() -> void:
	if u.is_release():
		return
	if u.is_editor():
		return
	

	if key_f_value == DVS.KeyFValueChanger.UNKNOWN:
		return

	if not speed_scale_coef_mutable:
		return

	await FrameUtils.wait_process_frames(6)
	SigUtils.safe_connect_pairs([
			[GlobalUIInfo.SIG_dvc_fvalue_changed, _on_SIG_dvc_fvalue_changed],
		])
	__log_("safe_connect_pairs")


## TODO: should be moved to separate mode, not using dev code inside Config
func _on_SIG_dvc_fvalue_changed(payload: Dictionary[String, Variant]):
	var parsed_payload := DVCSIGPayloadParser.parse_untyped_dvc_value_changed(
		payload,
		DVS.KeyFValueChanger
		)
	if not parsed_payload or not parsed_payload.value is float:
		return
	var dvc_key := parsed_payload.key
	var value := parsed_payload.value as float
	match dvc_key:
		key_f_value:
			__log_("_on_SIG_dvc_fvalue_changed", key_f_value, value, typeof(value))
			SPEED_SCALE_COEF = value
			__log_("SPEED_SCALE_COEF", SPEED_SCALE_COEF)


##

func __LOG_B() -> bool:
	return false
