extends RefCounted
class_name print_


## 🚧
## NOTE: preset approach is being replaced by ExtenderLogger method (via class extenders)
## 🚧

## PRESETS
static var DEV_PRINT := PrintData.PrintInstance.new(LogToggler.DEV_B, "dev", 0, prefix)
static var COMBO_PRINT := PrintData.PrintInstance.new(LogToggler.COMBO_B, "Combo xx", 0, fight)
static var FIGHT_PRINT := PrintData.PrintInstance.new(LogToggler.FIGHT_B, "⚔️", 0, prefix)
static var E_CONTAINER_PRINT := PrintData.PrintInstance.new(LogToggler.E_CONTAINER_B, "Container", 0, prefix)
# player
static var ACTION_ANIM := PrintData.PrintInstance.new(LogToggler.ACTION_ANIM_B, "▷", 16, prefix)
static var PSM_ACTION := PrintData.PrintInstance.new(LogToggler.PSM_B, "Action", 2, prefix)
static var PSM_CHECK_TRANS_PRINT := PrintData.PrintInstance.new(LogToggler.PSM_B, "transition ❔", 1, prefix)
# player lsm
static var LSM_BEH_CH := PrintData.PrintInstance.new(LogToggler.LSM_BEH_B, "choose act ❔", 4, lsm_beh)
static var LSM_BEH_PRINT := PrintData.PrintInstance.new(LogToggler.LSM_BEH_B, "Behavior", 4, lsm)
static var LSM_ACTION_STRAFE := PrintData.PrintInstance.new(LogToggler.LSM_ACTION_B, "Strafe", 6, lsm_action)
static var LSM_ACTION := PrintData.PrintInstance.new(LogToggler.LSM_ACTION_B, "Action", 6, lsm)
static var LSM_PRINT := PrintData.PrintInstance.new(LogToggler.LSM_BEH_B, "LSM", 3, prefix)
#
static var INPUT_GATHERING_PRINT := PrintData.PrintInstance.new(LogToggler.input_gathering_B, "Input", 0, prefix)
static var PHE_ANIM_PRINT := PrintData.PrintInstance.new(LogToggler.PHE_ANIM_B, "▷ anim", 16, phe_sm)
static var PHE_CHECK_PRINT := PrintData.PrintInstance.new(LogToggler.PHE_CHECK_B, "transition ❔", 0, phe_sm)
static var PHE_SM_PRINT := PrintData.PrintInstance.new(LogToggler.PHE_B, "🗿", 1, prefix)


## COMMON


static func dev(add_prefix_: String, text: Variant = ""):
	_generic(DEV_PRINT, add_prefix_, text)


# region: CONTAINER


static func e_container(add_prefix_: String, text: String, info_indents: int = 0):
	_generic(E_CONTAINER_PRINT, add_prefix_, text, info_indents)


# endregion

# region: FIGHT logs


static func combo(add_prefix_: String, text: String, info_indents: int = 0):
	_generic(COMBO_PRINT, add_prefix_, text, info_indents)


static func fight(add_prefix_: String, text: String, info_indents: int = 0):
	_generic(FIGHT_PRINT, add_prefix_, text, info_indents)

# endregion

# region: PLAYER PSM


static func any_action_anim(
	add_prefix_: String, anim_name: String,
	blend_time, start_time_offset, prev_act_name,
	info_indents: int = 0):
	var msg := pp.s(
		"anim", pp.in_q(anim_name),
		"blend t", blend_time,
		"start off", start_time_offset,
		"prev", pp.in_q(prev_act_name)
		)
	_generic(ACTION_ANIM, add_prefix_, msg, info_indents)

static func psm_check_trans(add_prefix_: String, text: String, info_indents: int = 0):
	_generic(PSM_CHECK_TRANS_PRINT, add_prefix_, text, info_indents)

static func psm_action(add_prefix_: String, text: String, info_indents: int = 0):
	_generic(PSM_ACTION, add_prefix_, text, info_indents)


# endregion

# region: PLAYER LSM


static func lsm_beh_ch(add_prefix_: String, motion_type: String,
	is_moving, is_reverse_moving, is_pure_reverse_moving, text, decision,
	info_indents: int = 0):
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
	
	_generic(LSM_BEH_CH, add_prefix_, msg, info_indents)

static func lsm_beh(add_prefix_: String, text: String, info_indents: int = 0):
	_generic(LSM_BEH_PRINT, add_prefix_, text, info_indents)

static func lsm_action_strafe(add_prefix_: String, text: String, info_indents: int = 0):
	_generic(LSM_ACTION_STRAFE, add_prefix_, text, info_indents)

