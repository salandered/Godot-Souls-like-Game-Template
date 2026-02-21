@tool
extends BaseInfoGroupPresenter


@onready var phe_attack_damage: DynamicInfoLabel = %PHEAttackDamage
@onready var phe_attack_speed: DynamicInfoLabel = %PHEAttackSpeed
@onready var phe_attack_direction: DynamicInfoLabel = %PHEAttackDirection


func _get_char_type() -> DVS.CharacterType:
	return DVS.CharacterType.HSM_ENEMY


func _get_dv_type() -> DVS.CharDVType:
	return DVS.CharDVType.ATTACK_INFO


func _supported_signal_pairs() -> Array[Array]:
	var sig_to_handler: Array[Array] = [
		[GlobalSignal.SIG_enemy_weapon_hit_data_set, _on_SIG_phe_weapon_hit_data_set],

	]
	return sig_to_handler


func _on_SIG_phe_weapon_hit_data_set(payload: Dictionary[StringName, Variant]):
	var tag := _get_SIG_string_payload(payload, SPS.tag_field, {})
	if tag != Constants.DEMO_ENEMY_TAG:
		return
	# __log_("_on_SIG_phe_weapon_hit_data_set", payload)
	_on_SIG_hit_data_payload(
		phe_attack_damage,
		phe_attack_speed,
		phe_attack_direction,
		payload,
		15.0,
		30.0,
		dlc_all_features_preset)


func _get_group_info_labels() -> Array[DynamicInfoLabel]:
	return [
		phe_attack_damage,
		phe_attack_speed,
		phe_attack_direction
	]


func _get_title() -> String:
	return "HSM Enemy Attack Info"
