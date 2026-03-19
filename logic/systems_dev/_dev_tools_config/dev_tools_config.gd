class_name DevVisualsConfig
extends RefCountedSystem


## SIGNALS

var _value_changed: Signal


## DATA

## Dictionary[DTS.DVSection, Dictionary[int <section key>, Variant <actual value>]]
var _data: Dictionary[DTS.DTSection, Dictionary]


func __hard_validation() -> bool:
	if error_.null_signal(_value_changed):
		return false
	return true


func _init(value_changed_: Signal) -> void:
	self._value_changed = value_changed_

	## 
	var _panel_data: Dictionary[DTS.KeyBOverlayPanel, bool] = {}
	for item in DTS.KeyBOverlayPanel.values():
		_panel_data[item] = false
	_panel_data[DTS.KeyBOverlayPanel.RAW_INPUT] = true

	_data[DTS.DTSection.B_OVERLAY_PANEL] = _panel_data


	##
	var _b_vc_data: Dictionary[DTS.KeyBValueChanger, bool] = {}
	for item in DTS.KeyBValueChanger.values():
		_b_vc_data[item] = false
	_b_vc_data[DTS.KeyBValueChanger.WEAPON_HIT_SHADED] = DVHitBoxAreaContact.DEF_SHADED == BaseMaterial3D.SHADING_MODE_PER_PIXEL
	_b_vc_data[DTS.KeyBValueChanger.WEAPON_HIT_SNAPPED_HITS] = DVHitBoxAreaContact.DEF_draw_snapped_hits
	_b_vc_data[DTS.KeyBValueChanger.PLAYER_LIGHTS] = true
	
	_data[DTS.DTSection.B_CHANGER] = _b_vc_data

	##
	var _s_vs_data: Dictionary[DTS.KeySValueChanger, String] = {}
	for item in DTS.KeySValueChanger.values():
		_s_vs_data[item] = ""
	
	_s_vs_data[DTS.KeySValueChanger.DV_SPECTRUM_AUDIO_BUS] = Const.SFX_ASP_BASE_BUS_ID

	_data[DTS.DTSection.S_CHANGER] = _s_vs_data

	##
	var _f_vc_data: Dictionary[DTS.KeyFValueChanger, float] = {}
	for item in DTS.KeyFValueChanger.values():
		_f_vc_data[item] = -1.0
	
	_f_vc_data[DTS.KeyFValueChanger.GHOST_DUR_SEC] = DynamicInfoLabel.DEF_WAIT_SEC
	_f_vc_data[DTS.KeyFValueChanger.GRID_V_SEP] = GlobalUIInfo.DEF_DYNAMIC_GRID_V_SEP
	_f_vc_data[DTS.KeyFValueChanger.WEAPON_HIT_DUR] = DVHitBoxAreaContact.BASE_DUR
	_f_vc_data[DTS.KeyFValueChanger.PL_SPEED_SCALE] = 1.0
	_f_vc_data[DTS.KeyFValueChanger.HSM_SPEED_SCALE] = 1.0
	_f_vc_data[DTS.KeyFValueChanger.SE_SPEED_SCALE] = 1.0
	
	_data[DTS.DTSection.F_CHANGER] = _f_vc_data

	##
	var _color_vc_data: Dictionary[DTS.KeyColorChanger, Color] = {}
	for item in DTS.KeyColorChanger.values():
		_color_vc_data[item] = DTS.DEF_OFF_COLOR
	
	_data[DTS.DTSection.COLOR_CHANGER] = _color_vc_data


	## 
	var _matrix_data: Dictionary[int, bool] = {}

	for char_type in DTS.CharacterType.values():
		for dv_type in DTS.CharDVType.values():
			var _r_composite_key := DTS.key_char_dv(char_type, dv_type)
			if not _r_composite_key == -1:
				_matrix_data[_r_composite_key] = false

	_data[DTS.DTSection.B_CHAR_DV] = _matrix_data
	
	__perform_validation()


