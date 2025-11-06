@tool
@icon("res://-assets-/x_misc/x_icons/red/icon_sword.png")
extends PHEWeapon
class_name PingaBlade

@onready var _weapon_hurt_box: WeaponHurtBox = %WeaponHurtBox
@onready var visuals: Node3D = %Visuals


func _ready() -> void:
	var mesh: MeshInstance3D = visuals.get_child(0)
	assert(mesh and mesh is MeshInstance3D)
	
	weapon_hurt_box = _weapon_hurt_box
	weapon_visuals = mesh
	weapon_name = WeaponNames.big_pinga_blade


	super._ready()
