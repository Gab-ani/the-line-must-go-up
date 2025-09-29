extends TileMapLayer
class_name GeneratedMap
# This class encapsulates map, generates, saves-loads it,
# and provides some api for other project parts to orient on the generated map

# strategy architecture pattern for life, we delegate map generation,
# I prepared only one, but if there were several, 
# that would be a field in the config file
@export var generation_strategy : MapGenerationStrategy

@export var air_source_id : int = 0
@export var air_atlas_coords : Vector2i = Vector2i(1,0)

var raw_pixel_size : Vector2i
var width : int
var height : int

# we generate map as a set of pattern entries,
# to escape saving avery single cell data into save file,
# we store generated pattern set and assume everything else is navigatable air.
var saved_generation : Dictionary

func _ready() -> void:
	# we strategically chose a dividable unchanged window size
	raw_pixel_size = DisplayServer.window_get_size()
	width = raw_pixel_size.x / tile_set.tile_size.x 
	height = raw_pixel_size.y / tile_set.tile_size.y


func set_air(coords : Vector2i) -> void:
	set_cell(coords, air_source_id, air_atlas_coords)

# while(true) shooting at random coords feels itty-bitty, but our map is relatively "empty"
# and it is faster than getting all quad entries and provide random
func provide_random_empty_quad(size : int) -> Vector2i:
	if size % 2 == 0:
		size += 1
	var random_coords : Vector2i
	while(true):
		random_coords = Vector2i(randi_range(0, width - 1), randi_range(0, width - 1))
		if is_quad_of_navigatable_air(random_coords, size):
			# we know that size is odd at this point
			return Vector2i(random_coords.x + (size - 1) / 2, random_coords.y + (size - 1) / 2) 
	return Vector2i.ZERO

func is_quad_of_navigatable_air(coords : Vector2i, size : int) -> bool:
	for w in size:
		for h in size:
			if not is_air(coords):
				return false
	return true

# a potential upgrade selling performance for unmatched flexibility
# we can analyse through all map, searching for patter and storing entries
# then return a random entry from the list
# is a total overkill for our task for now
#func provide_random_pattern_entry(pattern : TileMapPattern) -> Vector2i:

# used by economy to get some empty spaces for coin spawn
func provide_air_positions(amount : int) -> Array[Vector2]:
	var positions : Array[Vector2] = []
	for i in amount:
		positions.append(generate_air_position())
	return positions

func generate_air_position() -> Vector2:
	while(true):
		var new_coords = Vector2i(randi_range(0, width - 1), randi_range(0, width - 1))
		if not is_air(new_coords):
			continue
		return Vector2(new_coords.x * tile_set.tile_size.x + tile_set.tile_size.x / 2, new_coords.y * tile_set.tile_size.y)
	return Vector2.ZERO

func is_air(coords : Vector2i) -> bool:
	return get_cell_atlas_coords(coords) == Vector2i(3,0)

# just forward here the data we stored when we generated the new map configuration
func save_self(state : Dictionary) -> void:
	state["map"] = saved_generation

# our map saving data format is a dictionary of <Vector2i, id>,
# where key is coords on our map, and id is TileSetPattern's id.
# We just traverce this dictionary and spawn patterns, 
# then fill the free cells with air.
func create_from_save(state : Dictionary) -> void:
	clear()
	saved_generation = state["map"]
	
	for coords : String in state["map"].keys():
		var id : int = int(state["map"][coords])
		var isolated_nums : Array = coords.remove_chars("(").remove_chars(")").remove_chars(" ").split(",")
		var vector : Vector2i = Vector2i(int(isolated_nums[0]), int(isolated_nums[1]))
		set_pattern(vector, tile_set.get_pattern(id))
	
	for w in width:
		for h in height:
			if get_cell_source_id(Vector2i(w,h)) == -1:
				set_air(Vector2i(w,h))


func create_new() -> void:
	saved_generation = generation_strategy.create_map(self)



















