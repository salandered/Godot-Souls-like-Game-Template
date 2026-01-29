@abstract
class_name BaseDynamicInfoDistributor
extends NodeSystem


var dlc_all_features_preset := DynamicLabelConfig.new(true, true, true)
var dlc_all_features_and_italics_preset := DynamicLabelConfig.new(true, true, true, false, true)


func _ready():
	if not __perform_validation():
		_set_container_visible(false)
		_ready_imp()

func _ready_imp():
	pass


func _on_SIG_string_payload(
	dynamic_label: DynamicInfoLabel,
	payload: Dictionary[String, Variant],
	field_name: String,
	str_replacers: Dictionary[String, String],
	dynamic_label_config: DynamicLabelConfig
):
	if not dynamic_label:
		return
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
	if not dynamic_label:
		return
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
			false, ## not italics
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


func _on_SIG_react_on_hit(
	opponent_attack_info: DynamicInfoLabel,
	reaction_info: DynamicInfoLabel,
	payload: Dictionary[String, Variant],
	_str_react_replacers_: Dictionary[String, String],
	dynamic_label_config: DynamicLabelConfig
):
	var _r_attack_dir := SigUtils.safe_get_string_payload_value(payload, GlobalSignal.payload_attack_dir_field)
	var attack_dir_pp_string = ""
	if not _r_attack_dir.err:
		attack_dir_pp_string = _r_attack_dir.value
	var _r_interruption := SigUtils.safe_get_bool_payload_value(payload, GlobalSignal.payload_interruption_field)
	var interruption_pp_string = ""
	if not _r_interruption.err:
		interruption_pp_string = "[i]" + ("Yes" if _r_interruption.value else "No") + "[/i]"
		interruption_pp_string = StrUtils.replace_text_fragments(interruption_pp_string, {})
	var _r_reaction := SigUtils.safe_get_string_payload_value(payload, GlobalSignal.payload_reaction)
	var reaction_pp_string = ""
	if not _r_reaction.err:
		reaction_pp_string = _r_reaction.value
		reaction_pp_string = StrUtils.replace_text_fragments(reaction_pp_string, _str_react_replacers_)

	if attack_dir_pp_string and interruption_pp_string and reaction_pp_string:
		var dir_interrupt_pp_str := pp.s(attack_dir_pp_string, "  ", interruption_pp_string)
		
		if opponent_attack_info:
			opponent_attack_info.set_label_text(dir_interrupt_pp_str, dlc_all_features_preset)
		if reaction_info:
			reaction_info.set_label_text(reaction_pp_string, dlc_all_features_preset)


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

	_reset_text(value)

	var pairs := _supported_signal_pairs()
	if value:
		SigUtils.safe_connect_pairs(pairs)
	else:
		SigUtils.safe_disconnect_pairs(pairs)


@abstract func _reset_text(value: bool)


@abstract func _set_container_visible(value: bool) -> void


@abstract func _supported_signal_pairs() -> Array[Array]


func is_visible() -> bool:
	if not __validation_ok(): return false
	return _is_visible()


@abstract func _is_visible() -> bool
