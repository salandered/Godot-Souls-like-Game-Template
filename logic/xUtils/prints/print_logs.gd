extends RefCounted
class_name print_

# region: FILTERS
# 
const _FRAME_PRINT := true

# COMMON
const DEV_B := true
const COLLISION_B := false

# CONTAINER
const CONTAINER_B := false
const E_CONTAINER_B := true

# FIGHT
const FIGHT_B := true
const COMBO_B := true
const HIT_BOX_B := true

# PLAYER PSM
const PSM_B := false
const SKM_B := false
const ACTION_ANIM_B := false

# PLAYER LSM
const LSM_BEH_B := false
const LSM_ACTION_STRAFE_B := false
const LSM_ACTION_B := false

# PL SYSTEMS
const FEEL_B := true
const input_gathering_B := false
const FANCY_CAM_B := false
const AWARENESS_B := false

# ENEMY
const SE_B := false
const PHE_CHECK_B := true
const PHE_B := true
const ANIM_MANAGER_B := true
# endregion

#----------------------


# region: CONTAINER

static var CONTAINER_PRINT := PrintData.new(CONTAINER_B, "Container", 0, prefix)
static var E_CONTAINER_PRINT := PrintData.new(E_CONTAINER_B, "Container", 0, prefix)


static func container(add_prefix_: String, text: String, info_indents: int = 0, level: String = LogL.NOTSET):
	_generic(CONTAINER_PRINT, add_prefix_, text, info_indents, level)

static func e_container(add_prefix_: String, text: String, info_indents: int = 0, level: String = LogL.NOTSET):
	_generic(E_CONTAINER_PRINT, add_prefix_, text, info_indents, level)


# endregion

# region: FIGHT logs

static var SE_FIGHT_PRINT := PrintData.new(FIGHT_B, "SE", 0, fight)
static var COMBO_PRINT := PrintData.new(COMBO_B, "Combo🗡️🗡️", 0, fight)
static var H_BOX_PRINT := PrintData.new(HIT_BOX_B, "💢 HBox", 0, fight)
static var FIGHT_PRINT := PrintData.new(FIGHT_B, "🗡️", 0, prefix)

static func se_fight(add_prefix_: String, text: String, info_indents: int = 0, level: String = LogL.NOTSET):
	_generic(SE_FIGHT_PRINT, add_prefix_, text, info_indents, level)

static func combo(add_prefix_: String, text: String, info_indents: int = 0, level: String = LogL.NOTSET):
	_generic(COMBO_PRINT, add_prefix_, text, info_indents, level)

static func h_box(add_prefix_: String, text: String, info_indents: int = 0, level: String = LogL.NOTSET):
	_generic(H_BOX_PRINT, add_prefix_, text, info_indents, level)

static func fight(add_prefix_: String, text: String, info_indents: int = 0, level: String = LogL.NOTSET):
	_generic(FIGHT_PRINT, add_prefix_, text, info_indents, level)

# endregion

# region: PLAYER PSM

static var ACTION_ANIM := PrintData.new(ACTION_ANIM_B, "▷", 16, psm)
static var PSM_ACTION := PrintData.new(PSM_B, "Action", 2, psm)
static var PSM_CHECK_TRANS_PRINT := PrintData.new(PSM_B, "transition ❔", 1, psm)
static var PSM_PRINT := PrintData.new(PSM_B, "PSM", 0, prefix)
static var SKM_PRINT := PrintData.new(SKM_B, "SKM 💀", 0, prefix)
static var FEEL_PRINT := PrintData.new(PSM_B, "FEEL🤍", 10, prefix)

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

static func skm(add_prefix_: String, text: String, info_indents: int = 0, level: String = LogL.NOTSET):
	_generic(SKM_PRINT, add_prefix_, text, info_indents, level)

static func feel(add_prefix_: String, text: String, info_indents: int = 0, level: String = LogL.NOTSET):
	_generic(FEEL_PRINT, add_prefix_, text, info_indents, level)

# endregion

# region: PLAYER LSM

static var LSM_BEH_CH := PrintData.new(LSM_BEH_B, "choose act ❔", 4, lsm_beh)
static var LSM_BEH_PRINT := PrintData.new(LSM_BEH_B, "Behavior", 4, lsm)
static var LSM_ACTION_STRAFE := PrintData.new(LSM_ACTION_STRAFE_B, "Strafe", 6, lsm_action)
static var LSM_ACTION := PrintData.new(LSM_ACTION_B, "Action", 6, lsm)
static var LSM_PRINT := PrintData.new(LSM_BEH_B, "LSM", 3, prefix)

