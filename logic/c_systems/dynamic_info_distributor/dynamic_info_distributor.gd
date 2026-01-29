extends BaseDynamicInfoDistributor
class_name PlayerDynamicInfoDistributor

@onready var dynamic_info: MarginContainer = %DynamicInfo

@onready var state_info: DynamicInfoLabel = %StateInfo
@onready var action_info: DynamicInfoLabel = %ActionInfo
@onready var attack_info: DynamicInfoLabelDouble = %AttackInfo
@onready var enemy_attack_info: DynamicInfoLabel = %EnemyAttackInfo
@onready var reaction_info: DynamicInfoLabel = %ReactionInfo

func __hard_dependencies() -> Array:
	return [
		dynamic_info,
		state_info,
		action_info,
		attack_info,
		enemy_attack_info,
		reaction_info,
	]


func _supported_signal_pairs() -> Array[Array]:
	var sig_to_handler: Array[Array] = [
		[GlobalSignal.SIG_player_state_changed, _on_SIG_player_state_changed],
		[GlobalSignal.SIG_player_action_changed, _on_SIG_player_action_changed],
		[GlobalSignal.SIG_player_weapon_hit_data_set, _on_SIG_player_weapon_hit_data_set],
		[GlobalSignal.SIG_player_react_on_hit, _on_SIG_player_react_on_hit],

	]
	return sig_to_handler


func _on_SIG_player_state_changed(payload: Dictionary[String, Variant]):
	_on_SIG_string_payload(state_info, payload, GlobalSignal.payload_state_name_field, {}, dlc_all_features_preset)


func _on_SIG_player_action_changed(payload: Dictionary[String, Variant]):
	_on_SIG_string_payload(action_info, payload, GlobalSignal.payload_state_name_field, _str_replacers, dlc_all_features_preset)


func _on_SIG_player_weapon_hit_data_set(payload: Dictionary[String, Variant]):
	_on_SIG_hit_data_payload(attack_info, payload, 10.0, 44.0, dlc_all_features_preset)


func _on_SIG_player_react_on_hit(payload: Dictionary[String, Variant]):
	_on_SIG_react_on_hit(enemy_attack_info, reaction_info, payload, _str_react_replacers, dlc_all_features_preset)


static var _str_react_replacers: Dictionary[String, String] = {
		A.react.head_B_large: "head impact",
		A.react.react_from_R: "react_from_R",
		A.react.react_from_L: "react_from_L",
		A.react.react_gut: "react_gut",
	}


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


## WARNING: dict key are not ordered i suppose
static var _str_replacers: Dictionary[String, String] = {
		"pla_": "",
		"la_": "",
		"🖊️": "",
		"✏️": "",
	}


func _reset_text(value: bool):
	state_info.reset_text()
	action_info.reset_text()
	attack_info.reset_text()
	enemy_attack_info.reset_text()
	reaction_info.reset_text()


func _set_container_visible(value: bool) -> void:
	if dynamic_info:
		dynamic_info.visible = value


func _is_visible() -> bool:
	return dynamic_info.visible
