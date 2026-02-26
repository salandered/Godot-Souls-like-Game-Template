extends RefCounted
class_name print_preset


## 🚧
## NOTE: preset approach is being replaced by LoggingFramework method (via class extenders)
## 🚧


## PRESETS
static var ACTION_ANIM := PrintData.PrintInstance.new(LogToggler.ACTION_ANIM_B, "▷", 16, print_msg_formatted)
static var PSM_ACTION := PrintData.PrintInstance.new(LogToggler.PSM_B, "Action", 2, print_msg_formatted)
static var PSM_CHECK_TRANS_PRINT := PrintData.PrintInstance.new(LogToggler.PSM_B, "transition ❔", 1, print_msg_formatted)
static var LSM_BEH_CH := PrintData.PrintInstance.new(LogToggler.LSM_BEH_B, "choose act ❔", 4, lsm_beh)
static var LSM_BEH_PRINT := PrintData.PrintInstance.new(LogToggler.LSM_BEH_B, "Behavior", 4, lsm)
static var LSM_ACTION_STRAFE := PrintData.PrintInstance.new(LogToggler.LSM_ACTION_B, "Strafe", 6, lsm_action)
static var LSM_ACTION := PrintData.PrintInstance.new(LogToggler.LSM_ACTION_B, "Action", 6, lsm)
static var LSM_PRINT := PrintData.PrintInstance.new(LogToggler.LSM_BEH_B, "LSM", 3, print_msg_formatted)
static var INPUT_GATHERING_PRINT := PrintData.PrintInstance.new(LogToggler.input_gathering_B, "Input", 0, print_msg_formatted)
static var PHE_ANIM_PRINT := PrintData.PrintInstance.new(LogToggler.PHE_ANIM_B, "▷ anim", 16, phe_sm)
static var PHE_CHECK_PRINT := PrintData.PrintInstance.new(LogToggler.PHE_CHECK_B, "transition ❔", 0, phe_sm)
static var PHE_SM_PRINT := PrintData.PrintInstance.new(LogToggler.PHE_B, "🗿", 1, print_msg_formatted)


## PRESET CALLING API 
# region

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

static func input_gathering(add_prefix_: String, text: String, info_indents: int = 0):
	_generic(INPUT_GATHERING_PRINT, add_prefix_, text, info_indents)

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


# region: INFRASTRUCTURE


static func print_msg_formatted(prefix_: String, text: String = "", info_indents: int = 0):
	_LowLevelPrinter.print_msg_formatted(false, prefix_, text, info_indents)


static func _generic(
		print_data: PrintData.PrintInstance,
		add_prefix_: String,
		text: Variant,
		info_indents: int = 0,
		freq: int = 1
	) -> void:
	if print_data == null or print_data.print_bool == null:
		# prevents problems on project start up
		return
	if not print_data.print_bool: return
	if not _is_freq_satisfied(1, freq): return

	var log_data := PrintData.LogData.new(add_prefix_, str(text), info_indents)
	log_data.add_prefix_ = print_data.const_prefix + " " + log_data.add_prefix_
	if log_data.info_indents == 0: log_data.info_indents = print_data.const_indent
	print_data.call_log_func(log_data)


static func _is_freq_satisfied(global_freq: int = 1, arg_freq: int = 1) -> bool:
	var result_freq := maxi(global_freq, arg_freq)

	if result_freq == 1 or FrameUtils.ifr() % result_freq == 0:
		return true
	return false

# endregion