static func lsm_beh_ch(add_prefix_: String, motion_type: String,
	is_moving, is_reverse_moving, is_pure_reverse_moving, text, decision,
	info_indents: int = 0, level: String = LogL.NOTSET):
	# Build custom message first
	if is_reverse_moving == true:
		is_reverse_moving = str(is_reverse_moving) + em.pin
	if is_pure_reverse_moving == true:
		is_pure_reverse_moving = str(is_pure_reverse_moving) + em.mark
	
	var msg = pp.s("mt", motion_type + ",",
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

static var INPUT_GATHERING_PRINT := PrintData.new(input_gathering_B, "Input", 0, prefix)
static var DEV_PRINT := PrintData.new(DEV_B, "dev", 0, prefix)
static var FANCY_CAM_PRINT := PrintData.new(FANCY_CAM_B, "🎥 Cam", 0, prefix)
static var AWARE_TARGET_PRINT := PrintData.new(AWARENESS_B, "🎯", 0, prefix)
static var AWARE_PRINT := PrintData.new(AWARENESS_B, "👀", 0, prefix)

static func input_gathering(add_prefix_: String, text: String, info_indents: int = 0, level: String = LogL.NOTSET):
	_generic(INPUT_GATHERING_PRINT, add_prefix_, text, info_indents, level)

static func dev(add_prefix_: String, text: Variant = "", info_indents: int = 0, level: String = LogL.NOTSET):
	_generic(DEV_PRINT, add_prefix_, text, info_indents, level)

static func fancy_cam(add_prefix_: String, text: Variant, info_indents: int = 0, level: String = LogL.NOTSET):
	_generic(FANCY_CAM_PRINT, add_prefix_, text, info_indents, level)


static func aware_target(add_prefix_: String, text: String, info_indents: int = 0, level: String = LogL.NOTSET):
	_generic(AWARE_TARGET_PRINT, add_prefix_, text, info_indents, level)

static func aware(add_prefix_: String, text: String, info_indents: int = 0, level: String = LogL.NOTSET):
	_generic(AWARE_PRINT, add_prefix_, text, info_indents, level)

# endregion

# region: ENEMY logs

static var PHE_ANIM_PRINT := PrintData.new(PHE_B, "▷ anim", 16, phe_sm)
static var PHE_CHECK_PRINT := PrintData.new(PHE_CHECK_B, "transition ❔", 0, phe_sm)
static var PHE_SM_PRINT := PrintData.new(PHE_B, "🗿", 1, prefix)
static var SE_PRINT := PrintData.new(SE_B, "SE", 0, prefix)
static var SE_CHECK_TRANS_PRINT := PrintData.new(SE_B, "transition ❔", 2, se)
static var ANIM_MANAGER_PRINT := PrintData.new(ANIM_MANAGER_B, "E▷", 12, prefix)


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
	
	
static func phe_check(add_prefix_: String, text: String, info_indents: int = 0, level: String = LogL.NOTSET, freq: int = 1):
	_generic(PHE_CHECK_PRINT, add_prefix_, text, info_indents, level, freq)

static func phe_sm(add_prefix_: String, text: String, info_indents: int = 0, level: String = LogL.NOTSET, freq: int = 1):
	_generic(PHE_SM_PRINT, add_prefix_, text, info_indents, level, freq)

static func se(add_prefix_: String, text: String, info_indents: int = 0, level: String = LogL.NOTSET, freq: int = 1):
	_generic(SE_PRINT, add_prefix_, text, info_indents, level, freq)

static func se_check_trans(add_prefix_: String, text: String, info_indents: int = 0, level: String = LogL.NOTSET, freq: int = 1):
	_generic(SE_CHECK_TRANS_PRINT, add_prefix_, text, info_indents, level, freq)

static func anim_manager(add_prefix_: String, text: String, info_indents: int = 0, level: String = LogL.NOTSET, freq: int = 1):
	_generic(ANIM_MANAGER_PRINT, add_prefix_, text, info_indents, level, freq)

# endregion


# ----------------------

# region: INFRASTRUCTURE

static func _generic(
		print_data: PrintData,
		add_prefix_: String,
		text: Variant,
		info_indents: int,
		level: String,
		freq: int = 1
	) -> void:
	if not print_data.PRINT_BOOL and level != LogL.FORCE_PRINT: return
	if not _is_freq_satisfied(1, freq): return

	var log_data = LogData.new(add_prefix_, str(text), info_indents, level)
	log_data.add_prefix_ = print_data.const_prefix + " " + log_data.add_prefix_
	if log_data.info_indents == 0: log_data.info_indents = print_data.const_indent
	print_data.call_log_func(log_data)

static func _is_freq_satisfied(global_freq: int = 1, arg_freq: int = 1) -> bool:
	var result_freq = max(global_freq, arg_freq)
	assert(result_freq > 0)

	if result_freq == 1 or u.fr(false) % result_freq == 0:
		return true
	return false

class LogData:
	var add_prefix_: String
	var text: String
	var info_indents: int
	var level: String

	func _init(add_prefix__: String, text_: String, info_indents_: int, level_: String):
		self.add_prefix_ = add_prefix__
		self.text = text_
		self.info_indents = info_indents_
		self.level = level_

class PrintData:
	var PRINT_BOOL: bool
	var const_prefix: String
	var const_indent: int
	var log_func: Callable

	func _init(PRINT_BOOL_: bool, const_prefix_: String, const_indent_: int, log_func_: Callable) -> void:
		self.PRINT_BOOL = PRINT_BOOL_
		self.const_prefix = const_prefix_
		self.const_indent = const_indent_
		self.log_func = log_func_

	func call_log_func(log_data: LogData) -> void:
		log_func.call(log_data.add_prefix_, log_data.text, log_data.info_indents, log_data.level)

static var _last_prefix_msg = ""

static func prefix_s(...parts: Array[Variant]):
	if parts.is_empty():
		parts = ["empty prefix", "empty text"]
		
	var _msg = pp.list_(parts.slice(1))
	prefix(parts[0], _msg)

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
	
	var fr_ = ""
	if _FRAME_PRINT:
		var _metka = " "
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

# endregion

# --------------------------

# region: UNSORTED

static func _ready_info(node: Node, info_indents: int = 0):
	print("||", node.name, " ready()")
	_info(node, "", 1)

static func _info(node: Node, prefix_: String = "", info_indents: int = 0):
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
	if not COLLISION_B and level != LogL.FORCE_PRINT: return
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

static func warn(text: String, crucial: bool = false):
	text = em.warn + "warning " + text
	if crucial: text = em.crucial_x2 + text
	print("\t", text)


static func note(text: String, bright: bool = false):
	text = em.pin + "NOTE " + text
	if bright: text = em.mark_2 + text
	print("\t", text)

# endregion