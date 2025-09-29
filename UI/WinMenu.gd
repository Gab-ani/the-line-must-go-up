extends Node2D

@onready var difficulty = $Difficulty

func _on_new_game_pressed() -> void:
	var game = load("res://Game.tscn").instantiate() as Game
	get_tree().root.add_child(game)
	game.generate_new(difficulty.get_selected_id())
	call_deferred("queue_free")


func _on_exit_pressed() -> void:
	get_tree().root.propagate_notification(NOTIFICATION_WM_CLOSE_REQUEST)
	get_tree().quit()
