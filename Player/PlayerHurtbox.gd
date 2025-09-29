extends Area2D
class_name PlayerHurtbox


@onready var model : PlayerModel = $"../Model"

# we accept this as a signal, but we wrap it into a call as soon as we can
func _on_body_entered(body : Node2D) -> void:
	if body is Ghost:
		model.current_move.process_ghost_contact(body)
