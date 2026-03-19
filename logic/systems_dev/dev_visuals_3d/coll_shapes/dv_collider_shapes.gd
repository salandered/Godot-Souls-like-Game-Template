@tool
class_name VisualizeColliderShapes
extends BaseDVCollShapes


@export var collider_colors: Dictionary[StringName, Color] = {
	DEF_CATEGORY: Color.DARK_BLUE,
}


func _initialize_visuals_implementation() -> void:
	var char_coll_colliders := get_descendants.char_coll_colliders(level)
	
	for node in char_coll_colliders:
		if not is_instance_valid(node): continue
		if node is not CharCollCollider: continue
		var casted := node as CharCollCollider
		if not casted.shape: continue

		var category := _get_coll_shape_category(casted)
		if category == MUTED_CATEGORY: continue

		var specific_mat := _get_or_create_mat_by_category(category, collider_colors)
		
		var mesh_inst := MeshInstanceUtils.create_mi_based_on_shape_3d(casted.shape)
		if mesh_inst:
			mesh_inst.material_override = specific_mat
			casted.add_child(mesh_inst)
			mesh_inst.visible = false
			_generated_nodes.append(mesh_inst)


func _get_coll_shape_category(casted: CollisionShape3D) -> StringName:
	return DEF_CATEGORY
