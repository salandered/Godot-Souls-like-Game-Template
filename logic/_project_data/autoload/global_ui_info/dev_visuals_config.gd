class_name DevVisualsConfig
extends RefCountedSystem


## SIGNALS

var _value_changed: Signal


## DATA

## Dictionary[DVS.DVSection, Dictionary[int <section key>, Variant <actual value>]]
var _data: Dictionary[DVS.DVSection, Dictionary]


func __hard_validation() -> bool:
	if error_.null_signal(_value_changed):
		return false
	return true


func _init(value_changed_: Signal) -> void:
	self._value_changed = value_changed_

	## 
	var _panel_data: Dictionary[DVS.KeyOverlayPanel, bool] = {}
	for item in DVS.KeyOverlayPanel.values():
		_panel_data[item] = false

	_data[DVS.DVSection.OVERLAY_PANEL] = _panel_data


	##
	var _value_data: Dictionary[DVS.KeyValueChanger, Variant] = {}
	_value_data = {
		DVS.KeyValueChanger.GHOST_DUR_SEC: DynamicInfoLabel.DEF_WAIT_SEC,
		DVS.KeyValueChanger.GRID_V_SEP: GlobalUIInfo.DEF_DYNAMIC_GRID_V_SEP,
		DVS.KeyValueChanger.SIG_FILTER: "",
		DVS.KeyValueChanger.ALL_LOG_FILTER: "",
		DVS.KeyValueChanger.ERROR_LOG_FILTER: "",
		DVS.KeyValueChanger.WEAPON_HIT: false,
		DVS.KeyValueChanger.WEAPON_HIT_EVERY_FRAME: false,
	}
	
	_data[DVS.DVSection.VALUE_CHANGER] = _value_data

	## 
	var _matrix_data: Dictionary[int, bool] = {}

	for char_type in DVS.CharacterType.values():
		for dv_type in DVS.CharDVType.values():
			var _r_composite_key := DVS.key_char_dv(char_type, dv_type)
			if not _r_composite_key.err:
				_matrix_data[_r_composite_key.value] = false

	_data[DVS.DVSection.CHAR_DV] = _matrix_data
	
	__perform_validation()


## API

func set_value(
		section: DVS.DVSection,
		key_: int,
		value_: Variant,
		emit_signal_: bool = true
	) -> void:
	if not __validation_ok():
		__log_warn_soft("can't process request")
		return
	if not _check_path_exists(section, key_):
		return

	_data[section][key_] = value_

	if emit_signal_:
		SigUtils.safe_emit_raw(_value_changed, {
			SPS.dvc_section_field: section,
			SPS.dvc_key_field: key_,
			SPS.dvc_value_field: value_}
		)


## returns INF in case of problem
func fget_value(section: DVS.DVSection, key_: int) -> float:
	var value: Variant = _get_typed_value(
		section,
		key_,
		func(v): return v is float,
		INF
	)
	return value as float


## returns "" in case of problem
func sget_value(section: DVS.DVSection, key_: int) -> String:
	var value: Variant = _get_typed_value(
		section,
		key_,
		func(v): return v is String,
		""
	)
	return value as String


## returns false in case of problem
func bget_value(section: DVS.DVSection, key_: int) -> bool:
	var value: Variant = _get_typed_value(
		section,
		key_,
		func(v): return v is bool,
		false
	)
	return value as bool


## INTERNAL

func _get_by_section_and_key(section: DVS.DVSection, key_: int) -> RO.VariantReturn:
	if not _check_path_exists(section, key_):
		return RO.VariantReturn.new(true)
	return RO.VariantReturn.new(false, _data[section][key_])


func _check_path_exists(section: DVS.DVSection, key_: int) -> bool:
	if not DictUtils.safe_has_key(_data, section):
		__log_warn_soft("section does not exist", "", "", section, key_)
		return false
	if not DictUtils.safe_has_key(_data[section], key_):
		__log_warn_soft("key- does not exist", "", "", section, key_)
		return false
	return true


func _get_typed_value(section: DVS.DVSection, key_: int, type_filter: Callable, value_on_error: Variant) -> Variant:
	if not __validation_ok():
		__log_warn_soft("can't process request")
		return value_on_error
	var _r := _get_by_section_and_key(section, key_)
	if _r.err or not type_filter.call(_r.value):
		return value_on_error
	return _r.value
