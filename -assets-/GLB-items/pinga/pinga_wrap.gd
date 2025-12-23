@tool
extends Node3D

@export var hide_rings: bool = false
@onready var chain_hp_003: MeshInstance3D = $"Pinga_002/chain HP_003"


func _ready():
	if not chain_hp_003:
		return
	
	chain_hp_003.visible = not hide_rings
