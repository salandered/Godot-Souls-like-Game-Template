extends RefCounted
class_name get_descendants


class Descendant:
	var node_: Node
	var depth: int
	func _init(node__, depth_):
		self.node_ = node__
		self.depth = depth_


## INTERNAL
# region

## by default first level has a depth of 0.
static func _get_descendants_filtered_with_depth(node: Node, filter: Callable, _depth: int = -1) -> Array[Descendant]:
	var descendants: Array[Descendant] = []
	for child in node.get_children():
		if filter.call(child):
			descendants.append(Descendant.new(child, _depth + 1))
		descendants.append_array(_get_descendants_filtered_with_depth(child, filter, _depth + 1))
	return descendants

static func _get_descendants_filtered(node: Node, filter: Callable, one_level: bool = false) -> Array:
	var descendants := []
	for child in node.get_children():
		if filter.call(child):
			descendants.append(child)
		if not one_level:
			descendants.append_array(_get_descendants_filtered(child, filter, one_level))
	return descendants

#endregion


# region: built in nodes

static func rigid_bodies(node: Node) -> Array:
	return _get_descendants_filtered(node, func(n): return n is RigidBody3D)

static func areas(node: Node) -> Array:
	return _get_descendants_filtered(node, func(n): return n is Area3D)


static func collision_shapes(node: Node) -> Array[CollisionShape3D]:
	var r = _get_descendants_filtered(node, func(n): return n is CollisionShape3D)
	r = TypeCast.array_of_collision_shape(r)
	return r


static func static_bodies(node: Node) -> Array:
	return _get_descendants_filtered(node, func(n): return n is StaticBody3D)


static func mesh_instances(node: Node, visible_only: bool = false) -> Array[MeshInstance3D]:
	var r = _get_descendants_filtered(
		node,
		func(n): \
			return n is MeshInstance3D \
				and (not visible_only or n.visible == true)
		)
	return TypeCast.array_of_mesh_instances(r)

static func mesh_instances_visible(node: Node, is_visible: bool = false, one_level: bool = false) -> Array:
	var filter := func(n):
		if n is MeshInstance3D:
			# why i needed that?
			return not is_visible or n.is_visible_in_tree()
		return false
	return _get_descendants_filtered(node, filter, one_level)

static func csg_primitives(node: Node) -> Array:
	return _get_descendants_filtered(node, func(n): return n is CSGPrimitive3D)

static func bone_attachments(node: Node) -> Array:
	return _get_descendants_filtered(node, func(n): return n is BoneAttachment3D)

# endregion


static func breakable_areas(node: Node) -> Array:
	return _get_descendants_filtered(node, func(n): return n is BreakableArea)

static func base_weapons_only_one(node: Node) -> BaseWeapon:
	var r := base_weapons(node)
	assert(len(r) == 1, "expected 1 base weapon, got " + str(len(r)))
	return r[0]

static func base_weapons(node: Node) -> Array:
	return _get_descendants_filtered(node, func(n): return n is BaseWeapon)


# region: player

static func player_states(node: Node) -> Array:
	return _get_descendants_filtered(node, func(n): return n is BasePlayerState)

static func player_actions(node: Node) -> Array:
	return _get_descendants_filtered(node, func(n): return n is PlayerAction)

static func legs_behaviors(node: Node) -> Array:
	return _get_descendants_filtered(node, func(n): return n is LegsBehavior)

static func legs_actions(node: Node) -> Array:
	return _get_descendants_filtered(node, func(n): return n is LegsAction)

# endregion


static func combos_one_level(node: Node) -> Array:
	return _get_descendants_filtered(node, func(n): return n is Combo_, true)


# 

static func base_ph_composite_states_with_depth(node: Node) -> Array[Descendant]:
	return _get_descendants_filtered_with_depth(node, func(n): return n is BasePHEComposite)

static func base_ph_leaf_states(node: Node) -> Array:
	return _get_descendants_filtered(node, func(n): return n is BasePHELeaf)


static func enemy_camera_targets(node: Node) -> Array[EnemyCameraTarget]:
	var r = _get_descendants_filtered(node, func(n): return n is EnemyCameraTarget)
	return TypeCast.array_of_enemy_camera_target(r)


# UI

static func pause_menu_controller(node: Node) -> Array[M_PauseMenuController]:
	var r = _get_descendants_filtered(node, func(n): return n is M_PauseMenuController)
	return TypeCast.array_of_pause_menu_controller(r)
# 