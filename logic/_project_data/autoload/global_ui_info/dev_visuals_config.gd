class_name DevVisualsConfig
extends RefCountedSystem


enum ValueType {
	UNKNOWN, # 0
	GHOST_DUR_SEC, # 1
	GRID_V_SEP, # 2
	}


enum OverlayPanelType {
	TUT, # 0
	PROFILER, # 1
	CAM_NODES # 2
	}

enum CharacterType {
	UNKNOWN, # 0
	PLAYER, # 1
	HSM_ENEMY, # 2
	SIMPLE_ENEMY # 3
	}

enum DevVisualsType {
	STATE_INFO, # 0
	ATTACK_INFO, # 1
	WEAPON_TRAIL, # 2
	HITBOX # 3
	}


## SIGNALS

var _value_changed: Signal
var _global_ui_panel_toggled: Signal
var _matrix_cdv_toggled: Signal


## DATA

var _value_data: Dictionary[ValueType, float] = {}
# can be reduced to _value_data using 0.0/1.0
var _panel_data: Dictionary[OverlayPanelType, bool] = {}
# CDV matrix. type: Dictionary[CharacterType, Dictionary[DevVisualsType, bool]]
var _matrix_data: Dictionary[CharacterType, Dictionary] = {}


func __hard_validation() -> bool:
	if len(_matrix_data) == 0:
		return false
	if error_.null_signal(_global_ui_panel_toggled):
		return false
	if error_.null_signal(_matrix_cdv_toggled):
		return false
	return true


func _init(value_changed_: Signal, global_ui_panel_toggled_: Signal, matrix_cdv_toggled_: Signal) -> void:
	self._value_changed = value_changed_
	self._global_ui_panel_toggled = global_ui_panel_toggled_
	self._matrix_cdv_toggled = matrix_cdv_toggled_

	_value_data = {
		ValueType.GHOST_DUR_SEC: DynamicInfoLabel.DEF_WAIT_SEC,
		ValueType.GRID_V_SEP: GlobalUIInfo.DEF_DYNAMIC_GRID_V_SEP
	}
	
	for item in OverlayPanelType.values():
		_panel_data[item] = false
	
	## create matrix data
	for char_type in CharacterType.values():
		_matrix_data[char_type] = {}
		for dv_type in DevVisualsType.values():
			_matrix_data[char_type][dv_type] = false
	
	__perform_validation(
)

## CDV MATRIX
# region

func set_active_cdv(char_type: CharacterType, dv_type: DevVisualsType, toggle_value: bool) -> void:
	if not __validation_ok():
		__log_warn_soft("can't process request")
		return
	if DictUtils.safe_has_key(_matrix_data, char_type):
		if DictUtils.safe_has_key(_matrix_data[char_type], dv_type):
			_matrix_data[char_type][dv_type] = toggle_value

			SigUtils.safe_emit_raw(_matrix_cdv_toggled, {
				SPS.char_type_field: char_type,
				SPS.dv_type_field: dv_type,
				SPS.toggle_field: toggle_value
			})


func is_active_cdv(char_type: CharacterType, dv_type: DevVisualsType) -> bool:
	if not __validation_ok():
		__log_warn_soft("can't process request")
		return false
	var _r_1 = DictUtils.safe_get_dict_key(_matrix_data, char_type, null)
	if _r_1 is Dictionary:
		var _r_2 = DictUtils.safe_get_dict_key(_r_1, dv_type, null)
		if _r_2 is bool:
			return _r_2
		else:
			return false
	else:
		return false

# endregion


#OverlayalUIPanel


## GlobalUIPanel

func set_active_global_ui_panel(
		type_: OverlayPanelType,
		toggle_value: bool,
		emit_signal_: bool = true
	) -> void:
	if not __validation_ok():
		__log_warn_soft("can't process request")
		return
	if DictUtils.safe_has_key(_panel_data, type_):
		_panel_data[type_] = toggle_value

		if emit_signal_:
			SigUtils.safe_emit_raw(_global_ui_panel_toggled, {
				SPS.global_ui_panel_type_field: type_,
				SPS.toggle_field: toggle_value}
			)


func is_global_ui_panel_active(type_: OverlayPanelType) -> bool:
	if not __validation_ok():
		__log_warn_soft("can't process request")
		return false
	var _r = DictUtils.safe_get_dict_key(_panel_data, type_, false)
	if _r is bool:
		return _r
	else:
		return false


## Values

func set_value(
		type_: ValueType,
		value_: float,
		emit_signal_: bool = true
	) -> void:
	if not __validation_ok():
		__log_warn_soft("can't process request")
		return
	if DictUtils.safe_has_key(_value_data, type_):
		_value_data[type_] = value_

		if emit_signal_:
			SigUtils.safe_emit_raw(_value_changed, {
				SPS.value_type_field: type_,
				SPS.value_field: value_}
			)


## returns INF in case of problem
func get_value(type_: ValueType) -> float:
	if not __validation_ok():
		__log_warn_soft("can't process request")
		return false
	var _r = DictUtils.safe_get_dict_key(_value_data, type_, null)
	if _r is float:
		return _r
	else:
		return INF
