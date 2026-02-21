@tool
extends BaseInfoGroupPresenter


@onready var se_state_info: DynamicInfoLabel = %SEStateInfo
@onready var se_reaction_info: DynamicInfoLabelDouble = %SEReactionInfo


# func _ready_imp():
# 	se_reaction_info.set_second_text_label("")

func _get_char_type() -> DVS.CharacterType:
	return DVS.CharacterType.SIMPLE_ENEMY


func _get_dv_type() -> DVS.CharDVType:
	return DVS.CharDVType.STATE_INFO


func _supported_signal_pairs() -> Array[Array]:
	var sig_to_handler: Array[Array] = [
		[GlobalSignal.SIG_enemy_state_changed, _on_SIG_enemy_state_changed],
		[GlobalSignal.SIG_enemy_reacted_on_hit, _on_SIG_se_reacted_on_hit],

	]
	return sig_to_handler


func _on_SIG_enemy_state_changed(payload: Dictionary[StringName, Variant]):
	_on_SIG_string_payload(se_state_info, payload, SPS.state_name_field, _str_replacers, dlc_all_features_preset)


func _on_SIG_se_reacted_on_hit(payload: Dictionary[StringName, Variant]):
	se_reaction_info.set_label_text("next attack", dlc_all_features_and_italics_preset)
	

static var _str_replacers: Dictionary[String, String] = {
		"attack_lr": "attack_L->R",
		"attack_rl": "attack_R->L",
		"power": "Powerful",
	}


func _get_group_info_labels() -> Array[DynamicInfoLabel]:
	return [
		se_state_info,
		se_reaction_info,
	]


func _get_title() -> String:
	return "Simple Enemy State Info"
