extends Node
class_name PlayerAreaAwareness
# this class stores all data used to orient and move in space
# it also provides context to our input package, after the player input is gathered,
# but before our state machine decides on what to do with the data

@onready var player = $".."

@export var gravity : float = 9.8

@export var cling_cooldown : float = 0.3
var last_cling_time : float = 0

var last_collision : KinematicCollision2D

func add_context(input : InputPackage) -> void:
	if not player.is_on_floor():
		input.input_actions.append(&"midair")
	if qualifies_for_cling():
		input.input_actions.append(&"cling")
	
	save_collision_data()

func qualifies_for_cling() -> bool:
	return player.is_on_wall_only() and Time.get_unix_time_from_system() - last_cling_time > cling_cooldown

# in the air result is null, and we want to store the last actual collision
func save_collision_data() -> void:
	var collision = player.get_last_slide_collision()
	if collision:
		last_collision = collision

func get_last_wall_normal() -> Vector2:
	return last_collision.get_normal()


func DEV_write_config(config : Dictionary) -> void:
	config["area_awareness"] = {}
	config["area_awareness"]["gravity"] = gravity
	config["area_awareness"]["cling_cooldown"] = cling_cooldown

func configure(config : Dictionary) -> void:
	gravity = config["area_awareness"]["gravity"]
	cling_cooldown = config["area_awareness"]["cling_cooldown"]


















