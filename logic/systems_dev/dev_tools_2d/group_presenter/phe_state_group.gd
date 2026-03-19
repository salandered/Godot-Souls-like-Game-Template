@tool
extends BaseInfoGroupPresenter


@onready var state_info_phe_2: DynamicInfoLabel = %StateInfoPheDepth2
@onready var state_info_phe_3: DynamicInfoLabel = %StateInfoPheDepth3
@onready var state_info_phe_4: DynamicInfoLabel = %StateInfoPheDepth4
@onready var state_info_phe_leaf: DynamicInfoLabel = %StateInfoPheLeaf
@onready var phe_reaction_info: DynamicInfoLabelDouble = %PHEReactionInfo


var depth_to_label: Dictionary[int, DynamicInfoLabel]


func _get_char_type() -> DTS.CharacterType:
	return DTS.CharacterType.HSM_ENEMY


func _get_dv_type() -> DTS.CharDVType:
	return DTS.CharDVType.STATE_INFO


func _ready():
	super._ready()
	depth_to_label = {
		# 1: state_info_phe_1, ## NOTE: turned off: first level is Life, currently never changes
		2: state_info_phe_2,
		3: state_info_phe_3,
		4: state_info_phe_4,
		-1: state_info_phe_leaf,
	}


func _supported_signal_pairs() -> Array[Array]:
	var sig_to_handler: Array[Array] = [
		[GlobalSignal.SIG_phe_state_changed, _on_SIG_phe_state_changed],
		[GlobalSignal.SIG_phe_state_reset, _on_SIG_phe_state_reset],
		[GlobalSignal.SIG_enemy_reacted_on_hit, _on_SIG_enemy_reacted_on_hit],


	]
	return sig_to_handler


func _on_SIG_phe_state_changed(payload: Dictionary[StringName, Variant]):
	var tag := _get_SIG_sname_payload(payload, SPS.tag_field)
	if tag != Const.DEMO_ENEMY_TAG:
		return
	var h_state_data := _get_SIG_h_state_data(payload)
	var selected_label: DynamicInfoLabel = DictUtils.safe_get_dict_key(depth_to_label, h_state_data.state_depth, null, WL.SILENT)
	if not selected_label:
		return
	
	var pp_string := h_state_data.state_name
	pp_string = StrUtils.replace_text_fragments(pp_string, _str_replacers)
	selected_label.set_label_text(pp_string, dlc_all_features_preset)


func _on_SIG_phe_state_reset(payload: Dictionary[StringName, Variant]):
	var h_state_data := _get_SIG_h_state_data(payload)
	var selected_label: DynamicInfoLabel = DictUtils.safe_get_dict_key(depth_to_label, h_state_data.state_depth)
	if not selected_label:
		return
	if selected_label == state_info_phe_leaf:
		return
	
	selected_label.set_label_text("", dlc_all_features_preset)
		

func _on_SIG_enemy_reacted_on_hit(payload: Dictionary[StringName, Variant]):
	_on_SIG_react_on_hit(phe_reaction_info, payload, _str_react_replacers, dlc_all_features_preset)


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


func _get_group_info_labels() -> Array[DynamicInfoLabel]:
	return [
		state_info_phe_2,
		state_info_phe_3,
		state_info_phe_4,
		state_info_phe_leaf,
		phe_reaction_info
	]


func _get_title() -> String:
	return "Enemy Hierarchical State Machine Info"
