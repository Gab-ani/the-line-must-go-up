extends CharacterBody2D
class_name PlayerCharacter
# The top level node that abstracts-out the player.
# internally, most of the controller logic is done via finite state machine
# with thin gate (PlayerModel node) and fat states (PlayerMove heirs)

@export var economy : Economy

@onready var input_gatherer : PlayerInput = $Input
@onready var model : PlayerModel = $Model
@onready var game : Game = $".."


func _physics_process(delta) -> void:
	var input : InputPackage = input_gatherer.gather_input()
	model.update(input, delta)


func save_self(state : Dictionary) -> void:
	state["player"] = {}
	state["player"]["position"] = global_position
	state["player"]["move"] = model.current_move.move_name


func create_from_save(state : Dictionary) -> void:
	var split = state["player"]["position"].remove_chars("(").remove_chars(")").split(",")
	global_position = Vector2(float(split[0]), float(split[1]))
	model.force_move(state["player"]["move"])



















