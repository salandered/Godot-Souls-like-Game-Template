extends BaseDynamicInfoDistributor
class_name PlayerDynamicInfoDistributor

@onready var dynamic_info: MarginContainer = %DynamicInfo

@onready var state_info: DynamicInfoLabel = %StateInfo
@onready var action_info: DynamicInfoLabel = %ActionInfo
@onready var attack_info: DynamicInfoLabelDouble = %AttackInfo

func __hard_dependencies() -> Array[Object]:
	return [
		dynamic_info,
		state_info,
		action_info,
		attack_info,
	]


func _connect_signals(is_connect: bool):
	if is_connect:
		SigUtils.safe_connect(GlobalSignal.SIG_player_state_changed, _on_SIG_player_state_changed)
		SigUtils.safe_connect(GlobalSignal.SIG_player_action_changed, _on_SIG_player_action_changed)
		SigUtils.safe_connect(GlobalSignal.SIG_player_weapon_hit_data_set, _on_SIG_player_weapon_hit_data_set)
	else:
		SigUtils.safe_disconnect(GlobalSignal.SIG_player_state_changed, _on_SIG_player_state_changed)
		SigUtils.safe_disconnect(GlobalSignal.SIG_player_action_changed, _on_SIG_player_action_changed)
		SigUtils.safe_disconnect(GlobalSignal.SIG_player_weapon_hit_data_set, _on_SIG_player_weapon_hit_data_set)


var dlc_all_features_on := DynamicLabelConfig.new(true, true, true)

func _on_SIG_player_state_changed(payload: Dictionary[String, Variant]):
	_on_SIG_string_payload(state_info, payload, GlobalSignal.payload_state_name_field, {}, dlc_all_features_on)


func _on_SIG_player_action_changed(payload: Dictionary[String, Variant]):
	_on_SIG_string_payload(action_info, payload, GlobalSignal.payload_state_name_field, _str_replacers, dlc_all_features_on)


func _on_SIG_player_weapon_hit_data_set(payload: Dictionary[String, Variant]):
	_on_SIG_hit_data_payload(attack_info, payload, 10.0, 44.0, dlc_all_features_on)


## WARNING: dict key are not ordered i suppose
static var _str_replacers: Dictionary[String, String] = {
		"pla_": "",
		"la_": "",
		"🖊️": "",
		"✏️": "",
	}


func _set_enable(value: bool):
	state_info.reset_text()
	action_info.reset_text()
	attack_info.reset_text()


func _set_container_visible(value: bool) -> void:
	if dynamic_info:
		dynamic_info.visible = value


func _is_visible() -> bool:
	return dynamic_info.visible
