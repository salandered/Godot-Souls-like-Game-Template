extends Node
class_name PlayerFeelings
@onready var model: PlayerModel = %Model

@onready var stamina_label = $"Stamina _bar_"
@onready var health_label = $"Health _bar_"



func _process(_delta):
	update_resources_interface()


func update_resources_interface():
	stamina_label.text = "Stamina " + "%10.3f" % model.resources.stamina
	health_label.text = "Health " + "%10.3f" % model.resources.health
