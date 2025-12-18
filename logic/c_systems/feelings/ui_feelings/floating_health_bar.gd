class_name FloatingHealthBar
extends Control

## Visual Settings
const Y_OFFSET_PIXELS = -50  # Shift up from the anchor point
const HIDE_DISTANCE = 30.0   # Hide bar if enemy is too far

## Refs
var _anchor_node: Node3D     # The point on the enemy to track (e.g. Head)
var _camera: Camera3D

# Internal state
var _max_health: float
var _target_health: float

# From your existing UI logic references
@onready var health_bar: TextureProgressBar = %HealthBar
@onready var ghost_bar: TextureProgressBar = %GhostBar  # Put this BEHIND health bar
@onready var tween_health: Tween
@onready var tween_ghost: Tween


func setup(anchor: Node3D, max_hp: float, current_hp: float):
	_anchor_node = anchor
	_camera = get_viewport().get_camera_3d()
	
	_max_health = max_hp
	_target_health = current_hp
	
	health_bar.max_value = max_hp
	health_bar.value = current_hp
	ghost_bar.max_value = max_hp
	ghost_bar.value = current_hp
	
	# Start hidden to avoid 1 frame flicker at (0,0)
	modulate.a = 0 
	show()
	
	# Fade in
	var tw = create_tween()
	tw.tween_property(self, "modulate:a", 1.0, 0.3)


func update_health(new_health: float):
	# 1. Instant or Fast Health Drop (The Red Bar)
	if tween_health: tween_health.kill()
	tween_health = create_tween()
	tween_health.tween_property(health_bar, "value", new_health, 0.1).set_ease(Tween.EASE_OUT)
	
	# 2. Delayed Ghost Drop (The Yellow/White Bar)
	# This creates that satisfying "Souls" impact
	if tween_ghost: tween_ghost.kill()
	tween_ghost = create_tween()
	
	# Wait 0.5s, then drain slowly
	tween_ghost.tween_interval(0.5) 
	tween_ghost.tween_property(ghost_bar, "value", new_health, 0.6).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)


func _process(_delta: float) -> void:
	# Safety checks
	if not is_instance_valid(_anchor_node):
		queue_free() # Enemy died, destroy UI
		return
	
	if not is_instance_valid(_camera):
		_camera = get_viewport().get_camera_3d()
		return

	# --- 3D to 2D Projection ---
	var anchor_pos_3d = _anchor_node.global_position
	
	# Check if behind camera
	if _camera.is_position_behind(anchor_pos_3d):
		visible = false
		return
	
	# Check distance (Optional optimization)
	var dist = _camera.global_position.distance_to(anchor_pos_3d)
	if dist > HIDE_DISTANCE:
		visible = false
		return
	
	visible = true
	
	# Project to screen
	var screen_pos = _camera.unproject_position(anchor_pos_3d)
	
	# Apply Offset and center alignment
	# (Subtract half width so the bar is centered on the head)
	position = screen_pos + Vector2(-size.x / 2, Y_OFFSET_PIXELS)