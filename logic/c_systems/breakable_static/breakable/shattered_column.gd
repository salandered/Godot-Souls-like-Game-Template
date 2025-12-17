extends Node3DSystem

# const DARK_CRATE_PH_MAT_COPIED = preload("uid://je08c3ggwy7m")
@onready var on_shatter_aps_3d: AudioStreamPlayer3D = %OnShatterAPS3D
@onready var on_shatter_aps_3d_2: AudioStreamPlayer3D = %OnShatterAPS3D_2


const BIG_CRASH_ROCK = preload("uid://cre4k58suo6da")
const RIGID_SHATTER_SCRIPT = preload("uid://cvdt0we2m7pch")

var asp_config := ASP3DConfig.new(0.4, -0.3, 6.0, 50, 2, 0.8, "", BIG_CRASH_ROCK)


func _ready() -> void:
	var count: int = 0

	asp_config.set_up_asp(on_shatter_aps_3d)
	asp_config.set_up_asp(on_shatter_aps_3d_2)
	
	on_shatter_aps_3d.play()
	__log_("first play", pp.asp_play_3d(on_shatter_aps_3d))
	
	for shatter: RigidBody3D in get_descendants.rigid_bodies(self):
		__log_("setting script", RIGID_SHATTER_SCRIPT)
		shatter.set_script(RIGID_SHATTER_SCRIPT)
		shatter._ready()
		shatter.mass = 3.0
		shatter.gravity_scale = 1.6
		shatter.collision_layer = Collision.Layers.ITEM_COL
		shatter.collision_mask = Collision.Masks.ITEM_COL_MASK
		count += 1
		
	__log_("~~", "ready of shattered column", count, "were initialised")
	await FrameUtils.wait_process_frames(30)
	on_shatter_aps_3d_2.play()
	__log_("second play", pp.asp_play_3d(on_shatter_aps_3d_2))


## __LOGS
# region

func pp_name() -> String:
	return "ShatteredColumn"

func __LOG_B() -> bool:
	return false

func __LOG_INDENT() -> int:
	return 0

# endregion
