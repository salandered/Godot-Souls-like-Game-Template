extends RefCounted
class_name BlendPlayback


var is_blending: bool = false
var duration: float = 0.0 # seconds
var time_spent: float = 0.0 # seconds
## If zero, then it's full previous animation. If one, we play full current animation.
var percentage: float = 0.0 # [0, 1]
var prev_percentage: float = 0.0 # what and why?


func _init(_is_blending: bool = false, _duration: float = 0.0, _time_spent: float = 0.0, _percentage: float = 0.0):
	is_blending = _is_blending
	duration = _duration
	time_spent = _time_spent
	percentage = _percentage

func start(blend_for: float) -> void:
	is_blending = true
	duration = blend_for
	time_spent = 0.0
	percentage = 0.0

func update(delta: float) -> void:
	if not is_blending:
		return
	
	prev_percentage = percentage

	# TODO: should global or anim specific speed scale affect the blend time?
	time_spent += delta
	percentage = time_spent / duration
	
	if percentage >= 1.0:
		# stops blending
		percentage = 1.0
		is_blending = false

func reset() -> void:
	is_blending = false
	duration = 0.0
	time_spent = 0.0
	percentage = 0.0


func time_remaining() -> float:
	return duration - time_spent


func _to_string() -> String:
	if not is_blending:
		return "Blend[OFF]"
	return "Blend[%.0f%% | %.2f/%.2fs]" % [
		percentage * 100,
		time_spent,
		duration
	]
