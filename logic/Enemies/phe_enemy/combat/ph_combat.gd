@tool
@icon("res://-assets-/x_misc/x_icons/white/icon_sword.png")
extends BaseCombat
class_name PHECombat

@onready var me: PHCharacter = $".."
@onready var bones: EnemyBones = %bones


func get_parent_node_of_weapons() -> Node3D:
	return bones


func is_player() -> bool:
	return false


func get_character() -> BaseCharacter:
	return me


func get_combat_name() -> String:
	return "Enemy Combat"
