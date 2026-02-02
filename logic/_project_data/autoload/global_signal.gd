extends Node

## AUTOLOAD ##

## DOCS
## * NOTE: all signals have the same payload structure Dictionary[String, Variant]
##   or don't have the payload at all. 
##   While cumbersome, it unifies all the signal handlers 
##	 and mitigates an error when handler signature does not match the signal
## * Use const fields for the payload keys
## * Use SigUtils for both, emitting signals and parsing their payload
##   (also for connecting/disconnecting signals)

## -------------------------------------------------------------------


## PLAYER EVENTS

signal SIG_player_state_changed(payload: Dictionary[String, Variant])
signal SIG_player_leg_beh_changed(payload: Dictionary[String, Variant])
signal SIG_player_action_changed(payload: Dictionary[String, Variant])
signal SIG_player_weapon_hit_data_set(payload: Dictionary[String, Variant])
signal SIG_player_reacted_on_hit(payload: Dictionary[String, Variant])

## PHE EVENTS
signal SIG_phe_state_changed(payload: Dictionary[String, Variant])
signal SIG_phe_state_reset(payload: Dictionary[String, Variant])

# E EVENTS
signal SIG_enemy_weapon_hit_data_set(payload: Dictionary[String, Variant])
signal SIG_enemy_state_changed(payload: Dictionary[String, Variant])
signal SIG_enemy_reacted_on_hit(payload: Dictionary[String, Variant])


## PLAYER FEELINGS

signal _SIG_player_change_health(payload: Dictionary[String, Variant])
signal _SIG_player_max_health_increase(payload: Dictionary[String, Variant])
signal _SIG_player_max_stamina_increase(payload: Dictionary[String, Variant])

## PLAYER STATS

signal _SIG_player_speed_increase(payload: Dictionary[String, Variant])
signal _SIG_player_dodge_increase(payload: Dictionary[String, Variant])

## SYSTEM GLOBAL UI
signal SIG_ui_overlay_check_button_toggled(payload: Dictionary[String, Variant])
signal SIG_ui_overlay_spin_box_value_changed(payload: Dictionary[String, Variant])

signal SIG_free_cam_mode_toggled(payload: Dictionary[String, Variant])
signal SIG_toggle_camera_visuals(payload: Dictionary[String, Variant])
signal SIG_toggle_camera_coll(payload: Dictionary[String, Variant])
# signal SIG_toggle_split_screen(payload: Dictionary[String, Variant])
signal SIG_tut_panel_switched(payload: Dictionary[String, Variant])

## SYSTEM SETTINGS

## between options menu and levels
signal SIG_update_video_settings_for_level()
##
signal SIG_update_mouse_settings_for_camera()


## PAYLOAD SCHEMAS


class HStateData:
	var state_name: String
	var state_depth: int
	func _init(state_name_: String, state_depth_: int) -> void:
		self.state_name = state_name_
		self.state_depth = state_depth_


## WRAPPERS

var player_change_health := SignalData.new(
	SignalID.player_change_health,
	_SIG_player_change_health
)

var player_max_health_increase := SignalData.new(
	SignalID.player_max_health_increase,
	_SIG_player_max_health_increase
)

var player_max_stamina_increase := SignalData.new(
	SignalID.player_max_stamina_increase,
	_SIG_player_max_stamina_increase
)

var player_speed_increase := SignalData.new(
	SignalID.player_speed_increase,
	_SIG_player_speed_increase
)

var player_dodge_increase := SignalData.new(
	SignalID.player_dodge_increase,
	_SIG_player_dodge_increase
)
