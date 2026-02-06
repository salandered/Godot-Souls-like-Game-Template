@tool
@icon("uid://bw1sr77shmixu")

class_name DVFancyCam
extends Node3DSystem


var _flying_label: Label3D
var _csg_nodes: Array[CSGPrimitive3D]
var _dv_trail: DevVisualiseTrail


var _flying_label_toggle: bool = false
var _dv_trail_toggle: bool = false


func __soft_dependencies() -> Array:
	return [
		_flying_label,
		# _dv_trail ## not even soft
	]


func _ready() -> void:
	if Engine.is_editor_hint():
		return

	_csg_nodes = get_descendants.csg_primitives(self )

	for item in _csg_nodes:
		if item:
			item.visible = true # always true, while parent (self) is false

	_flying_label = get_descendants.label_3d_one_or_null(self )
	toggle_flying_label_visible(false)


	_dv_trail = get_descendants.dev_visualise_trail_one_or_null(self )
	toggle_dv_trail_visible(false)


	if __perform_validation():
		SigUtils.safe_connect_pairs([
			[GlobalUIInfo.SIG_dvc_value_changed_section_op, _on_SIG_dvc_value_changed_section_op],
		])

	set_enable(false)


func set_enable(toggle: bool):
	__log_("set_enable", toggle)
	visible = toggle
	set_process_input(toggle)


## works only when self (main visuals) are visible
func toggle_flying_label_visible(toggle: bool):
	if _flying_label:
		_flying_label_toggle = toggle
		_flying_label.visible = toggle


## works only when self (main visuals) are visible
func toggle_dv_trail_visible(toggle: bool):
	if _dv_trail:
		_dv_trail_toggle = toggle
		_dv_trail.set_enabled(toggle)


func _on_SIG_dvc_value_changed_section_op(payload: Dictionary[String, Variant]):
	__log_("_on_SIG_dvc_value_changed_section_char_dv", payload)
	var r_toggle := SigPayloadParser.safe_bget_value_by_key_from_SIG_dvc_value_changed_section_payload(
		payload,
		DVS.KeyOverlayPanel.CAM_NODES
		)
	if r_toggle.err: return
	set_enable(r_toggle.value)
	

## here not marking input as handled - (several instances)
func _input(event: InputEvent) -> void:
	match InputUtils.get_keycode(event):
		KEY_L:
			__log_("_input", KEY_L)
			toggle_flying_label_visible(not _flying_label_toggle)
		KEY_T:
			__log_("_input", KEY_T)
			toggle_dv_trail_visible(not _dv_trail_toggle)


func __LOG_B() -> bool:
	return false
