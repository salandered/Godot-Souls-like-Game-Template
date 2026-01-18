extends Node


signal SIG_dodge_combo_achieved
signal SIG_power_combo_achieved
signal SIG_plush_launched
signal SIG_sitting_skeleton_is_not_happy
signal SIG_simple_target_super_rotate


var _count_dodge: int = 0
var _count_plush_launches: int = 0
var _power_combo: bool = false
var _simple_target_super_rotate: bool = false
var _count_sitting_sk_hit: int = 0


func increase_count_dodge():
	_count_dodge += 1
	if _count_dodge >= 3:
		u.safe_emit_raw_no_payload(SIG_dodge_combo_achieved)

func reset_count_dodge():
	_count_dodge = 0


func set_power_combo():
	_power_combo = true
	u.safe_emit_raw_no_payload(SIG_power_combo_achieved)

func set_simple_target_super_rotate():
	_simple_target_super_rotate = true
	u.safe_emit_raw_no_payload(SIG_simple_target_super_rotate)


func increase_count_plush_launches():
	_count_plush_launches += 1
	u.safe_emit_raw_no_payload(SIG_plush_launched)


func increase_count_sitting_sk_hit():
	_count_sitting_sk_hit += 1
	if _count_sitting_sk_hit >= 2:
		u.safe_emit_raw_no_payload(SIG_sitting_skeleton_is_not_happy)
