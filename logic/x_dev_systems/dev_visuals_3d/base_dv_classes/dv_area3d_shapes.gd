@tool
class_name VisualiseArea3DShapes
extends BaseDVCollShapes


## colors for different area types
@export var area_type_colors: Dictionary[String, Color] = {
	"InteractArea": Color.GREEN_YELLOW,
	"WeatherChangeArea": Color.YELLOW,
	"BreakableArea": Color.ORANGE_RED,
	"CommonArea": Color.MEDIUM_PURPLE,
	"default": Color.SLATE_GRAY,
}


func _initialise_visuals_imp() -> void:
	var areas := get_descendants.area_3d(level)
	
	for node in areas:
		var area := node as Area3D
		if not is_instance_valid(area): continue
		var category := _get_area_category(area)
		if category == MUTED_CATEGORY: continue
		var specific_mat := _get_or_create_mat_by_category(category, area_type_colors)
		
		for child in area.get_children():
			var col_shape := child as CollisionShape3D
			if not is_instance_valid(col_shape) or not col_shape.shape: continue
			
			var mesh_inst := MeshInstanceUtils.create_based_on_shape_3d(col_shape.shape)
			if mesh_inst:
				mesh_inst.material_override = specific_mat
				col_shape.add_child(mesh_inst)
				mesh_inst.visible = false
				_generated_nodes.append(mesh_inst)


func _get_area_category(area: Area3D) -> String:
	if area is CharacterHitbox or area is WeaponHurtBox:
		return MUTED_CATEGORY

	if area is InteractArea:
		return "InteractArea"
	if area is WeatherChangeArea:
		return "WeatherChangeArea"
	if area is BreakableArea:
		return "BreakableArea"
	
	## should be in the end
	if area is CommonArea:
		return "CommonArea"


	return "default"
