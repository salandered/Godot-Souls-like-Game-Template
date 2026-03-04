@tool
class_name DVAudioBusPanelManager
extends BasePanelManager


@export var spectrum: DVAudioBusSpectrum
@export var ui_container: Container
@export var auido_bus_label: Label


func __hard_dependencies() -> Array:
	return super.__hard_dependencies() + [
		spectrum
	]


## called before validation
func initialize_implementation():
	pass


func get_ui_panel() -> Container:
	return ui_container


func get_dtc_op_key() -> DTS.KeyBOverlayPanel:
	return DTS.KeyBOverlayPanel.BUS_SPECTRUM


func _supported_signal_pairs() -> Array[Array]:
	return [
		[GlobalUIInfo.SIG_dtc_svalue_changed, _on_SIG_dtc_svalue_changed],
	]


func set_enabled(value: bool):
	super.set_enabled(value)
	if spectrum:
		spectrum.set_enabled(value)


func _on_SIG_dtc_svalue_changed(payload: Dictionary[StringName, Variant]):
	var _r := DTCSIGPayloadParser.safe_sget_value_by_dtc_key(
		payload,
		DTS.KeySValueChanger.DV_SPECTRUM_AUDIO_BUS
		)
	if _r.err: return ""

	var _new_bus_id := _r.value

	if spectrum:
		var is_set := spectrum.set_audio_bus(_new_bus_id)
		if is_set and auido_bus_label:
			auido_bus_label.text = _new_bus_id
