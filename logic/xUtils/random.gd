extends RefCounted
class_name ra


# MOST BASIC
static func coinflip() -> bool:
    return randi() % 2 == 1

## Returns true with given probability (0.0 to 1.0)
static func chance(probability: float, coefficient: float = 1.0) -> bool:
    return randf() < probability * coefficient


## Returns random integer between min and max (inclusive)
static func int_range(min_val: int, max_val: int) -> int:
    return randi_range(min_val, max_val)

## Returns random float between min and max
static func float_range(min_val: float, max_val: float) -> float:
    return randf_range(min_val, max_val)

## Returns random time between min and max
static func wait_time(min_seconds: float = 0.5, max_seconds: float = 2.0) -> float:
    return randf_range(min_seconds, max_seconds)
# MOST BASIC END


## Returns true if should attack based on aggression level (0.0 to 1.0)
static func should_attack(aggression: float) -> bool:
    return randf() < aggression

## Returns random attack pattern from available attacks
static func attack_pattern(available_attacks: Array[String]) -> String:
    return pick_random(available_attacks)

## Returns true if enemy should change behavior based on boredom factor
static func should_change_behavior(boredom_threshold: float = 0.3) -> bool:
    return randf() < boredom_threshold

## Returns random state duration for state machine
static func state_duration(min_time: float = 1.0, max_time: float = 3.0) -> float:
    return randf_range(min_time, max_time)

## Returns true if should perform special action based on distance to player
static func distance_triggered_action(distance: float, min_distance: float, max_distance: float, probability: float = 0.2) -> bool:
    if distance < min_distance or distance > max_distance:
        return false
    return randf() < probability

# SOME ROTATION LOGIC
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

# SOME ARRAY LOGIC
## Pick random element from array
static func pick_random(array: Array):
    if array.is_empty():
        return null
    return array[randi() % array.size()]

## Pick random weighted element from array based on weights
static func pick_weighted(items: Array, weights: Array[float]) -> Variant:
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
