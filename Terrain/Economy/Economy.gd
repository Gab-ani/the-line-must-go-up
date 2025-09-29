extends Node2D
class_name Economy
# the core class that abstracts-out everything that is related to coins, scores etc

@export var player : PlayerCharacter
@export var map : GeneratedMap
@export var coin_scene : PackedScene = preload("uid://cj1p0yhv8a8gx")
@export var coins_to_spawn : int = 6

@onready var equity_label : Label = $"../EquityLabel"
@onready var game : Game = $".."

var equity : int = 0


#func _ready() -> void:
	#spawn_coins()

# request a bunch of epty spaces from our map and instantiate coins there
func spawn_coins() -> void:
	var coin_positions : Array[Vector2] = map.provide_air_positions(coins_to_spawn)
	#print(coin_positions)
	for i in coins_to_spawn:
		var new_coin = coin_scene.instantiate() as Coin
		new_coin.global_position = coin_positions[i]
		new_coin.economy = self
		add_child(new_coin)

# this method is being called by a coin when it is touched by player
func coin_acquired() -> void:
	equity += 1
	equity_label.text = "equity " + str(equity)
	if equity == coins_to_spawn:
		game.win()

# serialisation
func save_self(state : Dictionary) -> void:
	state["economy"] = {}
	state["economy"]["equity"] = equity
	state["economy"]["coins"] = []
	for child in get_children():
		if child is Coin:
			state["economy"]["coins"].append(child.global_position)


func create_from_save(state : Dictionary) -> void:
	equity = int(state["economy"]["equity"])
	equity_label.text = "equity " + str(equity)
	for entry : String in state["economy"]["coins"]:
		var split = entry.remove_chars("(").remove_chars(")").split(",")
		var new_coin = coin_scene.instantiate() as Coin
		new_coin.global_position = Vector2(float(split[0]), float(split[1]))
		new_coin.economy = self
		add_child(new_coin)

























