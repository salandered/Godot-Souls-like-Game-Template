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
const frame_field := "frame_"

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


# dvc
const dvc_overlay_panel_type_field = "overlay_panel_type"
const dvc_value_type_field = "dvc_value_type_field"
const dvc_char_type_field = "dvc_char_type"
const dvc_dv_type_field = "dvc_dv_type"


# meta
const sig_name_field := "sig_name"
const sig_with_payload_field := "sig_with_payload"
const sig_payload_field := "sig_payload"