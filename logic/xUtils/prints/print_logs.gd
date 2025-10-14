extends RefCounted
class_name print_


# TODO: filter for log levels


# 
const FR := true

# SYSTEMS
const DEV_PRINT := true
const input_gathering_PRINT := true
const FANCY_CAM_PRINT := true
const AWARENESS := true
const CONTAINER_PRINT := false
const COLLISION_PRINT := false

# ENEMY
const SE_PRINT := false
const HSME_PRINT := true

# FIGHT
const FIGHT_PRINT := false
const COMBO_PRINT := true
const HIT_B_PRINT := true


# PLAYER
const PSM_PRINT := false
const LSM_BEH_PRINT := true
const LSM_ACTION_PRINT := true
const STRAFE_ACTION_PRINT := true
const SKM_PRINT := false

static func _is_freq_satisfied(global_freq: int = 1, arg_freq: int = 1) -> bool:
	var result_freq = max(global_freq, arg_freq)
	assert(result_freq > 0)

	if result_freq == 1 or u.fr(false) % result_freq == 0:
		return true
	return false


# region: ENEMY logs

static func hsme(add_prefix_: String, text: String, info_indents: int = 0, level: String = LogL.NOTSET, freq: int = 1):
	if not HSME_PRINT and level != LogL.FORCE_PRINT: return
	if not _is_freq_satisfied(1, freq): return

	add_prefix_ = "HSM" + " " + add_prefix_
	prefix(add_prefix_, text, info_indents, level)


static func se(add_prefix_: String, text: String, info_indents: int = 0, level: String = LogL.NOTSET, freq: int = 1):
	if not SE_PRINT and level != LogL.FORCE_PRINT: return
	if not _is_freq_satisfied(1, freq): return

	add_prefix_ = "SE" + " " + add_prefix_
	prefix(add_prefix_, text, info_indents, level)

# add_prefix_ is state_name here in most cases
static func se_check_trans(add_prefix_: String, text: String, info_indents: int = 0, level: String = LogL.NOTSET, freq: int = 1):
	add_prefix_ = "transition ❔" + " " + add_prefix_
	if info_indents == 0: info_indents = 2 # if not specified, lets shift it all
	se(add_prefix_, text, info_indents, level, freq)

# endregion

# region: SYSTEMS logs

static func input_gathering(add_prefix_: String, text: String, info_indents: int = 0, level: String = LogL.NOTSET):
	if not input_gathering_PRINT and level != LogL.FORCE_PRINT: return
	
	add_prefix_ = "Input" + " " + add_prefix_
	prefix(add_prefix_, text, info_indents, level)

static func dev(add_prefix_: String, text: String, info_indents: int = 0, level: String = LogL.NOTSET):
	if not DEV_PRINT and level != LogL.FORCE_PRINT: return
	
	add_prefix_ = "dev" + " " + add_prefix_
	prefix(add_prefix_, text, info_indents, level)

static func fancy_cam(add_prefix_: String, text: String, info_indents: int = 0, level: String = LogL.NOTSET):
	if not FANCY_CAM_PRINT and level != LogL.FORCE_PRINT: return
	
	add_prefix_ = "🎥 Cam" + " " + add_prefix_
	prefix(add_prefix_, text, info_indents, level)


static func container(add_prefix_: String, text: String, info_indents: int = 0, level: String = LogL.NOTSET):
	if not CONTAINER_PRINT and level != LogL.FORCE_PRINT: return
	
	add_prefix_ = "Container" + " " + add_prefix_
	prefix(add_prefix_, text, info_indents, level)

static func aware_target(add_prefix_: String, text: String, info_indents: int = 0, level: String = LogL.NOTSET):
	if not AWARENESS and level != LogL.FORCE_PRINT: return
	add_prefix_ = "🎯" + " " + add_prefix_
	aware_target(add_prefix_, text, info_indents, level)

static func aware(add_prefix_: String, text: String, info_indents: int = 0, level: String = LogL.NOTSET):
	if not AWARENESS and level != LogL.FORCE_PRINT: return
	add_prefix_ = "👀" + add_prefix_
	prefix(add_prefix_, text, info_indents, level)


# endregion


# region: FIGHT logs

static func fight(add_prefix_: String, text: String, info_indents: int = 0, level: String = LogL.NOTSET):
	if not FIGHT_PRINT and level != LogL.FORCE_PRINT: return
		
	add_prefix_ = "[Fight 🗡️]" + " " + add_prefix_
	prefix(add_prefix_, text, info_indents, level)

static func combo(add_prefix_: String, text: String, info_indents: int = 0, level: String = LogL.NOTSET):
	if not COMBO_PRINT and level != LogL.FORCE_PRINT: return
		
	add_prefix_ = "Combo🗡️🗡️" + " " + add_prefix_
	fight(add_prefix_, text, info_indents, level)


