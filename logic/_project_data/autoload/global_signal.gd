extends Node


## AUTOLOAD ##

## -------------------------------------------------------------------


## PLAYER EVENTS

signal SIG_player_state_changed(payload: Dictionary[String, Variant])
signal SIG_player_action_changed(payload: Dictionary[String, Variant])
signal SIG_player_weapon_hit_data_set(payload: Dictionary[String, Variant])
signal SIG_player_react_on_hit(payload: Dictionary[String, Variant])

## PHE EVENTS
signal SIG_phe_state_changed(payload: Dictionary[String, Variant])
signal SIG_phe_state_reset(payload: Dictionary[String, Variant])

# E EVENTS
signal SIG_enemy_weapon_hit_data_set(payload: Dictionary[String, Variant])
signal SIG_enemy_state_changed(payload: Dictionary[String, Variant])
signal SIG_enemy_react_on_hit(payload: Dictionary[String, Variant])


## PLAYER FEELINGS

signal _SIG_player_change_health(payload: Dictionary[String, Variant])
signal _SIG_player_max_health_increase(payload: Dictionary[String, Variant])
signal _SIG_player_max_stamina_increase(payload: Dictionary[String, Variant])

## PLAYER STATS

signal _SIG_player_speed_increase(payload: Dictionary[String, Variant])
signal _SIG_player_dodge_increase(payload: Dictionary[String, Variant])

## SYSTEM GLOBAL UI

signal SIG_toggle_show_tut(payload: Dictionary[String, Variant])
signal SIG_toggle_show_profiler(payload: Dictionary[String, Variant])
signal SIG_free_cam_mode_toggled(payload: Dictionary[String, Variant])
signal SIG_toggle_dynamic_state_info(payload: Dictionary[String, Variant])
signal SIG_toggle_phe_dynamic_state_info(payload: Dictionary[String, Variant])
signal SIG_toggle_se_dynamic_state_info(payload: Dictionary[String, Variant])
signal SIG_toggle_camera_visuals(payload: Dictionary[String, Variant])
signal SIG_toggle_camera_coll(payload: Dictionary[String, Variant])
# signal SIG_toggle_split_screen(payload: Dictionary[String, Variant])


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


const payload_h_state_data_field := "h_state_data"
const payload_state_name_field := "state_name"
const payload_amount_field := "amount"
const payload_damage_field := "damage"
const payload_hit_data_field := "hit_data"
const payload_toggle_field := "toggle"
const payload_attack_dir_field := "attack_dir"
const payload_interruption_field := "interruption"
const payload_reaction := "react_anim"


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
