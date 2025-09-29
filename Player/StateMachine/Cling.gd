extends PlayerMove
# Wall grabbing-jumping state

@export var drag_down_speed : float = 100

func check_relevance(input : InputPackage) -> StringName:
	translate_actions_to_moves(input)
	
	# these two are manual checks because we need cling to have higher priority, 
	# but still let go of control if certain events are happening
	if input.possible_moves.has(&"jump"):
		player.velocity.x = area_awareness.get_last_wall_normal().x * 80
		return &"jump"
	if input.input_actions.has(&"move") and input.horizontal_part * area_awareness.get_last_wall_normal().x > 0:
		player.velocity.x = area_awareness.get_last_wall_normal().x * 80
		return &"midair"
	
	var best_input : StringName = most_important_move(input)
	if best_input != move_name:
		return most_important_move(input)
	return &"continue"


func update(_input : InputPackage, delta : float) -> void:
	player.velocity.y += drag_down_speed * delta
	visuals.flip_h = area_awareness.get_last_wall_normal().x < 0
	player.move_and_slide()


func on_enter_move(_input : InputPackage) -> void:
	player.velocity.y = 0

func on_exit_move() -> void:
	area_awareness.last_cling_time = Time.get_unix_time_from_system()


func DEV_write_config(config : Dictionary) -> void:
	config[move_name] = {}
	config[move_name]["drag_down_speed"] = drag_down_speed

func configure(config : Dictionary) -> void:
	drag_down_speed = config[move_name]["drag_down_speed"]







