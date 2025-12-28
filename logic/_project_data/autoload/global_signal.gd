extends Node


## AUTOLOAD

## Here can be added signals which are consumed in one place only.

signal _SIG_player_change_health(payload: Dictionary[String, Variant])


var player_change_health := SignalData.new(
	SignalID.player_change_health,
	_SIG_player_change_health
)


const payload_amount_field := "amount"
