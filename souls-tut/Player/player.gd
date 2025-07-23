extends CharacterBody3D


@onready var input_gatherer = $Input as InputGatherer
@onready var model = $Model as PlayerModel
@onready var visuals = $Visuals as PlayerVisuals
@onready var camera_mount = $CameraMount
@onready var fancy_camera: FancyCamera = %FancyCamera
@onready var camera_focus: Node3D = $CameraFocus

func _ready():
	Print.print_ready(self)
	visuals.accept_model(model)
	model.animator.play("run")


func _physics_process(delta):
	# CONTROLLER (INPUT)
	var input = input_gatherer.gather_input()
	
	# MODEL (SIMULATION)
	model.update(input, delta)
	
	# VISUALISE (PRESENTATION)
	# Visuals -> follow parent transformations
	
	input.queue_free()
