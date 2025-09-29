extends PlayerMove
# The jump action state
# in our game jump height can be regulated by holding the jump input for some time,
# and we accelerate upwards for the whole time the input is held

@export var vertical_acceleration : float = 3000
@export var horizontal_acceleration : float = 1500
@export var jump_up_duration : float = 0.2

# if player let fo of go_up input or if we achieved the maximum duration - force midair
func check_relevance(input : InputPackage) -> StringName:
	if works_longer_than(jump_up_duration) or not input.input_actions.has(&"go_up"): 
		return &"midair"
	return &"continue"


func update(input : InputPackage, delta : float) -> void:
	teleport_through_borders()
	player.velocity.y -= vertical_acceleration * delta
	player.velocity.x += horizontal_acceleration * input.horizontal_part * delta
	visuals.flip_h = player.velocity.x < 0
	player.move_and_slide()

func on_enter_move(_input : InputPackage) -> void:
	player.velocity.y = 0


func DEV_write_config(config : Dictionary) -> void:
	config[move_name] = {}
	config[move_name]["vertical_acceleration"] = vertical_acceleration
	config[move_name]["horizontal_acceleration"] = horizontal_acceleration
	config[move_name]["jump_up_duration"] = jump_up_duration

func configure(config : Dictionary) -> void:
	vertical_acceleration = config[move_name]["vertical_acceleration"]
	horizontal_acceleration = config[move_name]["horizontal_acceleration"]
	jump_up_duration = config[move_name]["jump_up_duration"]







