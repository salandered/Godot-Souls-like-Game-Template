@abstract
class_name BaseCharacterMovement
extends NodeCharacterSystem


## DOCS
# region
# - what we call 'move' is officially called 'translate' i suppose
#   'move' might be seen too abstract but it is used as well (like in Blender3D G key)
# - 'rotate' for rotating the character.
# endregion


var _character: BaseCharacter
var _area_awareness: BaseAreaAwareness


class AllowedAngle:
	var value: float
	var cut: float

	func _init(_value: float, _cut: bool = false) -> void:
		self.value = _value
		self.cut = _cut


func initialise(character: BaseCharacter, area_awareness: BaseAreaAwareness):
	self._character = character
	self._area_awareness = area_awareness


func get_character() -> BaseCharacter:
	return _character

func get_area_awareness() -> BaseAreaAwareness:
	return _area_awareness


## GETTERS
# region


func get_curr_velocity_len() -> float:
	return get_character().velocity.length()

func get_curr_xz_velocity_len() -> float:
	return Vector3(get_character().velocity.x, 0, get_character().velocity.z).length()

func get_curr_y_velocity() -> float:
	return get_character().velocity.y

func face_dir() -> Vector3:
	return get_character().basis.z


const FALL_VELOCITY_THRESHOLD = -0.5

func is_actively_falling() -> bool:
	if get_character().is_on_floor():
		return false
	
	# should fall faster than the threshold
	return get_curr_y_velocity() < FALL_VELOCITY_THRESHOLD


func direction_to_(target: Variant) -> Vector3:
	if target is Node3D:
		return get_character().global_position.direction_to(target.global_position)
	elif target is Vector3:
		return get_character().global_position.direction_to(target)
	else:
		push_error("Invalid target type for direction_to_")
		return Vector3.ZERO

# endregion


## BASIC MOVING
# region

func set_velocity(velocity: Vector3):
	get_character().velocity = velocity


## - multiplier will affect gravity (default or specified)
## - if no gravity specified, default will be used
## - will be applied only if not is_on_floor() 
##       - consider making force apply flag if this will cause problems
## - returns true if was applied
func apply_gravity(delta: float, multiplier: float = 1.0, gravity: float = u.gravity) -> bool:
	if not get_character().is_on_floor():
		get_character().velocity.y -= gravity * delta * multiplier
		return true
	return false


## TODO: make one function out of these three 
func apply_friction_xz(delta: float, friction_value: float = 5.0):
	var new_velocity := get_character().velocity
	new_velocity.x = move_toward(new_velocity.x, 0.0, friction_value * delta)
	new_velocity.z = move_toward(new_velocity.z, 0.0, friction_value * delta)
	get_character().velocity = new_velocity


func apply_friction(delta: float, friction_value: float = 5.0):
	var horizontal_vel := Vector3(get_character().velocity.x, 0, get_character().velocity.z)
	horizontal_vel = horizontal_vel.move_toward(Vector3.ZERO, friction_value * delta)
	
	var new_velocity := get_character().velocity
	new_velocity.x = horizontal_vel.x
	new_velocity.z = horizontal_vel.z
	get_character().velocity = new_velocity

func smooth_xz_stop(delta: float, decel_speed: float):
	var horizontal_vel := Vector3(get_character().velocity.x, 0, get_character().velocity.z)
	horizontal_vel = horizontal_vel.move_toward(Vector3.ZERO, decel_speed * delta)
	get_character().velocity.x = horizontal_vel.x
	get_character().velocity.z = horizontal_vel.z

# endregion


## MOVING WITH ROOT
# region 

## applies a local-space velocity (e.g., from root motion) to character
func apply_local_velocity_as_global(local_velocity: Vector3):
	get_character().velocity = get_character().get_quaternion() * local_velocity


# endregion


## Applies an immediate vertical upward force.
## - force: The vertical velocity to apply.
## - reset_y_velocity: If true, ignores current falling speed (guarantees consistent jump height).
func apply_spring_force(force: float, reset_y_velocity: bool = true) -> void:
	var current_vel := get_character().velocity
	
	__log_("current_vel", current_vel)
	if reset_y_velocity:
		current_vel.y = force
	else:
		current_vel.y += force
		
	set_velocity(current_vel)
	__log_("current_vel", current_vel)

## __LOGGING
# region

func __LOG_B() -> bool:
	return false

func __LOG_INDENT() -> int:
	return 0

## just indent:


func __pp_vel_y() -> String:
	return pp.s(get_curr_y_velocity())

func __pp_gl_pos_y() -> String:
	return pp.s(get_character().global_position.y)

func __pp_vel_xz_len() -> String:
	return pp.s(get_curr_xz_velocity_len())

func __pp_vel() -> String:
	return pp.s("vel.y / gl_pos.y / vel.xz.len", __pp_vel_y(), __pp_gl_pos_y(), __pp_vel_xz_len())

# endregion
