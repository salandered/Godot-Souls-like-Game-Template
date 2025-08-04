extends Node
class_name EnemyResources

@onready var me: CharacterBody3D = $"../"

@export var max_health: float = 100
@export var health: float = 100


func lose_health(amount: float):
	health -= amount
	if health < 1:
		me.switch_to(SEState.death)


func gain_health(amount: float):
	if health + amount <= max_health:
		health += amount
	else:
		health = max_health
