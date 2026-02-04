class_name ControlUtils
extends RefCounted
##


static func margin_container_set_margins(margin_cont: MarginContainer, left: int = 0, right: int = 0, top: int = 0, bottom: int = 0):
	margin_cont.add_theme_constant_override(PropC.MARGIN_LEFT, left)
	margin_cont.add_theme_constant_override(PropC.MARGIN_RIGHT, right)
	margin_cont.add_theme_constant_override(PropC.MARGIN_TOP, top)
	margin_cont.add_theme_constant_override(PropC.MARGIN_BOTTOM, bottom)

## sets all: normal, italics, bold
static func rr_label_set_font_size(rr_label: RichTextLabel, font_size: int):
	rr_label.add_theme_font_size_override(PropC.NORMAL_FONT_SIZE, font_size)
	rr_label.add_theme_font_size_override(PropC.BOLD_FONT_SIZE, font_size)
	rr_label.add_theme_font_size_override(PropC.ITALICS_FONT_SIZE, font_size)


## NOTE: uses normal as a base, mult all: normal, italics, bold. Result: all three have same value
static func rr_label_mult_font_size(rr_label: RichTextLabel, mult: float):
	var cur_size := get_theme_normal_font_size(rr_label)
	var new_size := int(cur_size * mult)
	rr_label.add_theme_font_size_override(PropC.NORMAL_FONT_SIZE, new_size)
	rr_label.add_theme_font_size_override(PropC.BOLD_FONT_SIZE, new_size)
	rr_label.add_theme_font_size_override(PropC.ITALICS_FONT_SIZE, new_size)


## note that bold and italics sizes may be of different values
static func get_theme_normal_font_size(rr_label: RichTextLabel) -> int:
	var current_size: int = rr_label.get_theme_font_size(PropC.NORMAL_FONT_SIZE)
	return current_size


static func flow_container_set_v_separation(flow_container: FlowContainer, value: int) -> void:
	if flow_container:
		flow_container.add_theme_constant_override(PropC.V_SEPARATION, value)


static func flow_container_add_v_separation(flow_container: FlowContainer, value: int) -> void:
	if not flow_container:
		return
	var curr_value := flow_container_get_v_separation(flow_container)
	flow_container_set_v_separation(flow_container, curr_value + value)


## returns -1 if error
static func flow_container_get_v_separation(flow_container: FlowContainer) -> int:
	if not flow_container:
		return -1
	return flow_container.get_theme_constant(PropC.V_SEPARATION)
