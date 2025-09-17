extends BaseWeapon

@onready var _handle: Marker3D = $Handle
@onready var _weapon_hurt_box: WeaponHurtBox = $WeaponHurtBox
@onready var visuals: Node3D = $Visuals

# heres sword specific logic
func _ready():
	# all BaseWeapon API
	var mesh: MeshInstance3D = visuals.get_child(0)
	assert(mesh and mesh is MeshInstance3D)
	
	weapon_handle = _handle
	weapon_hurt_box = _weapon_hurt_box
	weapon_visuals = mesh
	weapon_name = "smith_sword"
	
	base_damage = 10
	basic_attacks = {
		CombatAction.light_attack_pressed: PS.longsword_1
	}

	super._ready()
