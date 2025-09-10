extends Node3D
class_name PlayerVisuals

var model: PlayerModel

@onready var all_data: Node3D = $all_data

@onready var sword_visuals_1 = $SwordVisuals1
@onready var stamina_label = $"Stamina _bar_"
@onready var health_label = $"Health _bar_"

func _get_mesh_descendants(node: Node) -> Array:
	var descendants := []
	for child in node.get_children():
		if child is MeshInstance3D:
			if child.is_visible_in_tree():
				descendants.append(child)
		descendants.append_array(_get_mesh_descendants(child))
	return descendants

# TODO: flying head without eyes
func accept_model(_model: PlayerModel):
	model = _model

	for child: MeshInstance3D in _get_mesh_descendants(all_data):
		child.skeleton = _model.skeleton.get_path()



func _process(_delta):
	update_resources_interface()
	adjust_weapon_visuals()


func adjust_weapon_visuals():
	# todo: problems when active_weapon not only a sword
	# To snap weapon visuals to the model
	sword_visuals_1.global_transform = model.active_weapon.global_transform

func update_resources_interface():
	stamina_label.text = "Stamina " + "%10.3f" % model.resources.stamina
	health_label.text = "Health " + "%10.3f" % model.resources.health
