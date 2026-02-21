extends RefCounted
class_name ra


## MOST BASIC

static func coinflip() -> bool:
	return randi() % 2 == 1


## Returns true with given probability (0.0 to 1.0)
static func chance(probability: float, coefficient: float = 1.0) -> bool:
	return randf() < probability * coefficient


## Returns random integer between min and max (inclusive)
static func int_range(min_val: int, max_val: int) -> int:
	return randi_range(min_val, max_val)

## Returns random float between min and max (inclusive)
static func float_range(min_val: float, max_val: float) -> float:
	return randf_range(min_val, max_val)

## Returns random time between min and max
static func wait_time(min_seconds: float = 0.5, max_seconds: float = 2.0) -> float:
	return randf_range(min_seconds, max_seconds)


## Angle
# region


## Returns random movement direction (normalized Vector3)
static func wander_direction() -> Vector3:
	var angle: float = randf() * TAU
	return Vector3(cos(angle), 0.0, sin(angle)).normalized()

## Returns random angle in radians for rotation variance
static func angle_variance(max_degrees: float = 45.0) -> float:
	return randf_range(-deg_to_rad(max_degrees), deg_to_rad(max_degrees))

## Returns random patrol point offset for wandering
static func patrol_offset(max_radius: float = 5.0) -> Vector3:
	var angle: float = randf() * TAU
	var radius: float = randf() * max_radius
	return Vector3(cos(angle) * radius, 0.0, sin(angle) * radius)


# endregion


## Pick weighted (dict)
# region

## Pick random weighted element from array based on weights
## Example: pick_weighted([1, 2, 3], [0.2, 0.4, 0.4]) returns 1 with 20% chance
static func pick_weighted(items: Array[Variant], weights: Array[float]) -> Variant:
	if items.is_empty() or weights.is_empty() or items.size() != weights.size():
		return null
	
	var total_weight: float = 0.0
	for weight in weights:
		total_weight += weight
	
	var random_value: float = randf() * total_weight
	var current_weight: float = 0.0
	
	for i in range(items.size()):
		current_weight += weights[i]
		if random_value <= current_weight:
			return items[i]
	
	return items[-1]

## Pick random value from dictionary where keys are values and dict values are probabilities
## Example: pick_weighted_dict({1: 0.2, 2: 0.4, 3: 0.4}) returns 1 with 20% chance
## {1: 0.2, 2: 0.4, 3: 0.4} is the same as {1: 2, 2: 4, 3: 4}
## Sum of the values doesnt matter. It will be normalised
static func ipick_weighted(weighted_values: Dictionary[int, float]) -> int:
	if weighted_values.is_empty():
		return 0
	
	var keys: Array[int] = []
	var values: Array[float] = []
	for key in weighted_values.keys():
		keys.append(key)
		values.append(weighted_values[key])
	
	return pick_weighted(keys, values)


static func spick_weighted(weighted_values: Dictionary[String, float]) -> String:
	if weighted_values.is_empty():
		return ""
	
	var keys: Array[String] = []
	var values: Array[float] = []
	for key in weighted_values.keys():
		keys.append(key)
		values.append(weighted_values[key])
	
	return pick_weighted(keys, values)


static func snpick_weighted(weighted_values: Dictionary[StringName, float]) -> String:
	if weighted_values.is_empty():
		return ""
	
	var keys: Array[StringName] = []
	var values: Array[float] = []
	for key in weighted_values.keys():
		keys.append(key)
		values.append(weighted_values[key])
	
	return pick_weighted(keys, values)

# endregion


## Pick random element from array
# region

static func pick_random_array(array: Array) -> Variant:
	if array.is_empty():
		return null
	return _pick_random(array)


static func pick_random(...elements: Array) -> Variant:
	return pick_random_array(elements)


static func spick_random_array(array: Array[String]) -> String:
	if array.is_empty():
		return ""
	return _pick_random(array)


static func spick_random(...elements: Array) -> String:
	var _elements: Array[String] = TypeCast.array_of_string(elements)
	return spick_random_array(_elements)


static func snpick_random(...elements: Array) -> StringName:
	var _elements: Array[StringName] = TypeCast.array_of_string_name(elements)
	return _pick_random(_elements)


## returns 0 if empty
static func ipick_random_array(array: Array[int]) -> int:
	if array.is_empty():
		return 0
	return _pick_random(array)


static func ipick_random(...elements: Array) -> int:
	var _elements: Array[int] = TypeCast.array_of_int(elements)
	return ipick_random_array(_elements)


## returns 0.0 of empty
static func fpick_random_array(array: Array[float]) -> float:
	if array.is_empty():
		return 0.0
	return _pick_random(array)


static func fpick_random(...elements: Array) -> float:
	var _elements: Array[float] = TypeCast.array_of_float(elements)
	return fpick_random_array(_elements)


static func _pick_random(array: Array) -> Variant:
	return array[randi_range(0, array.size() - 1)]

# endregion


##

static func get_random_vibrant_color() -> Color:
	return Color.from_hsv(randf(), 0.9, 0.9)