## API

func set_value(
		section: DTS.DTSection,
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
		SigUtils.safe_emit(_value_changed, {
			SPS.dtc_section_field: section,
			SPS.dtc_key_field: key_,
			SPS.dtc_value_field: value_}
		)


func add_fvalue(
		section: DTS.DTSection,
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
		section: DTS.DTSection,
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
		section: DTS.DTSection,
		char_t: DTS.CharacterType,
		char_dv: DTS.CharDVType,
		emit_signal_: bool = true
	) -> void:
	if not __validation_ok():
		__log_warn_soft("can't process request")
		return
	toggle_bvalue(section, DTS.key_char_dv(char_t, char_dv), emit_signal_)


## SUGAR API. bloats the config, but lets see how it goes
# region


func toggle_bvalue_array(
		section: DTS.DTSection,
		keys_: Array[int],
		emit_signal_: bool = true
	) -> void:
	if not __validation_ok():
		__log_warn_soft("can't process request")
		return
	for k in keys_:
		toggle_bvalue(section, k, emit_signal_)


func toggle_all_char_dv_options(
	char_dv: DTS.CharDVType,
) -> void:
	if not __validation_ok():
		__log_warn_soft("can't process request")
		return
	
	var char_types := EnumUtils.get_values_excluding_unknown(DTS.CharacterType)
	
	for char_type in char_types:
		toggle_bvalue_composite_key(
			DTS.DTSection.B_CHAR_DV,
			char_type,
			char_dv,
		)


func toggle_all_char_t_options(
	char_t: DTS.CharacterType,
) -> void:
	if not __validation_ok():
		__log_warn_soft("can't process request")
		return

	var dv_types := EnumUtils.get_values_excluding_unknown(DTS.CharDVType)

	for dv_type in dv_types:
		toggle_bvalue_composite_key(
			DTS.DTSection.B_CHAR_DV,
			char_t,
			dv_type,
		)

# endregion


## returns INF in case of problem
func fget_value(section: DTS.DTSection, key_: int) -> float:
	var value: Variant = _get_typed_value(
		section,
		key_,
		func(v): return v is float,
		INF
	)
	return value as float


## returns "" in case of problem
func sget_value(section: DTS.DTSection, key_: int) -> String:
	var value: Variant = _get_typed_value(
		section,
		key_,
		func(v): return v is String,
		""
	)
	return value as String


## returns false in case of problem
func bget_value(section: DTS.DTSection, key_: int) -> bool:
	var value: Variant = _get_typed_value(
		section,
		key_,
		func(v): return v is bool,
		false
	)
	return value as bool

## returns false in case of problem
func color_get_value(section: DTS.DTSection, key_: int) -> Color:
	var value: Variant = _get_typed_value(
		section,
		key_,
		func(v): return v is Color,
		DTS.DEF_OFF_COLOR
	)
	return value as Color


## INTERNAL

func _get_by_section_and_key(section: DTS.DTSection, key_: int) -> RO.VariantReturn:
	if not _check_path_exists(section, key_):
		return RO.VariantReturn.new(true)
	return RO.VariantReturn.new(false, _data[section][key_])


func _check_path_exists(section: DTS.DTSection, key_: int) -> bool:
	if not DictUtils.safe_has_key(_data, section):
		__log_warn_soft("section does not exist", "", "", section, key_)
		return false
	if not DictUtils.safe_has_key(_data[section], key_):
		__log_warn_soft("key does not exist", "", "", section, key_)
		return false
	return true


func _get_typed_value(section: DTS.DTSection, key_: int, type_filter: Callable, value_on_error: Variant) -> Variant:
	if not __validation_ok():
		__log_warn_soft("can't process request")
		return value_on_error
	var _r := _get_by_section_and_key(section, key_)
	if _r.err or not type_filter.call(_r.value):
		return value_on_error
	return _r.value
