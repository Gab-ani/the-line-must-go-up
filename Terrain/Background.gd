extends Sprite2D
# just a simple backgorund class to match player's movement with parallax-ish effect
# mostly useless, but originally I planned to have a 2d camera,
# and the effect would look dope

@export var player : CharacterBody2D
@export var distance_k : float = 50

func _physics_process(delta) -> void:
	global_position -= player.velocity * delta / distance_k
