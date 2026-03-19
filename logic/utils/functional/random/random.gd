extends RefCounted
class_name ra


## See docs: https://docs.godotengine.org/en/stable/tutorials/math/random_number_generation.html


## MOST BASIC

static func coinflip() -> bool:
	return randi() % 2 == 1


## Returns true with given probability (0.0 to 1.0)
static func chance(probability: float, coefficient: float = 1.0) -> bool:
	return randf() < probability * coefficient


## Returns random integer between min and max (inclusive)
static func irange(min_val: int, max_val: int) -> int:
	return randi_range(min_val, max_val)


## Returns random float between min and max (inclusive)
static func frange(min_val: float, max_val: float) -> float:
	return randf_range(min_val, max_val)


## Pick weighted (dict)
# region

## NOTE: returns null if dict is empty
static func pick_weighted(weighted_values: Dictionary[Variant, float]) -> Variant:
	return _pick_weighted(weighted_values, null)

## Pick random value from dictionary where dict key is a value to pick and dict value is probability.
## Example: pick_weighted_dict({1: 0.2, 2: 0.4, 3: 0.4}) returns 1 with 20% chance
## NOTE: Sum of the weight values does not matter: will be normalised
##  I.e. {1: 0.2, 2: 0.4, 3: 0.4} is the same as {1: 4, 2: 8, 3: 8}
## NOTE: returns 0 if dict is empty
static func ipick_weighted(weighted_values: Dictionary[int, float]) -> int:
	return _pick_weighted(weighted_values, 0)

## NOTE: returns "" if dict is empty
static func spick_weighted(weighted_values: Dictionary[String, float]) -> String:
	return _pick_weighted(weighted_values, "")

## NOTE: returns &"" if dict is empty
static func snpick_weighted(weighted_values: Dictionary[StringName, float]) -> StringName:
	return _pick_weighted(weighted_values, Const.EMPTY_SNAME)

# endregion


## PICK RANDOM ARRAY
# region

static func pick_random_array(array: Array) -> Variant:
	return _pick_random_array(array, null)

static func spick_random_array(array: Array[String]) -> String:
	return _pick_random_array(array, "")

static func snpick_random_array(array: Array[StringName]) -> String:
	return _pick_random_array(array, Const.EMPTY_SNAME)

static func ipick_random_array(array: Array[int]) -> int:
	return _pick_random_array(array, 0)

static func fpick_random_array(array: Array[float]) -> float:
	return _pick_random_array(array, 0.0)

static func pick_random(...elements: Array) -> Variant:
	return pick_random_array(elements)

# endregion


## PICK RANDOM ARRAY VARIADIC
# region

static func spick_random(...elements: Array) -> String:
	var _elements: Array[String] = TypeCast.array_of_string(elements)
	return spick_random_array(_elements)

static func snpick_random(...elements: Array) -> StringName:
	var _elements: Array[StringName] = TypeCast.array_of_string_name(elements)
	return snpick_random_array(_elements)

static func ipick_random(...elements: Array) -> int:
	var _elements: Array[int] = TypeCast.array_of_int(elements)
	return ipick_random_array(_elements)

static func fpick_random(...elements: Array) -> float:
	var _elements: Array[float] = TypeCast.array_of_float(elements)
	return fpick_random_array(_elements)

# endregion


## COLOR

static func get_random_vibrant_color() -> Color:
	return Color.from_hsv(randf(), 0.9, 0.9)


## ANGLE
# region

## Returns random movement direction (normalized Vector3)
static func wander_direction() -> Vector3:
	var angle: float = randf() * TAU
	return Vector3(cos(angle), 0.0, sin(angle)).normalized()

## Returns random angle in radians for rotation variance
static func angle_variance(max_degrees: float = 45.0) -> float:
	return randf_range(-deg_to_rad(max_degrees), deg_to_rad(max_degrees))

# endregion


# INTERNAL

## Pick random weighted element from dictionary based on weights
## Example: _pick_weighted({1: 0.4, 2: 0.6}, 0) returns 1 with 40% chance
## NOTE: Sum of the weight values does not matter: will be normalised
static func _pick_weighted(dict: Dictionary, default_on_error: Variant) -> Variant:
	if dict.is_empty():
		return default_on_error
	
	var items: Array[Variant] = dict.keys()
	var weights: Array[float] = dict.values()
	
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


static func _pick_random_array(array: Array, default_on_error: Variant) -> Variant:
	if array.is_empty():
		return default_on_error
	return array.pick_random()