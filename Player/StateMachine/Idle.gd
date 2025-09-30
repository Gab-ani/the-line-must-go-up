extends PlayerMove
# The Do Nothing state

# priority is passed to whatever state is inputed aside from our own
func check_relevance(input : InputPackage) -> StringName:
	translate_actions_to_moves(input)
	var best_move = most_important_move(input)
	if best_move != move_name:
		return best_move
	return &"continue"


func on_enter_move(_input : InputPackage) -> void:
	player.velocity = Vector2.ZERO

# we don't have any fields to configure
func DEV_write_config(_config : Dictionary) -> void:
	pass

func configure(_config : Dictionary) -> void:
	pass



