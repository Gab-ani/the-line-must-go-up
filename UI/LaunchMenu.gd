extends Node2D

@onready var difficulty = $Difficulty


func _on_new_game_pressed() -> void:
	var game = preload("res://Game.tscn").instantiate() as Game
	get_tree().root.add_child(game)
	game.generate_new(difficulty.get_selected_id())
	call_deferred("queue_free")


func _on_continue_pressed() -> void:
	var game = preload("res://Game.tscn").instantiate() as Game
	var file_name : String
	if OS.has_feature("standalone"):
		file_name = OS.get_executable_path().get_base_dir() + "/last_game_state.txt"
	else:
		file_name = "res://last_game_state.txt"
	var save_file = FileAccess.open(file_name, FileAccess.READ)
	var json = save_file.get_as_text()
	var state = JSON.parse_string(json)
	#print(state)
	get_tree().root.add_child(game)
	game.load_from_save(state)
	call_deferred("queue_free")
