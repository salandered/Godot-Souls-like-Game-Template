extends Resource
class_name InputPackage

var input_direction: Vector2

# NOTE: for now actions contains player states like PS.run
var actions: Array[String]
var combat_actions: Array[String]

# Target
var target_lock_pressed: bool = false
var target_lock_long_pressed: bool = false

# Fancy camera
var forward_input := 0.0
var orbit_input := 0.0
