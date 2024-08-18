extends StaticBody2D


@onready var vanish_animation: AnimationPlayer = $VanishAnimation


func destroy_cup() -> void:
	vanish_animation.play("vanish_animation")


func _on_vanish_animation_animation_finished(anim_name: StringName) -> void:
	SignalManager.on_cup_destroyed.emit()
	queue_free()
