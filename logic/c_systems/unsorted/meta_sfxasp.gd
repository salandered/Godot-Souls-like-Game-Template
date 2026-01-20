class_name MetaASP
extends AudioStreamPlayerLogger

const CURSOR_STYLE_5_TRIMMED = preload("uid://ddxh6lf6328dt")
const IMPACT_SOFT_MEDIUM_003 = preload("uid://com27t7o3xhsm")


const THROTTLE_TIME = 0.4 # min time between sounds

var asp_config := ASPConfig.new(
	-4.0,
	-0.2,
	ASPConfig.DEF_MAX_POLYPHONY,
	ASPConfig.DEF_BUS_ID,
	IMPACT_SOFT_MEDIUM_003)

var secondary_asp_config := ASPConfig.new(
	+0.5,
	-0.2,
	ASPConfig.DEF_MAX_POLYPHONY,
	ASPConfig.DEF_BUS_ID,
	CURSOR_STYLE_5_TRIMMED)


var _can_play := true

const _SECONDARY_ASP_NAME := "SecondaryMetaASP"
var _secondary_asp: AudioStreamPlayer

func _ready() -> void:
	__log_("creating _secondary_asp")
	_secondary_asp = AudioStreamPlayer.new()
	_secondary_asp.name = _SECONDARY_ASP_NAME
	self.add_child(_secondary_asp)

	asp_config.set_up_asp(self)
	secondary_asp_config.set_up_asp(_secondary_asp)

	__log_(asp_config)
	__log_(secondary_asp_config)


func _on_princess_sig_stamina_cant_be_paid(signal_payload: Dictionary[String, Variant]) -> void:
	_play_both_asp(0.0)


func _on_princess_sig_switch_weapon_cant_be_done(signal_payload: Dictionary[String, Variant]) -> void:
	_play_both_asp(-0.3, 2.0)


func _play_both_asp(change_pitch: float, change_vol: float = 0.0):
	if not _can_play:
		return

	_secondary_asp.volume_db = secondary_asp_config.get_result_vol() + change_vol
	_secondary_asp.pitch_scale = secondary_asp_config.get_result_pitch() + change_pitch

	_secondary_asp.play()

	await get_tree().create_timer(0.02).timeout
	play()
	# __log_(pp.asp_play(self))
	
	_can_play = false
	await get_tree().create_timer(THROTTLE_TIME).timeout
	_can_play = true


func __LOG_B() -> bool:
	return LogToggler.SFX.META_ASP
