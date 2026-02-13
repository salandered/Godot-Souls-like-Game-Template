@tool
class_name RawInputsGridManager
extends BaseMetricsGridManager

# keycode (int) -> key_name (String)
var _active_keys: Dictionary[int, String] = {}
var _active_modifiers: Dictionary[int, String] = {}
var _active_mouse_buttons: Dictionary[int, String] = {}


var MODIFIERS := [
	KEY_CTRL, KEY_SHIFT, KEY_ALT, KEY_META,
]
var MOUSE_WHEEL := [
	MOUSE_BUTTON_WHEEL_UP, MOUSE_BUTTON_WHEEL_DOWN, MOUSE_BUTTON_WHEEL_LEFT, MOUSE_BUTTON_WHEEL_RIGHT
]


func get_dvc_op_key() -> DVS.KeyBOverlayPanel:
	return DVS.KeyBOverlayPanel.RAW_INPUT


func _input(event: InputEvent) -> void:
	# mouse
	if event is InputEventMouseButton:
		var casted_event := event as InputEventMouseButton
		# ignore scroll wheel
		if casted_event.button_index in MOUSE_WHEEL:
			return
			
		if casted_event.pressed:
			_active_mouse_buttons[casted_event.button_index] = _get_mouse_button_name(casted_event.button_index)
		else:
			_active_mouse_buttons.erase(casted_event.button_index)

	# keyboard
	elif event is InputEventKey and not event.is_echo():
		var casted_event := event as InputEventKey
		# use physical_keycode so 'W' is always 'W' regardless of language layout
		var code := casted_event.physical_keycode
		# fallback to keycode if needed
		# if code == 0: code = casted_event.keycode

		if casted_event.pressed:
			var key_name := OS.get_keycode_string(code)
			if _is_modifier(code):
				_active_modifiers[code] = key_name
			else:
				_active_keys[code] = key_name
		else:
			if _active_modifiers.has(code):
				_active_modifiers.erase(code)
			else:
				_active_keys.erase(code)


func _process_implementation(delta: float) -> void:
	_update_raw_input_metrics()


func _update_raw_input_metrics() -> void:
	var key_names: Array = _active_keys.values()
	key_names.sort()
	_metrics_grid.update_metric("Keys", " ".join(key_names))

	var mod_names: Array = _active_modifiers.values()
	mod_names.sort()
	_metrics_grid.update_metric("Mods", " ".join(mod_names))
	
	var mouse_names: Array = _active_mouse_buttons.values()
	mouse_names.sort()
	_metrics_grid.update_metric("Mouse", " ".join(mouse_names))


## HELPERS


func _is_modifier(code: int) -> bool:
	return code in MODIFIERS

func _get_mouse_button_name(idx: int) -> String:
	match idx:
		MOUSE_BUTTON_LEFT: return "LMB"
		MOUSE_BUTTON_RIGHT: return "RMB"
		MOUSE_BUTTON_MIDDLE: return "MMB"
		MOUSE_BUTTON_XBUTTON1: return "MB4"
		MOUSE_BUTTON_XBUTTON2: return "MB5"
		_: return "M%d" % idx
