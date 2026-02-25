class_name InputUtils
extends RefCounted


static func is_keycode(event: InputEvent, keycode: Key, filter_echo: bool = false) -> bool:
	if not event: return false
	return _is_event_pressed(event, filter_echo) and event.keycode == keycode


static func is_in_keycodes(event: InputEvent, keycodes: Array[Key], filter_echo: bool = false) -> bool:
	if not event: return false
	for item in keycodes:
		if is_keycode(event, item, filter_echo):
			return true
	return false


static func is_keycode_w_ctrl(event: InputEvent, keycode: Key, filter_echo: bool = false) -> bool:
	return _is_keycode_with_modifiers(event, keycode, true, false, false, filter_echo)


static func is_keycode_w_alt(event: InputEvent, keycode: Key, filter_echo: bool = false) -> bool:
	return _is_keycode_with_modifiers(event, keycode, false, true, false, filter_echo)


static func is_keycode_w_shift(event: InputEvent, keycode: Key, filter_echo: bool = false) -> bool:
	return _is_keycode_with_modifiers(event, keycode, false, false, true, filter_echo)


static func is_keycode_w_ctrl_shift(event: InputEvent, keycode: Key, filter_echo: bool = false) -> bool:
	return _is_keycode_with_modifiers(event, keycode, true, false, true, filter_echo)


static func is_keycode_w_ctrl_alt(event: InputEvent, keycode: Key, filter_echo: bool = false) -> bool:
	return _is_keycode_with_modifiers(event, keycode, true, true, false, filter_echo)


static func get_keycode(event: InputEvent, filter_echo: bool = false) -> Key:
	if _is_event_pressed(event, filter_echo):
		return event.keycode
	return KEY_NONE


static func mark_input_handled(for_whom: Node, affect_tree_root: bool = false) -> void:
	if not for_whom: return
	if for_whom.get_viewport():
		for_whom.get_viewport().set_input_as_handled()
	if affect_tree_root:
		if for_whom.get_tree() and for_whom.get_tree().root:
			for_whom.get_tree().root.set_input_as_handled()


static func _is_keycode_with_modifiers(event: InputEvent, keycode: Key, ctrl: bool = false, alt: bool = false, shift: bool = false, filter_echo: bool = false) -> bool:
	if not is_keycode(event, keycode, filter_echo):
		return false
	
	var casted := event as InputEventWithModifiers
	if ctrl and not casted.ctrl_pressed: return false
	if alt and not casted.alt_pressed: return false
	if shift and not casted.shift_pressed: return false
	
	return true

	
## INTERNAL

static func _is_event_pressed(event: InputEvent, filter_echo: bool):
	if not event:
		return false
	if event is not InputEventKey:
		return false
	if not event.pressed:
		return false
	if filter_echo and event.echo:
		return false
	return true


## DEV
# region

static func _dev_change_t12_param(event, param, param_name: String = "some param", step: float = 0.1,
	require_ctrl_alt: bool = false) -> Variant:
	return _dev_change_param(event, param, param_name, step, RawAction.t1, RawAction.t2, require_ctrl_alt)

static func _dev_change_t34_param(event, param, param_name: String = "some param", step: float = 0.1,
	require_ctrl_alt: bool = false) -> Variant:
	return _dev_change_param(event, param, param_name, step, RawAction.t3, RawAction.t4, require_ctrl_alt)

static func _dev_change_t58_param(event, param, param_name: String = "some param", step: float = 0.1,
	require_ctrl_alt: bool = false) -> Variant:
	return _dev_change_param(event, param, param_name, step, RawAction.t5, RawAction.t8, require_ctrl_alt)

static func _dev_change_t67_param(event, param, param_name: String = "some param", step: float = 0.1,
	require_ctrl_alt: bool = false) -> Variant:
	return _dev_change_param(event, param, param_name, step, RawAction.t6, RawAction.t7, require_ctrl_alt)

static func _dev_change_param(
	event: InputEvent,
	param: Variant,
	param_name: String = "some param",
	step: float = 0.1,
	key_a: StringName = RawAction.t1,
	key_b: StringName = RawAction.t2,
	require_ctrl_alt: bool = false
) -> Variant:
	if eu.is_release():
		return param
	var prev_param: Variant = param

	if not event is InputEventKey:
		return param

	var casted: InputEventKey = event
	if require_ctrl_alt and (not casted.ctrl_pressed or not casted.alt_pressed):
		return param

	if event.is_action_released(key_a):
		param -= step
	if event.is_action_released(key_b):
		param += step

	if prev_param != param:
		print_.dev("_dev_change_param", param_name, prev_param, pp.ARROW, param)
	return param

# endregion
