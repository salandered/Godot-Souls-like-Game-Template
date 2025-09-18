extends BaseWeapon
class_name HFSMWeapon

@onready var _weapon_hurt_box: WeaponHurtBox = %WeaponHurtBox
@onready var visuals: Node3D = %Visuals

# heres sword specific logic
func _ready():
	# all BaseWeapon API
	var mesh: MeshInstance3D = visuals.get_child(0)
	assert(mesh and mesh is MeshInstance3D)
	
	weapon_hurt_box = _weapon_hurt_box
	weapon_visuals = mesh
	weapon_name = "Halberd"
	
	base_damage = 10
	basic_attacks = {
		
	}

	super._ready()

func get_hit_data():
	return holder.get_lowest_active_state().pack_hit_data(self)
