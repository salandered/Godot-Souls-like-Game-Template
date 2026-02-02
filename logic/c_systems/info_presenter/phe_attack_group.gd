@tool
extends BaseInfoGroupPresenter


@onready var phe_attack_group: BluePanelBottomless = %PHEAttackGroup

@onready var phe_attack_damage: DynamicInfoLabel = %PHEAttackDamage
@onready var phe_attack_speed: DynamicInfoLabel = %PHEAttackSpeed
@onready var phe_attack_direction: DynamicInfoLabel = %PHEAttackDirection


func get_char_type() -> DevVisualsConfig.CharacterType:
	return DevVisualsConfig.CharacterType.HSM_ENEMY


func get_dv_type() -> DevVisualsConfig.DevVisualsType:
	return DevVisualsConfig.DevVisualsType.ATTACK_INFO


func _supported_signal_pairs() -> Array[Array]:
	var sig_to_handler: Array[Array] = [
		[GlobalSignal.SIG_enemy_weapon_hit_data_set, _on_SIG_phe_weapon_hit_data_set],

	]
	return sig_to_handler


func _on_SIG_phe_weapon_hit_data_set(payload: Dictionary[String, Variant]):
	__log_("_on_SIG_phe_weapon_hit_data_set", payload)
	_on_SIG_hit_data_payload(
		phe_attack_damage,
		phe_attack_speed,
		phe_attack_direction,
		payload,
		15.0,
		30.0,
		dlc_all_features_preset)


func _get_group_panel() -> BluePanelBottomless:
	return phe_attack_group


func _get_group_info_labels() -> Array[DynamicInfoLabel]:
	return [
		phe_attack_damage,
		phe_attack_speed,
		phe_attack_direction
	]


func _get_title() -> String:
	return "HSM Enemy Attack Info"
