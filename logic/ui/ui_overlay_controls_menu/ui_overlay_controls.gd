class_name UIOverlayControls
extends PanelContainer


## check buttons

@onready var tutorial_toggler: CheckButton = %TutorialToggler
@onready var profiler_toggler: CheckButton = %ProfilerToggler
@onready var camera_nodes_toggler: CheckButton = %CameraNodesToggler

@onready var check_button_1: CheckButton = %CheckButton1
@onready var check_button_2: CheckButton = %CheckButton2
@onready var check_button_3: CheckButton = %CheckButton3
@onready var check_button_4: CheckButton = %CheckButton4
@onready var check_button_5: CheckButton = %CheckButton5
@onready var check_button_6: CheckButton = %CheckButton6
@onready var check_button_7: CheckButton = %CheckButton7
@onready var check_button_8: CheckButton = %CheckButton8
@onready var check_button_9: CheckButton = %CheckButton9
@onready var check_button_10: CheckButton = %CheckButton10
@onready var check_button_11: CheckButton = %CheckButton11
@onready var check_button_12: CheckButton = %CheckButton12

## spin buttons
@onready var spin_ghost_sec: UIOverlaySpinBox = %SpinGhostSec
@onready var spin_grid_v_separation: UIOverlaySpinBox = %SpinGridVSeparation

##


var ui_check_button_array: Array[CheckButton]

var button_name_to_overlay_panel_type: Dictionary[String, DevVisualsConfig.OverlayPanelType] = {}

var button_name_to_matrix_cdv_type: Dictionary[String, Array] = {}

var ui_spin_boxes_array: Array[SpinBox]


func _ready() -> void:
	## every check button can emit this signal 
	SigUtils.safe_connect(GlobalSignal.SIG_ui_overlay_check_button_toggled, _on_SIG_ui_overlay_check_button_toggled)
	## every spin box can emit this
	SigUtils.safe_connect(GlobalSignal.SIG_ui_overlay_spin_box_value_changed, _on_SIG_ui_overlay_spin_box_value_changed)

	## checkboxes
	_init_check_buttons_dicts()
	_init_check_buttons_array()
	_set_check_buttons_from_dvc()

	## spinboxes
	_init_spin_boxes_array()
	_set_spin_boxes_from_dvc()


func _init_spin_boxes_array() -> void:
	# can be automated via get descendants
	ui_spin_boxes_array = [
		spin_ghost_sec,
		spin_grid_v_separation,
]


func _init_check_buttons_dicts() -> void:
	button_name_to_overlay_panel_type = {
		tutorial_toggler.name: DevVisualsConfig.OverlayPanelType.TUT,
		profiler_toggler.name: DevVisualsConfig.OverlayPanelType.PROFILER,
		camera_nodes_toggler.name: DevVisualsConfig.OverlayPanelType.CAM_NODES,
	}

	## can be automated using 
	##    - button names (e g button name has index ij)
	##    - or adding special type for button and making export fields with types (see UIOverlaySpinBox)
	button_name_to_matrix_cdv_type = {
		check_button_1.name: [DevVisualsConfig.CharacterType.PLAYER, DevVisualsConfig.DevVisualsType.STATE_INFO],
		check_button_2.name: [DevVisualsConfig.CharacterType.HSM_ENEMY, DevVisualsConfig.DevVisualsType.STATE_INFO],
		check_button_3.name: [DevVisualsConfig.CharacterType.SIMPLE_ENEMY, DevVisualsConfig.DevVisualsType.STATE_INFO],
		check_button_4.name: [DevVisualsConfig.CharacterType.PLAYER, DevVisualsConfig.DevVisualsType.ATTACK_INFO],
		check_button_5.name: [DevVisualsConfig.CharacterType.HSM_ENEMY, DevVisualsConfig.DevVisualsType.ATTACK_INFO],
		check_button_6.name: [DevVisualsConfig.CharacterType.SIMPLE_ENEMY, DevVisualsConfig.DevVisualsType.ATTACK_INFO],
		check_button_7.name: [DevVisualsConfig.CharacterType.PLAYER, DevVisualsConfig.DevVisualsType.WEAPON_TRAIL],
		check_button_8.name: [DevVisualsConfig.CharacterType.HSM_ENEMY, DevVisualsConfig.DevVisualsType.WEAPON_TRAIL],
		check_button_9.name: [DevVisualsConfig.CharacterType.SIMPLE_ENEMY, DevVisualsConfig.DevVisualsType.WEAPON_TRAIL],
		check_button_10.name: [DevVisualsConfig.CharacterType.PLAYER, DevVisualsConfig.DevVisualsType.HITBOX],
		check_button_11.name: [DevVisualsConfig.CharacterType.HSM_ENEMY, DevVisualsConfig.DevVisualsType.HITBOX],
		check_button_12.name: [DevVisualsConfig.CharacterType.SIMPLE_ENEMY, DevVisualsConfig.DevVisualsType.HITBOX],
	}


