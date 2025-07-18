extends TextureProgressBar
class_name HealthBar

@export var health_system: HealthSystem
# TODO
@onready var enemy_base: CharacterBody3D = $'../../..'

func _ready():
	if health_system:
		value = health_system.total_health
		health_system.health_updated.connect(_on_health_updated)

func _on_health_updated(new_health):
	value = new_health