static func lsm_action(add_prefix_: String, text: String, info_indents: int = 0):
	_generic(LSM_ACTION, add_prefix_, text, info_indents)

static func lsm(add_prefix_: String, text: String, info_indents: int = 0):
	_generic(LSM_PRINT, add_prefix_, text, info_indents)


# endregion

# region: PLAYER SYSTEMS


static func input_gathering(add_prefix_: String, text: String, info_indents: int = 0):
	_generic(INPUT_GATHERING_PRINT, add_prefix_, text, info_indents)


# endregion

# region: ENEMY logs


static func phe_anim(add_prefix_: String, anim_name: String,
	blend_time, start_time_offset, sp_scale, prev_leaf_state,
	info_indents: int = 0):
	var msg := pp.s(
		"anim", pp.in_q(anim_name),
		"blend-t", blend_time,
		"start-off", start_time_offset,
		"sp-scale", sp_scale,
		" (prev", pp.in_q(prev_leaf_state), ")"
		)
	_generic(PHE_ANIM_PRINT, add_prefix_, msg, info_indents)
	

static func phe_overlay_anim(add_prefix_: String, anim_name: String,
	overlay_config: OverlayConfig,
	start_time_offset = 0.0, sp_scale: float = 1.0,
	info_indents: int = 0):
	var msg := pp.s(
		"anim", pp.in_q(anim_name),
		"", overlay_config,
		"start-off", start_time_offset,
		"sp-scale", sp_scale,
		)
	_generic(PHE_ANIM_PRINT, add_prefix_, msg, info_indents)
	
	
static func phe_check(add_prefix_: String, text: String, info_indents: int = 0, freq: int = 1):
	_generic(PHE_CHECK_PRINT, add_prefix_, text, info_indents, freq)

static func phe_sm(add_prefix_: String, text: String, info_indents: int = 0, freq: int = 1):
	_generic(PHE_SM_PRINT, add_prefix_, text, info_indents, freq)


# endregion


# ----------------------

# region: INFRASTRUCTURE

static func _generic(
		print_data: PrintData.PrintInstance,
		add_prefix_: String,
		text: Variant,
		info_indents: int = 0,
		freq: int = 1
	) -> void:
	if print_data == null or print_data.print_bool == null:
		# prevents problems on project start up. 
		return
	if not print_data.print_bool: return
	if not _is_freq_satisfied(1, freq): return

	var log_data := PrintData.LogData.new(add_prefix_, str(text), info_indents)
	log_data.add_prefix_ = print_data.const_prefix + " " + log_data.add_prefix_
	if log_data.info_indents == 0: log_data.info_indents = print_data.const_indent
	print_data.call_log_func(log_data)

static func _is_freq_satisfied(global_freq: int = 1, arg_freq: int = 1) -> bool:
	var result_freq := maxi(global_freq, arg_freq)

	if result_freq == 1 or u.ifr() % result_freq == 0:
		return true
	return false

static func note(bright: bool, ...parts: Array):
	var _msg := em.pin_alt + "NOTE (not warn) " + pp.list_(parts)
	if bright: _msg = em.mark_x2 + _msg
	print("\t", _msg)


# legacy name
static func prefix(prefix_: String, text: String = "", info_indents: int = 0):
	_low_level_printer.prefix(false, prefix_, text, info_indents)

# legacy name
static func prefix_s(...parts: Array):
	_low_level_printer.prefix_s(false, pp.list_(parts))


static func console(...parts: Array):
	prefix_s(pp.s(">>", em.console), pp.list_(parts))


class ParsedPrefix:
	var prefix: String
	var index: int

	func _init(prefix_: String, index_: int) -> void:
		prefix = prefix_
		index = index_


## "Tree" -> ("Tree", 0)
## "LOD 1" -> ("LOD", 1)
## "Wall Brick 05" -> ("Wall Brick", 5)  # <-- check
## "Level 2 Boss" -> ("Level 2 Boss", 0)
## "" -> ("", 0)
## "2" -> ("2", 0)
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


## detailed info about the given node
static func node_info(node: Node):
	if not node:
		return "no node"
	
	prefix_s("", "Node name: ", node.name)
	prefix_s("", "Node name: ", node.name)
	prefix_s("", "Node type: ", node.get_class())
	prefix_s("", "Node path: ", node.get_path())
	prefix_s("", "Is inside tree:", node.is_inside_tree())
	prefix_s("", "Parent:", node.get_parent())
	prefix_s("", "Children count:", node.get_child_count())
	var groups := node.get_groups()
	prefix_s("Groups:", ", ".join(groups) if groups.size() > 0 else "(none)")


static func collisions(node: Node, info_indents: int = 0, layer_: bool = true):
	if not LogToggler.COLLISION_B: return
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


# endregion
