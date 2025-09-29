extends PlayerMove
# state for falling down

#@export var speed : float = 150 
@export var acceleration : float = 2000
@export var max_horizontal_speed : float = 200

# This looks like a continuous state's transition logic
# because our space-orientation related logic is centralised in area awareness module.
# The "is there land?" check is done there, and if there is, we don't
# even get the &"midair" state key by coming to this function
func check_relevance(input : InputPackage) -> StringName:
	translate_actions_to_moves(input)
	var best_input :StringName = most_important_move(input)
	if best_input != move_name:
		return most_important_move(input)
	return &"continue"


func update(input : InputPackage, delta : float) -> void:
	teleport_through_borders()
	player.velocity.y += area_awareness.gravity * delta
	player.velocity.x += input.horizontal_part * acceleration * delta
	player.velocity.x = clamp(player.velocity.x, -max_horizontal_speed, max_horizontal_speed)
	visuals.flip_h = player.velocity.x < 0
	player.move_and_slide()


func DEV_write_config(config : Dictionary) -> void:
	config[move_name] = {}
	config[move_name]["acceleration"] = acceleration
	config[move_name]["max_horizontal_speed"] = max_horizontal_speed

func configure(config : Dictionary) -> void:
	acceleration = config[move_name]["acceleration"]
	max_horizontal_speed = config[move_name]["max_horizontal_speed"]