func _init_check_buttons_array() -> void:
	# can be automated via get descendants
	ui_check_button_array = [
		tutorial_toggler,
		profiler_toggler,
		camera_nodes_toggler,
		check_button_1,
		check_button_2,
		check_button_3,
		check_button_4,
		check_button_5,
		check_button_6,
		check_button_7,
		check_button_8,
		check_button_9,
		check_button_10,
		check_button_11,
		check_button_12,
]


func _set_check_buttons_from_dvc():
	var dvc := GlobalUIInfo.get_dev_visuals_config()
	for button: CheckButton in ui_check_button_array:
		if not button:
			error_.warn("null button in ui_check_button_array", "_set_check_buttons_from_dvc", "", WL.WARN)
			continue
		var type_ := __get_overlay_panel_type_by_button_name(button.name)
		if type_ != -1:
			button.set_pressed_no_signal(dvc.is_global_ui_panel_active(type_))
			continue
		
		var pair_type: Array = __get_matrix_cdv_type_by_button_name(button.name)
		if __valid_pair_type(pair_type):
			button.set_pressed_no_signal(dvc.is_active_cdv(pair_type[0], pair_type[1]))
			continue

		error_.warn("button name was't found in any dict", "_set_check_buttons_from_dvc", "", WL.WARN, button.name)


func _set_spin_boxes_from_dvc():
	var dvc := GlobalUIInfo.get_dev_visuals_config()
	for spin_box: UIOverlaySpinBox in ui_spin_boxes_array:
		if not spin_box:
			error_.warn("null spin_box in ui_spin_boxes_array", "_set_spin_boxes_from_dvc", "", WL.WARN)
			continue
		spin_box.set_value_no_signal(dvc.get_value(spin_box.overlay_value_type))
		

func _update_dvc_from_check_button(button_name: String, toggle: bool):
	var dev_visuals_config := GlobalUIInfo.get_dev_visuals_config()

	var type_ := __get_overlay_panel_type_by_button_name(button_name)
	if type_ != -1:
		dev_visuals_config.set_active_global_ui_panel(type_, toggle)
		return
	
	var pair_type: Array = __get_matrix_cdv_type_by_button_name(button_name)
	if __valid_pair_type(pair_type):
		dev_visuals_config.set_active_cdv(pair_type[0], pair_type[1], toggle)
		return

	error_.warn("button name was't found in any dict", "_update_dvc_from_check_button", "", WL.WARN, button_name)


func _update_dvc_from_spin_box(type_: DevVisualsConfig.ValueType, value: float):
	var dev_visuals_config := GlobalUIInfo.get_dev_visuals_config()
	dev_visuals_config.set_value(type_, value)
	

func _on_SIG_ui_overlay_check_button_toggled(payload: Dictionary[String, Variant]):
	var _r_toggle := SigUtils.safe_get_toggle_payload_value(payload)
	if _r_toggle.err: return

	var _r_button_name := SigUtils.safe_get_string_payload_value(payload, SPS.button_name_field)
	if _r_button_name.err: return

	_update_dvc_from_check_button(_r_button_name.value, _r_toggle.value)


func _on_SIG_ui_overlay_spin_box_value_changed(payload: Dictionary[String, Variant]):
	var _r_value := SigUtils.safe_get_int_float_payload_value(payload, SPS.value_field)
	if _r_value.err: return

	var _r_type := SigUtils.safe_get_int_payload_value(payload, SPS.type_field)
	if _r_type.err: return

	_update_dvc_from_spin_box(_r_type.value, _r_value.value)


## HELPERS


func __valid_pair_type(pair_type: Array[Variant]) -> bool:
	var _r := len(pair_type) == 2 and pair_type[0] is int and pair_type[1] is int
	if not _r:
		error_.warn("not valid pair", "__valid_pair_type", "false", WL.WARN, pair_type)
	return _r

## returns -1 in case of problems
func __get_overlay_panel_type_by_button_name(button_name: String, warn_level: String = WL.SILENT) -> int:
	var _r = DictUtils.safe_get_dict_key(button_name_to_overlay_panel_type, button_name, -1, warn_level)
	return _r


## returns [] in case of problems
func __get_matrix_cdv_type_by_button_name(button_name: String, warn_level: String = WL.SILENT) -> Array:
	var _r = DictUtils.safe_get_dict_key(button_name_to_matrix_cdv_type, button_name, [], warn_level)
	return _r
