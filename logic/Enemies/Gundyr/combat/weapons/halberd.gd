@tool
@icon("res://-assets-/x_misc/x_icons/red/icon_sword.png")
extends HSMEWeapon
class_name BossHalberd

@onready var _weapon_hurt_box: WeaponHurtBox = %WeaponHurtBox
@onready var visuals: Node3D = %Visuals


func _ready():
	var mesh: MeshInstance3D = visuals.get_child(0)
	assert(mesh and mesh is MeshInstance3D)
	
	weapon_hurt_box = _weapon_hurt_box
	weapon_visuals = mesh
	weapon_name = "Halberd"


	super._ready()

func get_hit_data():
	return holder.get_lowest_active_state().pack_hit_data(self)
