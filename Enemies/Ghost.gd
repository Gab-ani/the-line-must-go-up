extends CharacterBody2D
class_name Ghost
# our main enemy, it is coded as a two-state state machine, but not as fleshed out as player's one

var hivemind : EnemyContainer 
var player : PlayerCharacter

@onready var navigation : NavigationAgent2D = $Navigation
@onready var eyes : RayCast2D = $Eyes
@onready var visuals : Sprite2D = $Visuals
@onready var animation_player = $AnimationPlayer

@export var wandering_speed : float = 50
@export var angry_speed : float = 100
@export var acceleration : float = 2

@export var player_detection_radius : float = 100
@export var player_loss_radius : float = 200
@export var lost_chase_duration : float = 2
var last_visual_contact : float


enum State {WANDERING, ANGRY}
var current_state : State = State.WANDERING


func _ready() -> void:
	animation_player.play("wandering")

func _physics_process(_delta) -> void:
	choose_state()
	move()

# we go from wandering to angy if we saw the player nearby
# we go from angry to wandering state if we lost player's tracks
func choose_state() -> void:
	match current_state:
		State.WANDERING when detected_player():
			go_angry()
		State.ANGRY when lost_player():
			go_wandering()

# wandering state  uses navigation agent's trajectory
# angry state just flies towards the player by a straight line
func move() -> void:
	match current_state:
		State.WANDERING:
			velocity = direction_along_nav_line() * smooth_wandering_speed()
			visuals.flip_h = velocity.x <= 0
			move_and_slide()
			if navigation.is_navigation_finished():
				navigation.target_position = hivemind.provide_next_wander_target()
		State.ANGRY:
			velocity = direction_to_player() * smooth_angry_speed()
			visuals.flip_h = velocity.x <= 0
			move_and_slide()

# if we close enough to player we try to shoot it with raycast,
# to prevent aggroing over walls etc
func detected_player() -> bool:
	return global_position.distance_to(player.global_position) < player_detection_radius and sees_player()

# we always chase for at least lost_chase_duration even after contact or radius loss
# if we haven't seen player for some time we do a final vision and loss radius check
func lost_player() -> bool:
	if Time.get_unix_time_from_system() - last_visual_contact < lost_chase_duration:
		return false
	return not sees_player() or global_position.distance_to(player.global_position) > player_loss_radius

func sees_player() -> bool:
	eyes.target_position = to_local(player.global_position)
	eyes.force_raycast_update()
	if eyes.is_colliding() and eyes.get_collider() is PlayerCharacter:
		last_visual_contact = Time.get_unix_time_from_system()
		return true
	return false

func go_angry() -> void:
	current_state = State.ANGRY
	animation_player.play("angry")

func go_wandering() -> void:
	current_state = State.WANDERING
	animation_player.play("wandering")
	navigation.target_position = hivemind.provide_next_wander_target()

# call me syntaxic sugar Willie Wonka
func direction_to_player() -> Vector2:
	return global_position.direction_to(player.global_position)

func direction_along_nav_line() -> Vector2:
	return global_position.direction_to(navigation.get_next_path_position())

func smooth_wandering_speed() -> float:
	return move_toward(velocity.length(), wandering_speed, acceleration)

func smooth_angry_speed() -> float:
	return move_toward(velocity.length(), angry_speed, acceleration)

















