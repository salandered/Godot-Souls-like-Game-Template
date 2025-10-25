extends RefCounted
class_name get_descendants


class Descendant:
	var node_: Node
	var depth: int
	func _init(node__, depth_):
		self.node_ = node__
		self.depth = depth_


## by default first level has a depth of 0.
static func get_descendants_filtered_with_depth(node: Node, filter: Callable, _depth: int = -1) -> Array[Descendant]:
	var descendants: Array[Descendant] = []
	for child in node.get_children():
		if filter.call(child):
			descendants.append(Descendant.new(child, _depth + 1))
		descendants.append_array(get_descendants_filtered_with_depth(child, filter, _depth + 1))
	return descendants

static func get_descendants_filtered(node: Node, filter: Callable, one_level: bool = false) -> Array:
	var descendants := []
	for child in node.get_children():
		if filter.call(child):
			descendants.append(child)
		if not one_level:
			descendants.append_array(get_descendants_filtered(child, filter, one_level))
	return descendants

#

static func base_weapons_only_one(node: Node) -> BaseWeapon:
	var r := base_weapons(node)
	assert(len(r) == 1, "expected 1 base weapon, got " + str(len(r)))
	return r[0]

static func base_weapons(node: Node) -> Array:
	return get_descendants_filtered(node, func(n): return n is BaseWeapon)

static func base_se_states(node: Node) -> Array:
	return get_descendants_filtered(node, func(n): return n is BaseSEState)

static func csg(node: Node) -> Array:
	return get_descendants_filtered(node, func(n): return n is CSGBox3D or n is CSGSphere3D)

static func bone_attachments(node: Node) -> Array:
	return get_descendants_filtered(node, func(n): return n is BoneAttachment3D)

#

static func player_states(node: Node) -> Array:
	return get_descendants_filtered(node, func(n): return n is PlayerState)

static func player_actions(node: Node) -> Array:
	return get_descendants_filtered(node, func(n): return n is PlayerAction)

static func legs_behaviors(node: Node) -> Array:
	return get_descendants_filtered(node, func(n): return n is LegsBehavior)

static func legs_actions(node: Node) -> Array:
	return get_descendants_filtered(node, func(n): return n is LegsAction)

#

static func mesh_instances(node: Node, is_visible: bool = false, one_level: bool = false) -> Array:
	var filter = func(n):
		if n is MeshInstance3D:
			return not is_visible or n.is_visible_in_tree()
		return false
	return get_descendants_filtered(node, filter, one_level)

static func combos_one_level(node: Node) -> Array:
	return get_descendants_filtered(node, func(n): return n is Combo_, true)

# 

static func base_ph_states_with_depth(node: Node) -> Array[Descendant]:
	return get_descendants_filtered_with_depth(node, func(n): return n is BasePHEState)
