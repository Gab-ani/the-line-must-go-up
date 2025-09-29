extends Node
class_name PlayerModel
# This is the container for our controller's state machine.
# It is used to manage the lifecycle of its PlayerMove children

@onready var player : PlayerCharacter = $".."
@onready var area_awareness = $"../AreaAwareness"
@onready var animation_player = $"../AnimationPlayer"
@onready var visuals = $"../Visuals"

# if true, then moves data will be pulled from player_config file,
# if false, export fields in states will be used
@export var configure_from_file : bool = true

#@export var DEV_create_config_file : bool = false

var moves : Dictionary[StringName, PlayerMove]
var current_move : PlayerMove

# setup PlayerMove children, forward some universal fields to them,
# then configure move's fields with game logic data
func _ready() -> void:
	#DEV_create_moves_config()
	accept_moves()
	configure_moves()
	current_move = moves[&"idle"]
	current_move.on_enter_move(InputPackage.new())

# the maic cycle of the controller.
# first, the current move thinks if it wants to give control to some other state,
# if it wants, we do the transition routine
# then current move updates player character
func update(input : InputPackage, delta : float) -> void:
	area_awareness.add_context(input)
	
	var transition_verdict = current_move.check_relevance(input)
	if transition_verdict != &"continue":
		#print(current_move.move_name + " -> " + transition_verdict)
		current_move._on_exit_move()
		current_move = moves[transition_verdict]
		current_move._on_enter_move(input)
		animation_player.play(current_move.animation)
	
	current_move.update(input, delta)

# initialization call for our moves, it is done from here because of how godot's
# scene tree readying order works - by now all PlayerMove are ready
func accept_moves() -> void:
	var priority_counter : int = 0
	for child in get_children():
		if child is PlayerMove:
			child.model = self
			child.player = player
			child.visuals = visuals
			child.economy = player.economy
			child.area_awareness = area_awareness
			if child.priority == -1:
				child.priority = priority_counter
			moves[child.move_name] = child
			priority_counter += 1


func configure_moves() -> void:
	if not configure_from_file:
		return
	var file_name : String
	if OS.has_feature("standalone"):
		file_name = OS.get_executable_path().get_base_dir() + "/player_config.txt"
	else:
		file_name = "res://player_config.txt"
	var save_file = FileAccess.open(file_name, FileAccess.READ)
	var json = save_file.get_as_text()
	var config = JSON.parse_string(json)
	#print(config)
	
	area_awareness.configure(config)
	for child in get_children():
		if child is PlayerMove:
			child.configure(config)

# a custom sorting function, more info in PlayerMove.priority field
func moves_priority_sort(a : StringName, b : StringName) -> bool:
	if moves[a].priority > moves[b].priority:
		return true
	else:
		return false


func force_move(move_name : String) -> void:
	current_move._on_exit_move()
	current_move = moves[move_name]
	current_move._on_enter_move(InputPackage.new())
	animation_player.play(current_move.animation)


## dev layer functional, changes configuration files, uncomment thoughtfully and save previous config
## will populate the model config files with the set in editor move params
## to use, uncomment, fix spaces, then uncomment DEV_create_config_file export bool and set true
#func DEV_create_moves _config() -> void:
	#if not DEV_create_config_file:
		#return
	#var config : Dictionary = {}
	#for child in get_children():
		#if child is Play erMove:
			#child.DEV_write_config(config)
	#area _awareness.DEV_write_config(config)
	##print(config)
	#var json = JSON.stringify(config, "\t")
	#var file_name : String
	#if OS.has_feature("standalone"):
		#file_n ame = OS.get_executable_path().get_base_dir() + "/player_config.txt"
	#else:
		#file_name = "res://player_config.txt"
	#var config_file = FileAccess.open(file_name, FileAccess.WRITE)
	#config_file.store_line(json)















