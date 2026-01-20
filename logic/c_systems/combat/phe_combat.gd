@tool
extends BaseCombat
class_name PHECombat

@onready var me: PHCharacter = $".."
@onready var bones: EnemyBones = %bones


func initialise_implementation():
	pass


func get_parent_node_of_weapons() -> Node3D:
	return bones


func is_player() -> bool:
	return false


func get_character() -> BaseCharacter:
	return me
