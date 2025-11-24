extends Node

@export var target_node: Node3D
@export var turned_on: bool = false
@export var path_color_a := Color.YELLOW
@export var path_color_b := Color.GREEN
@export var path_duration: float = 60

var path_points: PackedVector3Array = []
var previous_position: Vector3 = Vector3.INF

@export var color_cycle_speed: float = 2.0
var time_elapsed: float = 0.0

func _process(delta: float) -> void:
	if not turned_on:
		return
	time_elapsed += delta
	if not is_instance_valid(target_node):
		previous_position = Vector3.INF
		return

	var current_position := target_node.global_position

	if previous_position != Vector3.INF:
		# 1. Calculate the interpolation factor using a sine wave.
		# This creates a smooth value that oscillates between 0.0 and 1.0.
		var t := (sin(time_elapsed * color_cycle_speed) + 1.0) / 2.0
		
		var current_color := path_color_a.lerp(path_color_b, t)
		
		DebugDraw3D.draw_line(previous_position, current_position, current_color, path_duration)
	
	previous_position = current_position


func _input(event: InputEvent) -> void:
	if event.is_action_pressed(RawAction.t5):
		print_.dev("Debug path cleared.")
		path_points.clear()
