extends Node2D
class_name Game
# The top-level class describing the game itself, manages winning, losing,
# saving and loading the game state. 
# Saving and loading are heavily delegated to the four nodes that abstract-out core game concepts

@onready var map : GeneratedMap = $Map
@onready var player : PlayerCharacter = $Player
@onready var economy : Economy = $Economy
@onready var enemies : EnemyContainer = $Enemies

# if true, map creation will use difficulty selected in the menues,
# if false, difficulty is ignored and game initializes with the export fields
# in economy, enemies and ghosts nodes
@export var use_config_difficulty : bool = true

var generated_timestamp : float

# TODO consider pulling up all files that have "game_conf" or smth in the name
# to allow a more flexible custom difficulty feature
var difficulty_configs : Dictionary = {
	0 : "game_conf_parkour.txt",
	1 : "game_conf_low.txt",
	2 : "game_conf_medium.txt",
	3 : "game_conf_glhf.txt",
}

# hook onto quit notification to save game
func _notification(what) -> void:
	if what == NOTIFICATION_WM_CLOSE_REQUEST:
		save_game_state()
		get_tree().quit()

# We delegate actual data saving to our core components,
# they save their state to a dictionary however they see fit,
# we then just save this dictionary as a json file.
# Also we check if the game was run from editor or from an actual exe file,
# if from editor - we use the file from project's folder to save user:// folder usage headache
# if from exe - we use the file from the folder, where exe file is run from.
func save_game_state() -> void:
	var state : Dictionary = {}
	map.save_self(state)
	player.save_self(state)
	economy.save_self(state)
	enemies.save_self(state)
	#print(state)
	var json = JSON.stringify(state, "\t")
	var file_name : String
	if OS.has_feature("standalone"):
		file_name = OS.get_executable_path().get_base_dir() + "/last_game_state.txt"
	else:
		file_name = "res://last_game_state.txt"
	var save_file = FileAccess.open(file_name, FileAccess.WRITE)
	save_file.store_line(json)

# interfaces and traits waiting room
func load_from_save(state : Dictionary) -> void:
	map.create_from_save(state)
	player.create_from_save(state)
	economy.create_from_save(state)
	enemies.create_from_save(state)

# New game generation, if we use difficulty, we setup core components as difficulty dictates,
# if no - just forward the generation to them, they will use export fields and defaults.
func generate_new(difficulty : int) -> void:
	if use_config_difficulty:
		var file_name : String
		if OS.has_feature("standalone"):
			file_name = OS.get_executable_path().get_base_dir() + "/" + difficulty_configs[difficulty]
		else:
			file_name = "res://" + difficulty_configs[difficulty]
		var config_file = FileAccess.open(file_name, FileAccess.READ)
		var json = config_file.get_as_text()
		var config = JSON.parse_string(json)
		#print(config)
		enemies.enemies_amount = config["ghosts_to_spawn"]
		enemies.difficulty_config = config
		economy.coins_to_spawn = config["coins_to_spawn"]
	
	map.create_new()
	enemies.spawn_enemies()
	economy.spawn_coins()
	
	generated_timestamp = Time.get_unix_time_from_system()

# all the code below contains only scene management to jump between menues and new games
func win() -> void:
	call_deferred("to_win_menu")
	call_deferred("queue_free")

func to_win_menu() -> void:
	get_tree().change_scene_to_packed(preload("uid://bdirqj6sy7t3x"))


func lose() -> void:
	print(Time.get_unix_time_from_system() - generated_timestamp)
	if Time.get_unix_time_from_system() - generated_timestamp > 1:
		call_deferred("to_loss_menu")
	else:
		call_deferred("to_super_loss_menu")
	call_deferred("queue_free")

func to_loss_menu() -> void:
	get_tree().change_scene_to_packed(preload("uid://bdhgwtdpvbr7q"))

func to_super_loss_menu() -> void:
	get_tree().change_scene_to_packed(preload("uid://rq5he5f2sk7c"))


















