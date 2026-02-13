extends Node


## Autoload ##


signal SIG_dodge_combo_achieved
signal SIG_power_combo_achieved
signal SIG_thrown
signal SIG_plush_launched
signal SIG_sitting_skeleton_is_not_happy
signal SIG_simple_target_super_rotate
signal SIG_player_waved


var _count_dodge: int = 0
var _count_plush_launches: int = 0
var _count_waved: int = 0
var _count_throw: int = 0
var _power_combo: bool = false
var _simple_target_super_rotate: bool = false
var _count_sitting_sk_hit: int = 0


func increase_count_dodge():
	_count_dodge += 1
	if _count_dodge >= 3:
		SigUtils.safe_emit_raw_no_payload(SIG_dodge_combo_achieved)


func reset_count_dodge():
	_count_dodge = 0


func set_power_combo():
	_power_combo = true
	SigUtils.safe_emit_raw_no_payload(SIG_power_combo_achieved)


func set_simple_target_super_rotate():
	_simple_target_super_rotate = true
	SigUtils.safe_emit_raw_no_payload(SIG_simple_target_super_rotate)


func increase_count_plush_launches():
	_count_plush_launches += 1
	SigUtils.safe_emit_raw_no_payload(SIG_plush_launched)


func increase_count_waved():
	_count_waved += 1
	SigUtils.safe_emit_raw_no_payload(SIG_player_waved)

func increase_count_thrown():
	_count_throw += 1
	SigUtils.safe_emit_raw_no_payload(SIG_thrown)


func increase_count_sitting_sk_hit():
	_count_sitting_sk_hit += 1
	if _count_sitting_sk_hit >= 2:
		SigUtils.safe_emit_raw_no_payload(SIG_sitting_skeleton_is_not_happy)


func _input(event: InputEvent) -> void:
	if InputUtils.is_keycode_w_alt(event, KEY_G):
		SIG_player_waved.emit()