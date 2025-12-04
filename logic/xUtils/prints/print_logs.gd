extends RefCounted
class_name print_

const _FRAME_PRINT := true


## COMMON

static var DEV_PRINT := PrintData.PrintInstance.new(LogToggler.DEV_B, "dev", 0, prefix)

static func dev(add_prefix_: String, text: Variant = "", info_indents: int = 0, level: String = LogL.NOTSET):
	_generic(DEV_PRINT, add_prefix_, text, info_indents, level)

# region: CONTAINER

static var CONTAINER_PRINT := PrintData.PrintInstance.new(LogToggler.CONTAINER_B, "Container", 0, prefix)
static var E_CONTAINER_PRINT := PrintData.PrintInstance.new(LogToggler.E_CONTAINER_B, "Container", 0, prefix)


static func container(add_prefix_: String, text: String, info_indents: int = 0, level: String = LogL.NOTSET):
	_generic(CONTAINER_PRINT, add_prefix_, text, info_indents, level)

static func e_container(add_prefix_: String, text: String, info_indents: int = 0, level: String = LogL.NOTSET):
	_generic(E_CONTAINER_PRINT, add_prefix_, text, info_indents, level)


# endregion

# region: FIGHT logs

static var COMBO_PRINT := PrintData.PrintInstance.new(LogToggler.COMBO_B, "Combo xx", 0, fight)
static var FIGHT_PRINT := PrintData.PrintInstance.new(LogToggler.FIGHT_B, "⚔️", 0, prefix)


static func combo(add_prefix_: String, text: String, info_indents: int = 0, level: String = LogL.NOTSET):
	_generic(COMBO_PRINT, add_prefix_, text, info_indents, level)


static func fight(add_prefix_: String, text: String, info_indents: int = 0, level: String = LogL.NOTSET):
	_generic(FIGHT_PRINT, add_prefix_, text, info_indents, level)

# endregion

# region: PLAYER PSM

static var ACTION_ANIM := PrintData.PrintInstance.new(LogToggler.ACTION_ANIM_B, "▷", 16, psm)
static var PSM_ACTION := PrintData.PrintInstance.new(LogToggler.PSM_B, "Action", 2, psm)
static var PSM_CHECK_TRANS_PRINT := PrintData.PrintInstance.new(LogToggler.PSM_B, "transition ❔", 1, psm)
static var PSM_PRINT := PrintData.PrintInstance.new(LogToggler.PSM_B, "PSM", 0, prefix)

static func any_action_anim(
	add_prefix_: String, anim_name: String,
	blend_time, start_time_offset, prev_act_name,
	info_indents: int = 0, level: String = LogL.NOTSET):
	var msg = pp.s(
		"anim", pp.in_q(anim_name),
		"blend t", blend_time,
		"start off", start_time_offset,
		"prev", pp.in_q(prev_act_name)
		)
	_generic(ACTION_ANIM, add_prefix_, msg, info_indents, level)

static func psm_check_trans(add_prefix_: String, text: String, info_indents: int = 0, level: String = LogL.NOTSET):
	_generic(PSM_CHECK_TRANS_PRINT, add_prefix_, text, info_indents, level)

static func psm_action(add_prefix_: String, text: String, info_indents: int = 0, level: String = LogL.NOTSET):
	_generic(PSM_ACTION, add_prefix_, text, info_indents, level)

static func psm(add_prefix_: String, text: String, info_indents: int = 0, level: String = LogL.NOTSET):
	_generic(PSM_PRINT, add_prefix_, text, info_indents, level)


# endregion

# region: PLAYER LSM

static var LSM_BEH_CH := PrintData.PrintInstance.new(LogToggler.LSM_BEH_B, "choose act ❔", 4, lsm_beh)
static var LSM_BEH_PRINT := PrintData.PrintInstance.new(LogToggler.LSM_BEH_B, "Behavior", 4, lsm)
static var LSM_ACTION_STRAFE := PrintData.PrintInstance.new(LogToggler.LSM_ACTION_B, "Strafe", 6, lsm_action)
static var LSM_ACTION := PrintData.PrintInstance.new(LogToggler.LSM_ACTION_B, "Action", 6, lsm)
static var LSM_PRINT := PrintData.PrintInstance.new(LogToggler.LSM_BEH_B, "LSM", 3, prefix)

static func lsm_beh_ch(add_prefix_: String, motion_type: String,
	is_moving, is_reverse_moving, is_pure_reverse_moving, text, decision,
	info_indents: int = 0, level: String = LogL.NOTSET):
	# Build custom message first
	if is_reverse_moving == true:
		is_reverse_moving = str(is_reverse_moving) + em.pin
	if is_pure_reverse_moving == true:
		is_pure_reverse_moving = str(is_pure_reverse_moving) + em.mark_alt
	
	var msg := pp.s("mt", motion_type + ",",
		"moving", str(is_moving) + ",",
		"reverse", str(is_reverse_moving) + ",",
		"pure_reverse", str(is_pure_reverse_moving) + ",",
		text, "=>", decision)
	
	_generic(LSM_BEH_CH, add_prefix_, msg, info_indents, level)

