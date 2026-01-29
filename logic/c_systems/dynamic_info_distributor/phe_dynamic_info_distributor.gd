extends BaseDynamicInfoDistributor
class_name PheDynamicInfoDistributor

@onready var dynamic_info_phe: MarginContainer = %DynamicInfoPhe


@onready var state_info_phe_2: DynamicInfoLabel = %StateInfoPheDepth2
@onready var state_info_phe_3: DynamicInfoLabel = %StateInfoPheDepth3
@onready var state_info_phe_4: DynamicInfoLabel = %StateInfoPheDepth4
@onready var state_info_phe_leaf: DynamicInfoLabel = %StateInfoPheLeaf

@onready var attack_info_phe: DynamicInfoLabelDouble = %AttackInfoPhe

@onready var phe_player_attack_info: DynamicInfoLabel = %PHEPlayerAttackInfo
@onready var phe_reaction_info: DynamicInfoLabel = %PHEReactionInfo


var depth_to_label: Dictionary[int, DynamicInfoLabel]


func __hard_dependencies() -> Array:
	return [
		dynamic_info_phe,
		state_info_phe_2,
		state_info_phe_3,
		state_info_phe_4,
		state_info_phe_leaf,
		attack_info_phe,
		phe_player_attack_info,
		phe_reaction_info
	]


func _ready():
	super._ready()
	depth_to_label = {
		# 1: state_info_phe_1, ## WARNING: turned off: first level is Life, currently never changes
		2: state_info_phe_2,
		3: state_info_phe_3,
		4: state_info_phe_4,
		-1: state_info_phe_leaf,
	}


func _supported_signal_pairs() -> Array[Array]:
	var sig_to_handler: Array[Array] = [
		[GlobalSignal.SIG_phe_state_changed, _on_SIG_phe_state_changed],
		[GlobalSignal.SIG_phe_state_reset, _on_SIG_phe_state_reset],
		[GlobalSignal.SIG_enemy_weapon_hit_data_set, _on_SIG_phe_weapon_hit_data_set],
		[GlobalSignal.SIG_enemy_react_on_hit, _on_SIG_enemy_react_on_hit],


	]
	return sig_to_handler


func _on_SIG_phe_state_changed(payload: Dictionary[String, Variant]):
	var h_state_data := _get_SIG_h_state_data(payload)
	var selected_label: DynamicInfoLabel = DictUtils.safe_get_dict_key(depth_to_label, h_state_data.state_depth)
	if not selected_label:
		return
	
	var pp_string := h_state_data.state_name
	pp_string = StrUtils.replace_text_fragments(pp_string, _str_replacers)
	selected_label.set_label_text(pp_string, dlc_all_features_preset)


func _on_SIG_phe_state_reset(payload: Dictionary[String, Variant]):
	var h_state_data := _get_SIG_h_state_data(payload)
	var selected_label: DynamicInfoLabel = DictUtils.safe_get_dict_key(depth_to_label, h_state_data.state_depth)
	if not selected_label:
		return
	if selected_label == state_info_phe_leaf:
		return
	
	selected_label.set_label_text("", dlc_all_features_preset)
		

func _on_SIG_phe_weapon_hit_data_set(payload: Dictionary[String, Variant]):
	_on_SIG_hit_data_payload(attack_info_phe, payload, 16.0, 40.0, dlc_all_features_preset)


func _on_SIG_enemy_react_on_hit(payload: Dictionary[String, Variant]):
	_on_SIG_react_on_hit(phe_player_attack_info, phe_reaction_info, payload, _str_react_replacers, dlc_all_features_preset)


static var _str_replacers: Dictionary[String, String] = {
		"dodge_B": "dodge Back",
		"dodge_F": "dodge Forward",
		"dodge_L": "dodge Left",
		"dodge_R": "dodge Right",
		"attack_from_dodge_b": "attack from dodge Back",
		"attack_with_dodge_f": "attack with dodge Forward",
		"attack_pick_single": "attack_pick_random🎲"
	}


static var _str_react_replacers: Dictionary[String, String] = {
		PHEA.react.react_from_L: "react_from_L",
		PHEA.react.react_from_R: "react_from_R",
		PHEA.react.react_gut: "react_gut",
		PHEA.react.body_impact: "body_impact",
		PHEA.react.react_dodge_B: "pushback_1",
		PHEA.react.pushback_2: "pushback_2",
	}


func _reset_text(value: bool):
	for label: DynamicInfoLabel in depth_to_label.values():
		label.reset_text()

	attack_info_phe.reset_text()
	phe_player_attack_info.reset_text()
	phe_reaction_info.reset_text()


func _set_container_visible(value: bool) -> void:
	if dynamic_info_phe:
		dynamic_info_phe.visible = value


func _is_visible() -> bool:
	return dynamic_info_phe.visible
