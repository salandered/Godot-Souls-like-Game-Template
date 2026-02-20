class_name SPS
extends RefCounted


## DOCS
## SPS stands for Signal Payload Schema
## for now it's not really a schema, but constants to use in payload dict as keys


const h_state_data_field := "h_state_data"
const hit_data_field := "hit_data"
const attack_dir_field := "attack_dir"
const interruption_field := "interruption"
const reaction_anim_or_state_field := "react_anim"
const frame_field := "frame_field"

# name

const state_name_field := "state_name"
const button_name_field := "button_name"

# generic
const type_field := "type_"
const value_field := "value_"
const toggle_field := "toggle_"
const amount_field := "amount_"
const damage_field := "damage_"
const number_field := "number_"
const message_field := "message_"
const tag_field := "tag_field_"


# dvc
const dvc_section_field = "dvc_section_field"
const dvc_key_field = "dvc_key_field"
const dvc_value_field = "dvc_value_field"
const dvc_overlay_panel_type_field = "overlay_panel_type"
const dvc_char_type_field = "dvc_char_type"
const dvc_dv_type_field = "dvc_dv_type"


# combo
const triggered_state_field = "triggered_state_field"

# meta
const sig_name_field := "sig_name"
const sig_with_payload_field := "sig_with_payload"
const sig_payload_field := "sig_payload"


## OBJECT SCHEMAS

class HStateData:
	var state_name: String
	var state_depth: int
	func _init(state_name_: String, state_depth_: int) -> void:
		self.state_name = state_name_
		self.state_depth = state_depth_