static func lsm_beh(add_prefix_: String, text: String, info_indents: int = 0, level: String = LogL.NOTSET):
	_generic(LSM_BEH_PRINT, add_prefix_, text, info_indents, level)

static func lsm_action_strafe(add_prefix_: String, text: String, info_indents: int = 0, level: String = LogL.NOTSET):
	_generic(LSM_ACTION_STRAFE, add_prefix_, text, info_indents, level)

static func lsm_action(add_prefix_: String, text: String, info_indents: int = 0, level: String = LogL.NOTSET):
	_generic(LSM_ACTION, add_prefix_, text, info_indents, level)

static func lsm(add_prefix_: String, text: String, info_indents: int = 0, level: String = LogL.NOTSET):
	_generic(LSM_PRINT, add_prefix_, text, info_indents, level)


# endregion

# region: PLAYER SYSTEMS

static var INPUT_GATHERING_PRINT := PrintData.PrintInstance.new(LogToggler.input_gathering_B, "Input", 0, prefix)
static var FANCY_CAM_PRINT := PrintData.PrintInstance.new(LogToggler.FANCY_CAM_B, "🎥 Cam", 0, prefix)

static func input_gathering(add_prefix_: String, text: String, info_indents: int = 0, level: String = LogL.NOTSET):
	_generic(INPUT_GATHERING_PRINT, add_prefix_, text, info_indents, level)

static func fancy_cam(add_prefix_: String, text: Variant, info_indents: int = 0, level: String = LogL.NOTSET):
	_generic(FANCY_CAM_PRINT, add_prefix_, text, info_indents, level)


# endregion

# region: ENEMY logs

static var PHE_ANIM_PRINT := PrintData.PrintInstance.new(LogToggler.PHE_ANIM_B, "▷ anim", 16, phe_sm)
static var PHE_CHECK_PRINT := PrintData.PrintInstance.new(LogToggler.PHE_CHECK_B, "transition ❔", 0, phe_sm)
static var PHE_SM_PRINT := PrintData.PrintInstance.new(LogToggler.PHE_B, "🗿", 1, prefix)


static func phe_anim(add_prefix_: String, anim_name: String,
	blend_time, start_time_offset, sp_scale, prev_leaf_state,
	info_indents: int = 0, level: String = LogL.NOTSET):
	var msg = pp.s(
		"anim", pp.in_q(anim_name),
		"blend-t", blend_time,
		"start-off", start_time_offset,
		"sp-scale", sp_scale,
		" (prev", pp.in_q(prev_leaf_state), ")"
		)
	_generic(PHE_ANIM_PRINT, add_prefix_, msg, info_indents, level)
	

static func phe_overlay_anim(add_prefix_: String, anim_name: String,
	overlay_config: OverlayConfig,
	start_time_offset = 0.0, sp_scale: float = 1.0,
	info_indents: int = 0, level: String = LogL.NOTSET):
	var msg = pp.s(
		"anim", pp.in_q(anim_name),
		"", overlay_config,
		"start-off", start_time_offset,
		"sp-scale", sp_scale,
		)
	_generic(PHE_ANIM_PRINT, add_prefix_, msg, info_indents, level)
	
	
static func phe_check(add_prefix_: String, text: String, info_indents: int = 0, level: String = LogL.NOTSET, freq: int = 1):
	_generic(PHE_CHECK_PRINT, add_prefix_, text, info_indents, level, freq)

static func phe_sm(add_prefix_: String, text: String, info_indents: int = 0, level: String = LogL.NOTSET, freq: int = 1):
	_generic(PHE_SM_PRINT, add_prefix_, text, info_indents, level, freq)


# endregion


# ----------------------

# region: INFRASTRUCTURE

static func _generic(
		print_data: PrintData.PrintInstance,
		add_prefix_: String,
		text: Variant,
		info_indents: int,
		level: String,
		freq: int = 1
	) -> void:
	if print_data == null or print_data.print_bool == null:
		# prevents problems on project start up. 
		return
	if not print_data.print_bool and level != LogL.FORCE_PRINT: return
	if not _is_freq_satisfied(1, freq): return

	var log_data := PrintData.LogData.new(add_prefix_, str(text), info_indents, level)
	log_data.add_prefix_ = print_data.const_prefix + " " + log_data.add_prefix_
	if log_data.info_indents == 0: log_data.info_indents = print_data.const_indent
	print_data.call_log_func(log_data)

static func _is_freq_satisfied(global_freq: int = 1, arg_freq: int = 1) -> bool:
	var result_freq := maxi(global_freq, arg_freq)
	assert(result_freq > 0)

	if result_freq == 1 or u.fr(false) % result_freq == 0:
		return true
	return false

static var _last_prefix_msg = ""

static func prefix_s(...parts: Array[Variant]):
	if parts.is_empty():
		parts = ["empty prefix", "empty text"]
	var _prefix = str(parts[0])
	var _msg = pp.list_(parts.slice(1))
	prefix(_prefix, _msg)

