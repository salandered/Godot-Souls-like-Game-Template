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
	var _panel_data: Dictionary[DVS.KeyBOverlayPanel, bool] = {}
	for item in DVS.KeyBOverlayPanel.values():
		_panel_data[item] = false
	_panel_data[DVS.KeyBOverlayPanel.RAW_INPUT] = true

	_data[DVS.DVSection.B_OVERLAY_PANEL] = _panel_data


	##
	var _b_vc_data: Dictionary[DVS.KeyBValueChanger, bool] = {}
	for item in DVS.KeyBValueChanger.values():
		_b_vc_data[item] = false
	_b_vc_data[DVS.KeyBValueChanger.WEAPON_HIT_SHADED] = DVHitBoxAreaContact.DEF_SHADED == BaseMaterial3D.SHADING_MODE_PER_PIXEL
	_b_vc_data[DVS.KeyBValueChanger.WEAPON_HIT_SNAPPED_HITS] = DVHitBoxAreaContact.DEF_draw_snapped_hits
	_b_vc_data[DVS.KeyBValueChanger.PLAYER_LIGHTS] = true
	
	_data[DVS.DVSection.B_CHANGER] = _b_vc_data

	##
	var _s_vs_data: Dictionary[DVS.KeySValueChanger, String] = {}
	for item in DVS.KeySValueChanger.values():
		_s_vs_data[item] = ""
	
	_s_vs_data[DVS.KeySValueChanger.DV_SPECTRUM_AUDIO_BUS] = Constants.SFX_ASP_BASE_BUS_ID

	_data[DVS.DVSection.S_CHANGER] = _s_vs_data

	##
	var _f_vc_data: Dictionary[DVS.KeyFValueChanger, float] = {}
	for item in DVS.KeyFValueChanger.values():
		_f_vc_data[item] = -1.0
	
	_f_vc_data[DVS.KeyFValueChanger.GHOST_DUR_SEC] = DynamicInfoLabel.DEF_WAIT_SEC
	_f_vc_data[DVS.KeyFValueChanger.GRID_V_SEP] = GlobalUIInfo.DEF_DYNAMIC_GRID_V_SEP
	_f_vc_data[DVS.KeyFValueChanger.WEAPON_HIT_DUR] = DVHitBoxAreaContact.BASE_DUR
	_f_vc_data[DVS.KeyFValueChanger.PL_SPEED_SCALE] = 1.0
	_f_vc_data[DVS.KeyFValueChanger.HSM_SPEED_SCALE] = 1.0
	_f_vc_data[DVS.KeyFValueChanger.SE_SPEED_SCALE] = 1.0
	
	_data[DVS.DVSection.F_CHANGER] = _f_vc_data

	##
	var _color_vc_data: Dictionary[DVS.KeyColorChanger, Color] = {}
	for item in DVS.KeyColorChanger.values():
		_color_vc_data[item] = DVS.DEF_OFF_COLOR
	
	_data[DVS.DVSection.COLOR_CHANGER] = _color_vc_data


	## 
	var _matrix_data: Dictionary[int, bool] = {}

	for char_type in DVS.CharacterType.values():
		for dv_type in DVS.CharDVType.values():
			var _r_composite_key := DVS.key_char_dv(char_type, dv_type)
			if not _r_composite_key == -1:
				_matrix_data[_r_composite_key] = false

	_data[DVS.DVSection.B_CHAR_DV] = _matrix_data
	
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

	if value_ is int:
		value_ = float(value_)
		
	_data[section][key_] = value_

	if emit_signal_:
		SigUtils.safe_emit_raw(_value_changed, {
			SPS.dvc_section_field: section,
			SPS.dvc_key_field: key_,
			SPS.dvc_value_field: value_}
		)


func add_fvalue(
		section: DVS.DVSection,
		key_: int,
		value_to_add: float,
		emit_signal_: bool = true
	) -> void:
	if not __validation_ok():
		__log_warn_soft("can't process request")
		return
	var _r := _get_by_section_and_key(section, key_)
	if _r.err: return
	if not _r.value is float:
		__log_warn_soft("can't add f value, value is not float", "add_fvalue")
		return
	var r_value = _r.value + value_to_add
	set_value(section, key_, r_value, emit_signal_)


func toggle_bvalue(
		section: DVS.DVSection,
		key_: int,
		emit_signal_: bool = true
	) -> void:
	if not __validation_ok():
		__log_warn_soft("can't process request")
		return
	var _r := _get_by_section_and_key(section, key_)
	if _r.err: return
	if not _r.value is bool:
		__log_warn_soft("can't toggle, value is not bool", "toggle_bvalue")
		return
	set_value(section, key_, not _r.value, emit_signal_)


func toggle_bvalue_composite_key(
		section: DVS.DVSection,
		char_t: DVS.CharacterType,
		char_dv: DVS.CharDVType,
		emit_signal_: bool = true
	) -> void:
	if not __validation_ok():
		__log_warn_soft("can't process request")
		return
	toggle_bvalue(section, DVS.key_char_dv(char_t, char_dv), emit_signal_)


## SUGAR API. bloats the config, but lets see how it goes
# region


func toggle_bvalue_array(
		section: DVS.DVSection,
		keys_: Array[int],
		emit_signal_: bool = true
	) -> void:
	if not __validation_ok():
		__log_warn_soft("can't process request")
		return
	for k in keys_:
		toggle_bvalue(section, k, emit_signal_)


func toggle_all_char_dv_options(
	char_dv: DVS.CharDVType,
) -> void:
	if not __validation_ok():
		__log_warn_soft("can't process request")
		return
	
	var char_types := EnumUtils.get_values_excluding_unknown(DVS.CharacterType)
	
	for char_type in char_types:
		toggle_bvalue_composite_key(
			DVS.DVSection.B_CHAR_DV,
			char_type,
			char_dv,
		)


func toggle_all_char_t_options(
	char_t: DVS.CharacterType,
) -> void:
	if not __validation_ok():
		__log_warn_soft("can't process request")
		return

	var dv_types := EnumUtils.get_values_excluding_unknown(DVS.CharDVType)

	for dv_type in dv_types:
		toggle_bvalue_composite_key(
			DVS.DVSection.B_CHAR_DV,
			char_t,
			dv_type,
		)

# endregion


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

## returns false in case of problem
func color_get_value(section: DVS.DVSection, key_: int) -> Color:
	var value: Variant = _get_typed_value(
		section,
		key_,
		func(v): return v is Color,
		DVS.DEF_OFF_COLOR
	)
	return value as Color


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
		__log_warn_soft("key does not exist", "", "", section, key_)
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
