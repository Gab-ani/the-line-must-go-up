extends Node
class_name PlayerInput
# This node's mission is to gather, prepare and pack all player input data
# into one package that will be used by our model later.
# In the current state seems like a total overkill, but it is necessary,
# if our game plans to grow

func gather_input() -> InputPackage:
	var new_input = InputPackage.new()
	
	new_input.input_actions.append(&"idle")
	
	new_input.horizontal_part = Input.get_axis("go_left", "go_right")
	if new_input.horizontal_part != 0:
		new_input.input_actions.append(&"move")
	
	if Input.is_action_pressed("go_up"):
		new_input.input_actions.append(&"go_up")
	
	return new_input














