extends RefCounted
class_name get_descendants


static func base_weapons_only_one(node: Node) -> BaseWeapon:
	var r := base_weapons(node)
	assert(len(r) == 1, "expected 1 base weapon, got " + str(len(r)))
	return r[0]

static func base_weapons(node: Node) -> Array:
	var descendants := []
	for child in node.get_children():
		if child is BaseWeapon:
			descendants.append(child)
		descendants.append_array(base_weapons(child))
	return descendants


static func base_se_states(node: Node) -> Array:
	var descendants := []
	for child in node.get_children():
		if child is BaseSEState:
			descendants.append(child)
		descendants.append_array(base_se_states(child))
	return descendants

static func base_hsme_states(node: Node) -> Array:
	var descendants := []
	for child in node.get_children():
		if child is BaseHSMEState:
			descendants.append(child)
		descendants.append_array(base_hsme_states(child))
	return descendants
	
static func base_ph_states(node: Node) -> Array:
	var descendants := []
	for child in node.get_children():
		if child is BasePHState:
			descendants.append(child)
		descendants.append_array(base_ph_states(child))
	return descendants

static func csg(node: Node) -> Array:
	var descendants := []
	for child in node.get_children():
		if child is CSGBox3D or child is CSGSphere3D:
			descendants.append(child)
		descendants.append_array(csg(child))
	return descendants


static func bone_attachments(node: Node) -> Array:
	var descendants := []
	for child in node.get_children():
		if child is BoneAttachment3D:
			descendants.append(child)
		descendants.append_array(bone_attachments(child))
	return descendants


static func player_states_by_type(node: Node, target_type: StringName) -> Array:
	var descendants: Array = []
	
	for child in node.get_children():
		match target_type:
			"PlayerState":
				if child is PlayerState: descendants.append(child)
			"PlayerAction":
				if child is PlayerAction: descendants.append(child)
			"LegsBehavior":
				if child is LegsBehavior: descendants.append(child)
			"LegsAction":
				if child is LegsAction: descendants.append(child)
			
		descendants.append_array(player_states_by_type(child, target_type))

	return descendants


static func mesh_instances(node: Node, is_visible: bool = false) -> Array:
	var descendants := []
	for child in node.get_children():
		if child is MeshInstance3D:
			if is_visible:
				if child.is_visible_in_tree():
					descendants.append(child)
			else:
				descendants.append(child)
		descendants.append_array(mesh_instances(child))
	return descendants


static func combos_one_level(node: Node) -> Array:
	var descendants := []
	for child in node.get_children():
		if child is Combo_:
			descendants.append(child)
	return descendants