static func h_box(add_prefix_: String, text: String, info_indents: int = 0, level: String = LogL.NOTSET):
	if not HIT_B_PRINT and level != LogL.FORCE_PRINT: return
	
	add_prefix_ = "💢 HBox" + " " + add_prefix_
	fight(add_prefix_, text, info_indents, level)

# endregion


# region: PLAYER logs


static func psm_check_trans(add_prefix_: String, text: String, info_indents: int = 0, level: String = LogL.NOTSET):
	add_prefix_ = "transition ❔" + " " + add_prefix_
	if info_indents == 0: info_indents = 1
	psm(add_prefix_, text, info_indents, level)


static func psm(add_prefix_: String, text: String, info_indents: int = 0, level: String = LogL.NOTSET):
	if not PSM_PRINT and level != LogL.FORCE_PRINT: return
	
	add_prefix_ = "PSM" + " " + add_prefix_
	prefix(add_prefix_, text, info_indents, level)


static func lsm_beh_ch(add_prefix_: String, motion_type: String,
	is_moving, is_reverse_moving, is_pure_reverse_moving, text, decision,
	info_indents: int = 0, level: String = LogL.NOTSET):
	if is_reverse_moving == true:
		is_reverse_moving = str(is_reverse_moving) + em.pin
	if is_pure_reverse_moving == true:
		is_pure_reverse_moving = str(is_pure_reverse_moving) + em.mark
	var msg = pp.s("mt", motion_type + ",",
		"moving", str(is_moving) + ",",
		"reverse", str(is_reverse_moving) + ",",
		"pure_reverse", str(is_pure_reverse_moving) + ",",
		text, "=>", decision)
	add_prefix_ = "choose act ❔" + " " + add_prefix_
	lsm_beh(add_prefix_, msg, info_indents, level)

static func lsm_beh(add_prefix_: String, text: String, info_indents: int = 0, level: String = LogL.NOTSET):
	if not LSM_BEH_PRINT and level != LogL.FORCE_PRINT: return
		
	add_prefix_ = "LSM Behavior" + " " + add_prefix_
	if info_indents == 0: info_indents = 3
	prefix(add_prefix_, text, info_indents, level)


static func lsm_action_anim(add_prefix_: String, anim_name: String, prev_action_name, blend_time, start_time_offset, info_indents: int = 0, level: String = LogL.NOTSET):
	var msg = pp.s(
		"anim: ", pp.in_q(anim_name),
		"Params based on prev", pp.in_q(prev_action_name) + ":",
		"blend_t", blend_time,
		"start_t_off", start_time_offset
		)
	add_prefix_ = "▶️" + " " + add_prefix_
	if info_indents == 0: info_indents = 7
	lsm_action(add_prefix_, msg, info_indents, level)

	
static func lsm_action(add_prefix_: String, text: String, info_indents: int = 0, level: String = LogL.NOTSET):
	if not LSM_ACTION_PRINT and level != LogL.FORCE_PRINT: return
		
	add_prefix_ = "LSM Action" + " " + add_prefix_
	if info_indents == 0: info_indents = 5
	prefix(add_prefix_, text, info_indents, level)


static func skm(add_prefix_: String, text: String, info_indents: int = 0, level: String = LogL.NOTSET):
	if not SKM_PRINT and level != LogL.FORCE_PRINT: return
		
	add_prefix_ = "SKM 💀" + " " + add_prefix_
	prefix(add_prefix_, text, info_indents, level)

# endregion

# -------------------

static var _last_prefix_msg = ""

static func prefix(prefix_: String, text: String, info_indents: int = 0, level: String = LogL.NOTSET):
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
	if FR:
		fr_ = "%6s" % [u.fr() + "| "]
	
	var result_msg = tabs_prefix + "  " + prefix_ + "  " + text
	
	if result_msg == _last_prefix_msg:
		print("%4s" % ["| "], result_msg)
		return

	_last_prefix_msg = result_msg
	print(fr_, result_msg)


static func _ready(node: Node, info_indents: int = 0):
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


static func __calculate_tab_prefix(info_indents: int) -> String:
	var tabs_prefix = ""
	if info_indents:
		for i in range(info_indents):
			tabs_prefix += "    "
	return tabs_prefix


static func collisions(node: Node, info_indents: int = 0, layer_: bool = true, level: String = LogL.NOTSET):
	if not COLLISION_PRINT and level != LogL.FORCE_PRINT: return
	print("COLLISION LAYER AND MASK")
	var layer = "none"
	if layer_:
		layer = node.collision_layer
	var mask = node.collision_mask
		# Debug print the values
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


static func warn(text: String):
	text = em.warn + " " + text
	print(text)

static func debug(text: String):
	text = em.bug + " " + text
	print(text)