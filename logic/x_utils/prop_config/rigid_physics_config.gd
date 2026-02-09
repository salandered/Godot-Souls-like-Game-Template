class_name RigidPhysicsConfig
extends RefCounted


var mass: float
# 0.0   # Ice - slides forever
# 0.3   # Plastic - slippery
# 1.0   # Wood/default - moderate grip
# 1.5   # Rubber - high grip, stops quickly
var friction: float
# 0.0   # Clay/sand - no bounce, dead stop
# 0.2   # Wood - small bounce
# 0.5   # Plastic ball - medium bounce
# 0.9   # Rubber ball - high bounce
# 1.0   # Superball - perfect bounce (no energy loss)
var bounce: float
# 1.0 - normal gravity (default)
# < 1.0 - floaty, slow fall
# > 1.0 - heavy, fast fall
# 0.0 - no gravity, floats in place
var gravity_scale: float


func _init(
	mass_: float = 1.0,
	friction_: float = 1.0,
	bounce_: float = 0.0,
	gravity_scale_: float = 1.0
) -> void:
	self.mass = mass_
	self.friction = friction_
	self.bounce = bounce_
	self.gravity_scale = gravity_scale_


func _to_string() -> String:
	return "mass: %.2f, fric: %.2f, bnc: %.2f, grav: %.2f" % [mass, friction, bounce, gravity_scale]
