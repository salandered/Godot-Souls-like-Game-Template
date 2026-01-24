@abstract
class_name BaseDynamicInfoDistributor
extends NodeSystem


func _ready():
	if not __perform_validation():
		_set_container_visible(false)


func _on_SIG_string_payload(
	dynamic_label: DynamicInfoLabel,
	payload: Dictionary[String, Variant],
	field_name: String,
	str_replacers: Dictionary[String, String],
	dynamic_label_config: DynamicLabelConfig
):
	var _r := SigUtils.safe_get_string_payload_value(payload, field_name)
	if not _r.err:
		var pp_string := _r.value
		pp_string = StrUtils.replace_text_fragments(pp_string, str_replacers)
		dynamic_label.set_label_text(pp_string, dynamic_label_config)


func _on_SIG_hit_data_payload(
	dynamic_label: DynamicInfoLabelDouble,
	payload: Dictionary[String, Variant],
	min_dmg: float,
	max_dmg: float,
	dynamic_label_config: DynamicLabelConfig
):
	var _r := SigUtils.safe_get_variant_payload_value(payload, GlobalSignal.payload_hit_data_field, false)
	if not _r.err and _r.value is HitData:
		var hit_data: HitData = _r.value
		var pp_string_dmg := str(int(hit_data.damage))
		var override_color := _get_damage_color(hit_data.damage, min_dmg, max_dmg)

		var dlc_with_clr := DynamicLabelConfig.new(
			dynamic_label_config.from_snake_case,
			dynamic_label_config.animate_prev,
			dynamic_label_config.adjust_prev_font_size,
			true, ## and bold
			override_color)

		dynamic_label.set_label_text(pp_string_dmg, dlc_with_clr)
		
		var pp_string_speed := str(pp.round_01(hit_data.anim_global_speed_scale))
		dynamic_label.set_second_text_label(pp_string_speed, dynamic_label_config) # no color here


func _get_SIG_h_state_data(payload: Dictionary[String, Variant]) -> GlobalSignal.HStateData:
	var _r := SigUtils.safe_get_variant_payload_value(payload, GlobalSignal.payload_h_state_data_field, false)
	if _r.err:
		__log_warn("", "", "", payload)
		return null
	if not _r.value is GlobalSignal.HStateData:
		__log_warn("", "", "", payload)
		return null
	var h_state_data: GlobalSignal.HStateData = _r.value
	return h_state_data


func _get_damage_color(dmg: float, min_dmg: float, max_dmg: float) -> Color:
	var t := clampf((dmg - min_dmg) / (max_dmg - min_dmg), 0.0, 1.0)
	# from desaturated B to desaturated R
	var start = Color(0.572, 0.652, 0.812, 1.0)
	var end = Color(0.867, 0.382, 0.382, 1.0)
	
	return start.lerp(end, t)


func set_enable(value: bool):
	if not __validation_ok():
		__log_warn_soft("validation failed, can't be enabled")
		return


	_set_container_visible(value)

	_set_enable(value)

	_connect_signals(value)


@abstract func _set_enable(value: bool)


@abstract func _set_container_visible(value: bool) -> void


@abstract func _connect_signals(is_connect: bool)


func is_visible() -> bool:
	if not __validation_ok(): return false
	return _is_visible()


@abstract func _is_visible() -> bool