static func prefix(prefix_: String, text: String = "", info_indents: int = 0, level: String = LogL.NOTSET):
	var tabs_prefix := __calculate_tab_prefix(info_indents)
	prefix_ = prefix_.strip_edges()
	prefix_ = pp.in_sq(prefix_)
	match level:
		LogL.DEBUG:
			prefix_ = LogL.DEBUG + " " + prefix_
		LogL.INFO:
			prefix_ = LogL.INFO + " " + prefix_
		LogL.WARN:
			prefix_ = LogL.WARN + " " + prefix_
		LogL.ERROR:
			prefix_ = LogL.ERROR + " " + prefix_

	prefix_ = prefix_.strip_edges()
	
	var fr_ := ""
	if _FRAME_PRINT:
		var _metka := " "
		if u.fr(false) % 15 == 0 and u.fr(false) != 0:
			_metka = "-"
		if u.fr(false) % 60 == 0 and u.fr(false) != 0:
			_metka = "x"
		fr_ = "%6s" % [u.fr() + "|" + _metka + " "]
	
	var result_msg = tabs_prefix + "  " + prefix_ + "  " + text
	
	if result_msg == _last_prefix_msg:
		print("%4s" % ["| "], result_msg)
		return

	_last_prefix_msg = result_msg
	print(fr_, result_msg)

static func __calculate_tab_prefix(info_indents: int) -> String:
	var tabs_prefix = ""
	if info_indents:
		for i in range(info_indents):
			tabs_prefix += "    "
	return tabs_prefix


class ParsedPrefix:
	var prefix: String
	var index: int

	func _init(prefix_: String, index_: int) -> void:
		prefix = prefix_
		index = index_

static func parse_prefix(encoded_prefix_: String) -> ParsedPrefix:
	var parts := encoded_prefix_.split(" ", false)

	if parts.size() == 0:
		return ParsedPrefix.new("", 0)

	if parts.size() == 1:
		return ParsedPrefix.new(parts[0], 0)


	var prefix_info = parts[0]
	var index := 0
	if parts[-1].is_valid_int():
		var prefix_parts = parts.slice(0, -1) # all except last
		prefix_info = " ".join(prefix_parts)
		index = int(parts[-1])
	else:
		prefix_info = " ".join(parts) # join all parts
		index = 0

	return ParsedPrefix.new(prefix_info, index)


# endregion

# --------------------------

# region: UNSORTED


static func node_info(node: Node, prefix_: String = "", info_indents: int = 0):
	## detailed information about the given node
	if prefix_:
		print(prefix_)

	var tabs_prefix := __calculate_tab_prefix(info_indents)

	print(tabs_prefix, "Node name: ", node.name)
	print(tabs_prefix, "Node type: ", node.get_class())
	print(tabs_prefix, "Node path: ", node.get_path())
	# print("Is inside tree:", node.is_inside_tree())
	# print("Parent:", node.get_parent())
	# print("Children count:", node.get_child_count())
	# var groups = node.get_groups()
	# print("Groups:", ", ".join(groups) if groups.size() > 0 else "(none)")


static func collisions(node: Node, info_indents: int = 0, layer_: bool = true, level: String = LogL.NOTSET):
	if not LogToggler.COLLISION_B and level != LogL.FORCE_PRINT: return
	print("COLLISION LAYER AND MASK")
	var layer = "none"
	if layer_: layer = node.collision_layer
	var mask = node.collision_mask

	if layer_: print("Collision Layer: ", layer, " (binary: ", str(layer).pad_zeros(32), ")")
	print("Collision Mask: ", mask, " (binary: ", str(mask).pad_zeros(32), ")")

	# print in binary format more clearly
	if layer_: print("Collision Layer binary: ", String.num_uint64(layer, 2))
	print("Collision Mask binary: ", String.num_uint64(mask, 2))
	
	# print the bit positions (layer numbers)
	if layer_: print("Collision Layer: ", __get_bit_position(layer), " (value: ", layer, ")")
	print("Collision Mask bit position: ", __get_bit_position(mask), " (value: ", mask, ")")

	print("")

static func __get_bit_position(value: int) -> int:
	# Returns the position of the first set bit (0-indexed)
	if value == 0:
		return -1
	for i in range(32):
		if value & (1 << i):
			return i
	return -1

static func warn_raw(crucial: bool = false, ...parts: Array):
	var _msg = em.warn + "warning " + pp.list_(parts)
	if crucial: _msg = em.crucial_x2 + _msg
	print("\t", _msg)


static func warn(crucial: bool, what: String, where: String, fallback: String, ...details: Array):
	var _msg = "Problem: %s. Where: '%s'. Fallback: %s" % [what, where, fallback]
	if not details.is_empty():
		_msg += " Details: " + pp.list_(details)
	warn_raw(crucial, _msg)
	

static func note(bright: bool, ...parts: Array):
	var _msg = em.pin_alt + "NOTE (not warn) " + pp.list_(parts)
	if bright: _msg = em.mark_x2 + _msg
	print("\t", _msg)


# endregion