extends Node2D

@onready var difficulty = $Difficulty
# this godawful text is the only thing that I AIed into existence for this project
@onready var complain_label = $"complain label" 

func _physics_process(delta):
	if complain_label.visible:
		complain_label.position.x -= 10 * delta

func _on_new_game_pressed() -> void:
	var game = load("res://Game.tscn").instantiate() as Game
	get_tree().root.add_child(game)
	game.generate_new(difficulty.get_selected_id())
	call_deferred("queue_free")


func _on_exit_pressed() -> void:
	get_tree().root.propagate_notification(NOTIFICATION_WM_CLOSE_REQUEST)
	get_tree().quit()


func _on_complain_pressed():
	complain_label.show()
	
