@abstract
class_name BaseCharacter
extends CharacterBody3D


## should not be null but can't guarantee
@abstract func get_current_state() -> Node


@abstract func react_on_hit(hit_data: HitData) -> void
