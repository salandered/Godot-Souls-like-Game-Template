extends Area3D


func _ready() -> void:
	body_entered.connect(_on_body_entered)
	collision_mask = Collision.Masks.ALL_CHARACTERS


func _on_body_entered(body: Node3D) -> void:
	if body is BaseCharacter:
		body.reset_position()
