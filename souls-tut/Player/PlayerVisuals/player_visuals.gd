extends Node3D
class_name PlayerVisuals

var model: PlayerModel

@onready var beta_joints = $beta/Beta_Joints
@onready var beta_surface = $beta/Beta_Surface
@onready var princess: Node3D = $princess


@onready var sword_visuals_1 = $SwordVisuals1
@onready var stamina_label = $"Stamina _bar_"
@onready var health_label = $"Health _bar_"

# TODO: flying head without eys
func accept_model(_model: PlayerModel):
	model = _model

	for child in princess.get_children():
		if child is MeshInstance3D:
			child.skeleton = _model.skeleton.get_path()

	beta_surface.skeleton = _model.skeleton.get_path()
	beta_joints.skeleton = _model.skeleton.get_path()


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
