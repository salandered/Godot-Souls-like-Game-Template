@tool
class_name M_ListOptionControl
extends M_OptionControl


## for Display Mode: something like: 0 2 3 4


## Locks Option Titles from auto-updating when editing Option Values.
## Intentionally put first for initialization.
@export var lock_titles: bool = false
## Defines the list of possible values for the variable
## this option stores in the config file.
@export var option_values: Array:
	set(value):
		option_values = value
		_on_option_values_changed()

## Defines the list of options displayed to the user.
## Length should match with Option Values.
@export var option_titles: Array[String]:
	set(value):
		option_titles = value
		if is_inside_tree():
			_set_option_list(option_titles)

var custom_option_values: Array

func _ready() -> void:
	lock_titles = lock_titles
	option_titles = option_titles
	option_values = option_values
	super._ready()


func _on_option_values_changed() -> void:
	if option_values.is_empty(): return
	custom_option_values = option_values.duplicate()
	var first_value = custom_option_values.front()
	property_type = typeof(first_value) as Variant.Type
	_set_titles_from_values()

func _on_setting_changed(value: Variant) -> void:
	if value == null:
		__log_warn("value is null", "_on_setting_changed", "return null")
		return
	if value < custom_option_values.size() and value >= 0:
		super._on_setting_changed(custom_option_values[value])

func _set_titles_from_values() -> void:
	if lock_titles: return
	var mapped_titles: Array[String] = []
	for option_value in custom_option_values:
		mapped_titles.append(_value_title_map(option_value))
	option_titles = mapped_titles

func _value_title_map(value: Variant) -> String:
	return "%s" % value

func _match_value_to_other(value: Variant, other: Variant) -> Variant:
	# Primarily for when the editor saves floats as ints instead
	if value is int and other is float:
		return float(value)
	if value is float and other is int:
		return int(round(value))
	return value


## overrides
func _set_value(value: Variant, on_init: bool = false) -> Variant:
	__log_(name, "_set_value starts", "Incoming value", pp.in_q(value), "| On initialization 🦕." if on_init else "")
	__log_(name, "Current option_values", option_values)
	if option_values.is_empty():
		__log_("option_values.is_empty(). should be a warning but ok", "_set_value", "Returning early", name)
		return
		
	if value == null:
		__log_(name, "Value is null", "Selecting -1")
		return super._set_value(-1)

	custom_option_values = option_values.duplicate()
	value = _match_value_to_other(value, custom_option_values.front())
	
	# Check if we are adding a new custom value
	if value not in custom_option_values and typeof(value) == property_type:
		__log_(name, "Value not found in list", "Adding custom value", value)
		custom_option_values.append(value)
		custom_option_values.sort()
	
	__log_(name, "lock_titles status", lock_titles)
	_set_titles_from_values()
	
	# Check for mismatch between data and UI
	var ui_count = %OptionButton.item_count
	var data_count = custom_option_values.size()
	__log_(name, "Counts", "UI Button Items", ui_count, "Data List Items", data_count)
	
	if ui_count != data_count:
		__log_error("ui_count != data_count", "_set_value", "", "UI Count vs Data Count", ui_count, data_count, name)

	# Check the value we are about to set
	if value not in option_values:
		var disable_idx = custom_option_values.find(value)
		__log_(name, "Disabling option index", disable_idx)
		disable_option(disable_idx)
	
	var final_index = custom_option_values.find(value)
	__log_(name, "Final calculated index", final_index)
	
	if final_index >= ui_count:
		__log_error("final_index >= ui_count", "_set_value", "", "Index vs Max UI Index:", final_index, ui_count - 1, name)

	return super._set_value(final_index)
	
	
func _set_option_list(option_titles_list: Array) -> void:
	%OptionButton.clear()
	for option_title in option_titles_list:
		%OptionButton.add_item(option_title)

func disable_option(option_index: int, disabled: bool = true) -> void:
	%OptionButton.set_item_disabled(option_index, disabled)
