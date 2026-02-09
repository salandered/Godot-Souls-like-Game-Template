@tool
extends BaseInfoGroupPresenter


@onready var se_attack_damage: DynamicInfoLabel = %SEAttackDamage
@onready var se_attack_speed: DynamicInfoLabel = %SEAttackSpeed
@onready var se_attack_direction: DynamicInfoLabel = %SEAttackDirection


func _get_char_type() -> DVS.CharacterType:
	return DVS.CharacterType.SIMPLE_ENEMY


func _get_dv_type() -> DVS.CharDVType:
	return DVS.CharDVType.ATTACK_INFO


func _supported_signal_pairs() -> Array[Array]:
	var sig_to_handler: Array[Array] = [
		[GlobalSignal.SIG_enemy_weapon_hit_data_set, _on_SIG_se_weapon_hit_data_set],

	]
	return sig_to_handler


func _on_SIG_se_weapon_hit_data_set(payload: Dictionary[String, Variant]):
	_on_SIG_hit_data_payload(
		se_attack_damage,
		se_attack_speed,
		se_attack_direction,
		payload,
		10.0,
		25.0,
		dlc_all_features_preset)


func _get_group_info_labels() -> Array[DynamicInfoLabel]:
	return [
		se_attack_damage,
		se_attack_speed,
		se_attack_direction
	]


func _get_title() -> String:
	return "Simple Enemy Attack Info"
