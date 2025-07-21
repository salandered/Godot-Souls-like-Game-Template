extends CharacterBody3D


@onready var input_gatherer = $Input as InputGatherer
@onready var model = $Model as PlayerModel
@onready var visuals = $Visuals as PlayerVisuals
@onready var camera_mount = $CameraMount
@onready var fancy_camera: FancyCamera = %FancyCamera
@onready var camera_focus: Node3D = $CameraFocus

func _ready():
	print("Player is ready")
	visuals.accept_model(model)
	model.animator.play("run")


func _physics_process(delta):
	# CONTROLLER
	var input = input_gatherer.gather_input()
	
	# MODEL
	model.update(input, delta)
	
	# VISUALISE
	# Visuals -> follow parent transformations
	
	input.queue_free()
