extends Area3D


func _ready() -> void:
	body_entered.connect(_on_body_entered)
	collision_mask = Collision.Masks.ALL_CHARACTERS


func _on_body_entered(body: Node3D) -> void:
	if body is SecretEnemy:
		body.reset_position(20.0)
	elif body is BaseCharacter:
		body.reset_position()
