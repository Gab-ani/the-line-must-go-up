extends Area2D
class_name Coin

var economy : Economy

func _ready() -> void:
	body_entered.connect(process_collision)


func process_collision(body : Node2D) -> void:
	if body is PlayerCharacter:
		economy.coin_acquired()
		queue_free()
