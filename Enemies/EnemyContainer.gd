extends Node2D
class_name EnemyContainer

@export var player : PlayerCharacter
@export var map : GeneratedMap
@export var ghost : PackedScene = preload("uid://jxw75jfis0wh")

@export var enemies_amount : int = 4

var difficulty_config : Dictionary

#func _ready() -> void:
	#spawn_enemies()


func spawn_enemies() -> void:
	for i in enemies_amount:
		var spawn_coords = map.provide_random_empty_quad(3)
		var new_ghost = ghost.instantiate() as Ghost
		new_ghost.global_position = Vector2(spawn_coords.x * map.tile_set.tile_size.x, spawn_coords.y * map.tile_set.tile_size.y)
		new_ghost.hivemind = self
		new_ghost.player = player
		
		new_ghost.wandering_speed = difficulty_config["wandering_speed"]
		new_ghost.angry_speed = difficulty_config["angry_speed"]
		new_ghost.acceleration = difficulty_config["acceleration"]
		new_ghost.player_detection_radius = difficulty_config["player_detection_radius"]
		new_ghost.player_loss_radius = difficulty_config["player_loss_radius"]
		new_ghost.lost_chase_duration = difficulty_config["lost_chase_duration"]
		
		add_child(new_ghost)

# we generate several random vectors, then do a classical single pass maximum search
# for the target that is the most remote from all enemies we have
# this is done to "de-clamp" ghosts when they request wander paths
func provide_next_wander_target() -> Vector2i:
	var target_candidates : Array[Vector2i]
	for i in 5:
		target_candidates.append(Vector2i(randi_range(0, map.raw_pixel_size.x), randi_range(0, map.raw_pixel_size.y)))
	var max_distance_sum = 0
	var best_target = Vector2i.ZERO
	for target in target_candidates:
		var distance = collective_distance(target)
		if distance > max_distance_sum:
			max_distance_sum = distance
			best_target = target
	return best_target

func collective_distance(target : Vector2i) -> float:
	var sum : float = 0
	for child in get_children():
		if child.is_in_group("enemy"):
			sum += target.distance_to(child.global_position)
	return sum


func save_self(state : Dictionary) -> void:
	state["enemies"] = {}
	state["enemies"]["ghosts"] = []
	for child in get_children():
		if child is Ghost:
			var ghost_data : Dictionary = {}
			ghost_data["position"] = child.global_position
			ghost_data["target"] = child.navigation.target_position
			ghost_data["velocity"] = child.velocity
			state["enemies"]["ghosts"].append(ghost_data)


func create_from_save(state : Dictionary) -> void:
	for entry : Dictionary in state["enemies"]["ghosts"]:
		var split = entry["position"].remove_chars("(").remove_chars(")").split(",")
		var new_ghost = ghost.instantiate() as Ghost
		new_ghost.global_position = Vector2(float(split[0]), float(split[1]))
		new_ghost.hivemind = self
		new_ghost.player = player
		add_child(new_ghost)
		split = entry["velocity"].remove_chars("(").remove_chars(")").split(",")
		new_ghost.velocity = Vector2(float(split[0]), float(split[1])) 
		split = entry["target"].remove_chars("(").remove_chars(")").split(",")
		new_ghost.navigation.target_position = Vector2(float(split[0]), float(split[1])) 
















