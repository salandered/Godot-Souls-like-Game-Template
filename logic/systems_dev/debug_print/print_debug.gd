extends RefCounted
class_name __print_debug


# region Skeleton Animator

static func log_state(sa: PlayerModifierAnimator) -> String:
	var nt := "\n\t\t\t"
	var msg := pp.s(
		"TO:  ", sa.curr_playback,
		nt, "BLEND:  ", sa.curr_blend_playback,
		nt, "FROM:  ", sa.prev_playback,
		nt, "PREV_BLEND:  ", sa.prev_blend_playback,
		nt, "PREV_PREV:  ", sa.prev_prev_playback,
		nt, "PREV_PREV_PREV: ", sa.prev_prev_prev_playback,
		nt, "GLOB_SPEED:  ", sa.global_speed_scale)
	return msg


static func log_blend_state(sa: PlayerModifierAnimator) -> String:
	var anim_names: Array[StringName] = []
	var blend_times: Array[float] = []
	var times_left: Array[float] = []

	if sa.prev_prev_blend_playback.is_blending and sa.prev_prev_prev_playback and sa.prev_prev_playback:
		anim_names.append(sa.prev_prev_prev_playback.anim.anim_name) # D
		anim_names.append(sa.prev_prev_playback.anim.anim_name) # C
		blend_times.append(sa.prev_prev_blend_playback.duration)
		times_left.append(sa.prev_prev_blend_playback.time_remaining())

	if sa.prev_blend_playback.is_blending and sa.prev_playback:
		anim_names.append(sa.prev_playback.anim.anim_name) # B
		blend_times.append(sa.prev_blend_playback.duration)
		times_left.append(sa.prev_blend_playback.time_remaining())

	if sa.curr_blend_playback.is_blending and sa.curr_playback:
		anim_names.append(sa.curr_playback.anim.anim_name) # A
		blend_times.append(sa.curr_blend_playback.duration)
		times_left.append(sa.curr_blend_playback.time_remaining())
	
	var overlap_duration := "-unknown-"
	if len(times_left) == 3:
		overlap_duration = pp.round_001(min(times_left[0], times_left[1], times_left[2]))
	
	return "Blend anims " + "/".join(anim_names) \
		+"| blend times " + pp.array_(blend_times) \
		+"| times left " + pp.array_(times_left) \
		+"| overlap (may be) " + str(overlap_duration)

# endregion


# TODO: NEEDS REFACTORING

## detailed info about the given node
static func node_info(node: Node):
	if not node:
		return "no node"
	
	print_.msg_raw("", "Node name: ", node.name)
	print_.msg_raw("", "Node type: ", node.get_class())
	print_.msg_raw("", "Node path: ", node.get_path())
	print_.msg_raw("", "Is inside tree:", node.is_inside_tree())
	print_.msg_raw("", "Parent:", node.get_parent())
	print_.msg_raw("", "Children count:", node.get_child_count())
	var groups := node.get_groups()
	print_.msg_raw("Groups:", ", ".join(groups) if groups.size() > 0 else "(none)")


static func collisions(node: Node, info_indents: int = 0, layer_: bool = true):
	if not LogToggler.COLLISION_B: return
	print_.msg_raw("COLLISION LAYER AND MASK")
	var layer = "none"
	if layer_: layer = node.collision_layer
	var mask = node.collision_mask

	if layer_: print_.msg_raw("Collision Layer: ", layer, " (binary: ", str(layer).pad_zeros(32), ")")
	print_.msg_raw("Collision Mask: ", mask, " (binary: ", str(mask).pad_zeros(32), ")")

	# print in binary format more clearly
	if layer_: print_.msg_raw("Collision Layer binary: ", String.num_uint64(layer, 2))
	print_.msg_raw("Collision Mask binary: ", String.num_uint64(mask, 2))
	
	# print the bit positions (layer numbers)
	if layer_: print_.msg_raw("Collision Layer: ", _get_bit_position(layer), " (value: ", layer, ")")
	print_.msg_raw("Collision Mask bit position: ", _get_bit_position(mask), " (value: ", mask, ")")

	print_.msg_raw("\n")


static func debug_compare_attachments(
	skeleton: Skeleton3D,
	working_node: BoneAttachment3D,
	broken_node: BoneAttachment3D
) -> void:
	print_.msg_raw("\n--- BONE ATTACHMENT DEBUG COMPARISON ---")
	
	var nodes = [working_node, broken_node]
	var labels = ["REFERENCE (Working)", "GENERATED (Broken)"]
	
	for i in range(2):
		var node = nodes[i]
		if not node:
			print_.msg_raw(labels[i] + ": IS NULL")
			continue
			
		print_.msg_raw("\n[%s]: %s" % [labels[i], node.name])
		print_.msg_raw("  - Parent:             ", node.get_parent().name if node.get_parent() else "NULL")
		print_.msg_raw("  - Global Position:    ", node.global_position)
		print_.msg_raw("  - Bone Name:          ", node.bone_name)
		
		# Validate Bone Index
		var bone_idx = skeleton.find_bone(node.bone_name)
		print_.msg_raw("  - Bone Index (Calc):  ", bone_idx)
		
		# External Skeleton Logic
		print_.msg_raw("  - Use External Skel:  ", node.use_external_skeleton)
		print_.msg_raw("  - Ext Skel Path:      ", node.external_skeleton)
		
		# specific check: does the path actually resolve?
		if node.use_external_skeleton:
			var target = node.get_node_or_null(node.external_skeleton)
			print_.msg_raw("  - Path Resolves To:   ", target.name if target else "FAILED TO RESOLVE!")
		else:
			print_.msg_raw("  - (Using Parent Hierarchy)")


static func _get_bit_position(value: int) -> int:
	# Returns the position of the first set bit (0-indexed)
	if value == 0:
		return -1
	for i in range(32):
		if value & (1 << i):
			return i
	return -1
