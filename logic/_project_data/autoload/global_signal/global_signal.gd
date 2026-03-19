extends Node

## AUTOLOAD ##


## PLAYER EVENTS

signal SIG_player_state_changed(payload: Dictionary[StringName, Variant])
signal SIG_player_action_changed(payload: Dictionary[StringName, Variant])
signal SIG_player_leg_beh_changed(payload: Dictionary[StringName, Variant])
signal SIG_player_weapon_hit_data_set(payload: Dictionary[StringName, Variant])
signal SIG_player_reacted_on_hit(payload: Dictionary[StringName, Variant])
signal SIG_player_combo_triggered(payload: Dictionary[StringName, Variant])

## PHE EVENTS
signal SIG_phe_state_changed(payload: Dictionary[StringName, Variant])
signal SIG_phe_state_reset(payload: Dictionary[StringName, Variant])

# E EVENTS
signal SIG_enemy_weapon_hit_data_set(payload: Dictionary[StringName, Variant])
signal SIG_enemy_state_changed(payload: Dictionary[StringName, Variant])
signal SIG_enemy_reacted_on_hit(payload: Dictionary[StringName, Variant])


## PLAYER FEELINGS

signal _SIG_player_change_health(payload: Dictionary[StringName, Variant])
signal _SIG_player_max_health_increase(payload: Dictionary[StringName, Variant])
signal _SIG_player_max_stamina_increase(payload: Dictionary[StringName, Variant])

## PLAYER STATS

signal _SIG_player_speed_increase(payload: Dictionary[StringName, Variant])
signal _SIG_player_dodge_increase(payload: Dictionary[StringName, Variant])

## SYSTEM GLOBAL UI
signal SIG_dt_ui_control_value_changed(payload: Dictionary[StringName, Variant])

signal SIG_free_cam_mode_toggled(payload: Dictionary[StringName, Variant])
signal SIG_toggle_camera_coll(payload: Dictionary[StringName, Variant])
signal SIG_tut_panel_switched(payload: Dictionary[StringName, Variant])

## SYSTEM SETTINGS

## between options menu and levels
signal SIG_update_video_settings_for_level()
##
signal SIG_update_mouse_settings_for_camera()

## meta signal
signal __SIG_sig_emitted(payload: Dictionary[StringName, Variant])
signal __SIG_error_log_printed(payload: Dictionary[StringName, Variant])
signal __SIG_all_log_printed(payload: Dictionary[StringName, Variant])


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
