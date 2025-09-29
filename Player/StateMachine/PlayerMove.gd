@abstract
extends Node
class_name PlayerMove
# the core class for our state machine's states to inherit from

# all moves have a name and an animation that presents them in the visual world
@export var move_name : StringName
@export var animation : StringName


@export_group("transition logic")# Priority is the field that regulates, which PlayerMove is forwarded,
# in case of several options being present.
# for example, Jump action is more important than Run action,
# so if player holds direction input (requirement for Run),
# and presses spacebar at the same time (requirement for Jump),
# system will have both Run and Jump available, but will choose Jump
@export var priority : int = -1
@export var action_map : Dictionary[StringName, StringName] = {
	&"idle" : &"idle",
	&"move" : &"run",
	&"go_up" : &"jump",
	&"midair" : &"midair",
	&"cling" : &"cling",
}

var economy : Economy
var model : PlayerModel
var visuals : Sprite2D
var player : PlayerCharacter
var area_awareness : PlayerAreaAwareness

var enter_move_time : float 

# generally, I prefer to not use recently added @abstract annotation,
# and instead use most of the to-override methods as stubs and default behaviours
func check_relevance(_input : InputPackage) -> StringName:
	return &"continue"


func translate_actions_to_moves(input : InputPackage) -> void:
	for action in input.input_actions:
		if action_map.has(action):
			input.possible_moves.append(action_map[action])


func most_important_move(input : InputPackage) -> StringName:
	input.possible_moves.sort_custom(model.moves_priority_sort)
	return input.possible_moves[0]


func update(_input : InputPackage, _delta : float) -> void:
	pass


func teleport_through_borders() -> void:
	var dimensions : Vector2i = DisplayServer.window_get_size()
	player.global_position.x = fposmod(player.global_position.x, dimensions.x)
	player.global_position.y = fposmod(player.global_position.y, dimensions.y)


func _on_enter_move(input : InputPackage) -> void:
	mark_enter_move()
	on_enter_move(input)

func on_enter_move(_input : InputPackage) -> void:
	pass

# no universal functional here, but I'm still using the wrapper to maintain
# symmetry with _on_enter_move
func _on_exit_move() -> void:
	on_exit_move()

func on_exit_move() -> void:
	pass


func process_ghost_contact(_ghost : Ghost) -> void:
	player.game.lose()


func mark_enter_move() -> void:
	enter_move_time = Time.get_unix_time_from_system()

func get_progress() -> float:
	var now = Time.get_unix_time_from_system()
	return now - enter_move_time

func works_longer_than(time : float) -> bool:
	return get_progress() >= time

func works_less_than(time : float) -> bool:
	return get_progress() < time

func works_between(start : float, finish : float) -> bool:
	var progress = get_progress()
	return progress >= start and progress <= finish

# the only two strictly required methods for serialisation and loading
@abstract func DEV_write_config(config : Dictionary)

@abstract func configure(config : Dictionary)


























# sf sd f
