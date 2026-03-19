@tool
extends BaseCombat
class_name MechFighterCombat

@export var me: MechFighter
@export var parent_node_of_weapons: Node3D


func initialize_implementation():
	pass


func get_parent_node_of_weapons() -> Node3D:
	return parent_node_of_weapons


func is_player() -> bool:
	return false


func get_character() -> BaseStaticCharacter:
	return me


##


func __LOG_B() -> bool:
	return false
