extends BaseDynamicInfoDistributor
class_name SEDynamicInfoDistributor

@onready var dynamic_info_simple_e: MarginContainer = %DynamicInfoSimpleE

@onready var se_state_info: DynamicInfoLabel = %SEStateInfo
@onready var se_attack_info: DynamicInfoLabelDouble = %SEAttackInfo
@onready var player_attack_info: DynamicInfoLabel = %PlayerAttackInfo
@onready var se_reaction_info: DynamicInfoLabel = %SEReactionInfo


func __hard_dependencies() -> Array:
	return [
		dynamic_info_simple_e,
		se_state_info,
		se_attack_info,
		player_attack_info,
		se_reaction_info
	]

func _supported_signal_pairs() -> Array[Array]:
	var sig_to_handler: Array[Array] = [
		[GlobalSignal.SIG_enemy_state_changed, _on_SIG_enemy_state_changed],
		[GlobalSignal.SIG_enemy_weapon_hit_data_set, _on_SIG_e_weapon_hit_data_set],
		[GlobalSignal.SIG_enemy_react_on_hit, _on_SIG_enemy_react_on_hit],

	]
	return sig_to_handler


func _on_SIG_enemy_state_changed(payload: Dictionary[String, Variant]):
	_on_SIG_string_payload(se_state_info, payload, GlobalSignal.payload_state_name_field, _str_replacers, dlc_all_features_preset)


func _on_SIG_e_weapon_hit_data_set(payload: Dictionary[String, Variant]):
	_on_SIG_hit_data_payload(se_attack_info, payload, 10.0, 25.0, dlc_all_features_preset)


func _on_SIG_enemy_react_on_hit(payload: Dictionary[String, Variant]):
	_on_SIG_react_on_hit(player_attack_info, null, payload, {}, dlc_all_features_preset)
	se_reaction_info.set_label_text("just the next attack type", dlc_all_features_and_italics_preset)


static var _str_replacers: Dictionary[String, String] = {
		"attack_lr": "attack_left_to_right",
		"attack_rl": "attack_right_to_left",
	}


func _reset_text(value: bool):
	se_state_info.reset_text()
	se_attack_info.reset_text()
	player_attack_info.reset_text()
	se_reaction_info.reset_text()


func _set_container_visible(value: bool) -> void:
	if dynamic_info_simple_e:
		dynamic_info_simple_e.visible = value


func _is_visible() -> bool:
	return dynamic_info_simple_e.visible
