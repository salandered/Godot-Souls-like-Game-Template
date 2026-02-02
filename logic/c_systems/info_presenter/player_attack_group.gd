@tool
extends BaseInfoGroupPresenter


@onready var player_attack_group: BluePanelBottomless = %PlayerAttackGroup

@onready var player_attack_damage: DynamicInfoLabel = %PlayerAttackDamage
@onready var player_attack_speed: DynamicInfoLabel = %PlayerAttackSpeed
@onready var player_attack_direction: DynamicInfoLabel = %PlayerAttackDirection


func get_char_type() -> DevVisualsConfig.CharacterType:
	return DevVisualsConfig.CharacterType.PLAYER


func get_dv_type() -> DevVisualsConfig.DevVisualsType:
	return DevVisualsConfig.DevVisualsType.ATTACK_INFO


func _supported_signal_pairs() -> Array[Array]:
	var sig_to_handler: Array[Array] = [
		[GlobalSignal.SIG_player_weapon_hit_data_set, _on_SIG_player_weapon_hit_data_set],

	]
	return sig_to_handler


func _on_SIG_player_weapon_hit_data_set(payload: Dictionary[String, Variant]):
	# __log_("_on_SIG_player_weapon_hit_data_set", payload)
	_on_SIG_hit_data_payload(
		player_attack_damage,
		player_attack_speed,
		player_attack_direction,
		payload,
		10.0,
		44.0,
		dlc_all_features_preset)


func _get_group_panel() -> BluePanelBottomless:
	return player_attack_group


func _get_group_info_labels() -> Array[DynamicInfoLabel]:
	return [
		player_attack_damage,
		player_attack_speed,
		player_attack_direction
	]


func _get_title() -> String:
	return "Player Attack Info"
