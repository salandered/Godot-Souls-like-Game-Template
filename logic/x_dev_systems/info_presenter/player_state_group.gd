@tool
extends BaseInfoGroupPresenter


@onready var pl_state_info: DynamicInfoLabel = %PlayerStateInfo
@onready var pl_action_info: DynamicInfoLabel = %PlayerActionInfo
@onready var pl_legs_state: DynamicInfoLabel = %PlayerLegsState
@onready var pl_reaction_info: DynamicInfoLabelDouble = %PlayerReactionInfo


func _get_char_type() -> DVS.CharacterType:
	return DVS.CharacterType.PLAYER


func _get_dv_type() -> DVS.CharDVType:
	return DVS.CharDVType.STATE_INFO


func _supported_signal_pairs() -> Array[Array]:
	var sig_to_handler: Array[Array] = [
		[GlobalSignal.SIG_player_state_changed, _on_SIG_player_state_changed],
		[GlobalSignal.SIG_player_leg_beh_changed, _on_SIG_player_leg_beh_changed],
		[GlobalSignal.SIG_player_action_changed, _on_SIG_player_action_changed],
		[GlobalSignal.SIG_player_reacted_on_hit, _on_SIG_player_reacted_on_hit],

	]
	return sig_to_handler


func _on_SIG_player_state_changed(payload: Dictionary[StringName, Variant]):
	_on_SIG_string_payload(pl_state_info, payload, SPS.state_name_field, {}, dlc_all_features_preset)


func _on_SIG_player_leg_beh_changed(payload: Dictionary[StringName, Variant]):
	pass
	# _on_SIG_string_payload(pl_legs_state, payload, SPS.state_name_field, _str_beh_replacers, dlc_all_features_preset)


func _on_SIG_player_action_changed(payload: Dictionary[StringName, Variant]):
	_on_SIG_string_payload(pl_action_info, payload, SPS.state_name_field, _str_action_replacers, dlc_all_features_preset)


func _on_SIG_player_reacted_on_hit(payload: Dictionary[StringName, Variant]):
	_on_SIG_react_on_hit(pl_reaction_info, payload, _str_react_replacers, dlc_all_features_preset)


static var _str_react_replacers: Dictionary[String, String] = {
		A.react.head_B_large: "head impact",
		A.react.react_from_R: "react_from_R",
		A.react.react_from_L: "react_from_L",
		A.react.react_gut: "react_gut",
	}


## WARNING: dict key are not ordered i suppose
static var _str_action_replacers: Dictionary[String, String] = {
		"pla_": "",
		"la_": "",
		"🖊️": "",
		"✏️": "",
		"↻": ""
	}

static var _str_beh_replacers: Dictionary[String, String] = {
		"l_behavior_double": "<waiting>",
		"l_behavior": "",
	}


func _get_group_info_labels() -> Array[DynamicInfoLabel]:
	return [
		pl_state_info,
		pl_legs_state,
		pl_action_info,
		pl_reaction_info
	]


func _get_title() -> String:
	return "Player State Info"
