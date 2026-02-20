@tool

@abstract
class_name BaseInfoGroupPresenter
extends NodeSystem


@export var ui_container: Container

var dlc_all_features_preset := DynamicLabelConfig.new(true, true, true)
var dlc_all_features_and_italics_preset := DynamicLabelConfig.new(true, true, true, false, true)


func __hard_validation() -> bool:
	if not ui_container:
		return false
	for item in _get_group_info_labels():
		if not item:
			return false
	return true


func _ready():
	if u.is_editor():
		return

	if not __perform_validation():
		__log_warn_soft("won't be working")
	else:
		_ready_imp()


func _ready_imp():
	pass


func set_enabled(value: bool):
	if not __validation_ok():
		__log_warn_soft("validation failed, can't be enabled")
		return

	if ui_container:
		ui_container.visible = value

	_reset_text(value)

	var pairs := _supported_signal_pairs()
	if value:
		SigUtils.safe_connect_pairs(pairs)
	else:
		SigUtils.safe_disconnect_pairs(pairs)


func is_visible() -> bool:
	if not __validation_ok():
		return false
	if ui_container:
		return ui_container.visible
	else:
		return false


func _reset_text(value: bool):
	for item in _get_group_info_labels():
		if item:
			item.reset_text()


@abstract func _get_char_type() -> DVS.CharacterType


@abstract func _get_dv_type() -> DVS.CharDVType


func get_composite_dvc_key() -> int:
	return DVS.key_char_dv(_get_char_type(), _get_dv_type())


@abstract func _get_title() -> String


@abstract func _get_group_info_labels() -> Array[DynamicInfoLabel]


@abstract func _supported_signal_pairs() -> Array[Array]


## ON SIG HELPERS
# region

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


## returns "" in case of problems
func _get_SIG_string_payload(
	payload: Dictionary[String, Variant],
	field_name: String,
	str_replacers: Dictionary[String, String],
) -> String:
	var _r := SigUtils.safe_get_string_payload_value(payload, field_name)
	if not _r.err:
		var pp_string := _r.value
		pp_string = StrUtils.replace_text_fragments(pp_string, str_replacers)
		return pp_string
	return ""


func _on_SIG_hit_data_payload(
	damage_label: DynamicInfoLabel,
	speed_label: DynamicInfoLabel,
	direction_label: DynamicInfoLabel,
	payload: Dictionary[String, Variant],
	min_dmg: float,
	max_dmg: float,
	dynamic_label_config: DynamicLabelConfig
):
	if not damage_label or not speed_label or not direction_label:
		__log_warn_soft("not damage_label or speed_label or direction_label", "")
		return
	var _r := SigUtils.safe_get_variant_payload_value(payload, SPS.hit_data_field, false)
	if _r.err or _r.value is not HitData:
		__log_warn_soft("_r.err or _r.value is not HitData", "", "", payload, _r.value)
		return
	var hit_data: HitData = _r.value
	var pp_string_dmg := str(int(hit_data.damage))
	var override_color := _get_damage_color(hit_data.damage, min_dmg, max_dmg)

	var dlc_for_dmg := DynamicLabelConfig.new(
		dynamic_label_config.from_snake_case,
		dynamic_label_config.animate_prev,
		dynamic_label_config.adjust_prev_font_size,
		true, ## and bold
		false, ## not italics
		override_color)
	
	damage_label.set_label_text(pp_string_dmg, dlc_for_dmg)
	# __log_("_on_SIG_hit_data_payload", "damage_label.set_label_text(pp_string_dmg, dlc_for_dmg)", pp_string_dmg, payload, _r.value)
	
	var pp_string_speed := str(pp.round_01(hit_data.anim_global_speed_scale))
	speed_label.set_label_text(pp_string_speed, dynamic_label_config)

	var pp_string_attack_dir := AttackDirection.name_(hit_data.attack_dir)
	direction_label.set_label_text(pp_string_attack_dir, dynamic_label_config)


func _get_SIG_h_state_data(payload: Dictionary[String, Variant]) -> SPS.HStateData:
	var _r := SigUtils.safe_get_variant_payload_value(payload, SPS.h_state_data_field, false)
	if _r.err:
		__log_warn("", "", "", payload)
		return null
	if not _r.value is SPS.HStateData:
		__log_warn("", "", "", payload)
		return null
	var h_state_data: SPS.HStateData = _r.value
	return h_state_data


func _on_SIG_react_on_hit(
	reaction_info: DynamicInfoLabelDouble,
	payload: Dictionary[String, Variant],
	_str_react_replacers_: Dictionary[String, String],
	dynamic_label_config: DynamicLabelConfig
):
	var _r_interruption := SigUtils.safe_get_bool_payload_value(payload, SPS.interruption_field)
	if _r_interruption.err: return
	var interruption_pp_string = ""
	interruption_pp_string = "[i]" + ("Yes" if _r_interruption.value else "No") + "[/i]"
	var _r_reaction := SigUtils.safe_get_string_payload_value(payload, SPS.reaction_anim_or_state_field)
	if _r_reaction.err: return
	var reaction_pp_string = ""
	reaction_pp_string = StrUtils.replace_text_fragments(_r_reaction.value, _str_react_replacers_)

	if reaction_info:
		reaction_info.set_label_text(reaction_pp_string, dlc_all_features_preset)
		reaction_info.set_second_text_label(interruption_pp_string, dlc_all_features_preset, true)


func _get_damage_color(dmg: float, min_dmg: float, max_dmg: float) -> Color:
	var t := clampf((dmg - min_dmg) / (max_dmg - min_dmg), 0.0, 1.0)
	# from desaturated B to desaturated R
	var start = Color(0.572, 0.652, 0.812, 1.0)
	var end = Color(0.867, 0.382, 0.382, 1.0)
	
	return start.lerp(end, t)

# endregion
