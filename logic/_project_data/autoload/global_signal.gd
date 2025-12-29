extends Node


## AUTOLOAD

## Here can be added signals which are consumed in one place only.

signal _SIG_player_change_health(payload: Dictionary[String, Variant])
signal _SIG_player_stamina_increase(payload: Dictionary[String, Variant])
signal _SIG_player_speed_increase(payload: Dictionary[String, Variant])
signal _SIG_player_dodge_increase(payload: Dictionary[String, Variant])


signal _SIG_show_tut()
signal _SIG_hid_tut()


var player_change_health := SignalData.new(
	SignalID.player_change_health,
	_SIG_player_change_health
)

var player_stamina_increase := SignalData.new(
	SignalID.player_stamina_increase,
	_SIG_player_stamina_increase
)

var player_speed_increase := SignalData.new(
	SignalID.player_speed_increase,
	_SIG_player_speed_increase
)

var player_dodge_increase := SignalData.new(
	SignalID.player_dodge_increase,
	_SIG_player_dodge_increase
)


const payload_amount_field := "amount"
