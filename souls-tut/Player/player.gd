extends CharacterBody3D


@export var input_gatherer: InputGatherer
@export var model: PlayerModel
@export var visuals: PlayerVisuals
@export var camera_mount: Node3D
@export var collider: CollisionShape3D
@onready var camera_focus: Node3D = %CameraFocus
@onready var fancy_camera: FancyCamera = %FancyCamera

@onready var label: Label = $debug_labels/Label
@onready var label_2: Label = $debug_labels/Label2
@onready var label_3: Label = $debug_labels/Label3

var debug_cams: Array[Node]
var cam_i := 0


func _ready():
	#Print.print_ready(self)
	visuals.accept_model(model)

	debug_cams = get_tree().get_nodes_in_group("debug_cameras")
	Print.print_debug_(debug_cams)
	debug_cams.append(fancy_camera.camera)
	cam_i = len(debug_cams) - 1
	Print.print_debug_("cam_i: " + str(cam_i))

func _process(_delta):
	_update_debug_interface()


func _update_debug_interface():
		var p_pos = model.global_position
		var nest_pos := fancy_camera.nest.global_position
		var camera_pos := fancy_camera.camera.global_position
		
		
		label.text = "player to nest " + "%10.3f" % p_pos.distance_to(nest_pos)
		label_2.text = "player to cam " + "%10.3f" % p_pos.distance_to(camera_pos)

		var free_offset = fancy_camera.free_camera.offset.length() if fancy_camera.free_camera.offset else 0.0
		var locked_offset := fancy_camera.locked_camera.offset.length() if fancy_camera.locked_camera.offset else 0.0
		label_3.text = "offset " + "%10.3f" % free_offset
		label_3.text += "%10.3f" % locked_offset


func _physics_process(delta):
	# CONTROLLER (INPUT)
	var input := input_gatherer.gather_input()
	
	# MODEL (SIMULATION)
	model.update(input, delta)
	
	# VISUALISE (PRESENTATION)
	# Visuals -> follow parent transformations
	
	#input.queue_free() ep 4


func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("debug_cycle_cam"):
		cam_i = (cam_i + 1) % debug_cams.size()
		Print.print_debug_("cam_i: " + str(cam_i))
		if debug_cams[cam_i].has_method("make_current"):
			debug_cams[cam_i].make_current()
