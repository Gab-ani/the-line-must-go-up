extends PlayerMove
# The earthbound locomotion state

@export var max_speed : float = 150 
@export var acceleration : float = 1000
@export var acceleration_period : float = 0.5

# as any continuous state, we pass the torch to whatever state that's more important
func check_relevance(input : InputPackage) -> StringName:
	translate_actions_to_moves(input)
	var best_move = most_important_move(input)
	if best_move != move_name:
		return most_important_move(input)
	return &"continue"

# velocity management, we use a short acceleration period instead of static speed
func update(input : InputPackage, delta : float) -> void:
	teleport_through_borders()
	if works_longer_than(acceleration_period):
		player.velocity.x = max_speed * input.horizontal_part
	else:
		player.velocity.x += acceleration * input.horizontal_part * delta
		player.velocity.x = clamp(player.velocity.x, -max_speed, max_speed)
	visuals.flip_h = player.velocity.x < 0
	player.move_and_slide()


func DEV_write_config(config : Dictionary) -> void:
	config[move_name] = {}
	config[move_name]["max_speed"] = max_speed
	config[move_name]["acceleration"] = acceleration
	config[move_name]["acceleration_period"] = acceleration_period

func configure(config : Dictionary) -> void:
	max_speed = config[move_name]["max_speed"]
	acceleration = config[move_name]["acceleration"]
	acceleration_period = config[move_name]["acceleration_period"]











