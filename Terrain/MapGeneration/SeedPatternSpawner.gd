extends MapGenerationStrategy
class_name SeedPatternStrategy

@export var platforms_amount : int = 35

var noize : FastNoiseLite
var peaks_map : Dictionary[float, Vector2i]
var banned_area : Array[Vector2i]
var platforms_spawned : int 
var keys : Array[float]

# first we clear whatever there is on the map and renew our internal variables
# then we generate a 2d noise and store its values in a hashmap of <float, vector2>, value to coordinate
# we want to add platforms in the highest values, so we need to "sort hashmap keys"
# we also prevent platforms from clamping together,
# when a platform spawns, a small area around the spawn point is now "banned" for future platforms
# the result is a random distribution that guarantees no too-empty and no overpopulated areas
# when the generation is over, we fill all empty cells with navigatable air
func create_map(tile_field : GeneratedMap) -> Dictionary[Vector2i, int]:
	var patterns : Dictionary[Vector2i, int] = {}
	flush()
	tile_field.clear()
	
	for w in range(2, tile_field.width - 6):
		for h in range( 2, tile_field.height - 4):
			peaks_map[noize.get_noise_2d(w, h)] = Vector2i(w, h)
	
	keys = peaks_map.keys().duplicate()
	keys.sort()
	for i in keys.size():
		if not banned(peaks_map[keys[i]], banned_area):
			var pattern_id = select_pattern(tile_field)
			tile_field.set_pattern(peaks_map[keys[i]], tile_field.tile_set.get_pattern(pattern_id))
			patterns[peaks_map[keys[i]]] = pattern_id
			banned_area.append(peaks_map[keys[i]])
			platforms_spawned += 1
			if platforms_spawned == platforms_amount:
				break
	
	for w in tile_field.width:
		for h in tile_field.height:
			if tile_field.get_cell_source_id(Vector2i(w,h)) == -1:
				tile_field.set_air(Vector2i(w,h))
	
	return patterns

func banned(vector : Vector2i, ban_list : Array[Vector2i]) -> bool:
	for ban in ban_list:
		if vector.distance_to(ban) < 6:
			return true
	return false

# TODO consider using metadata probability rate of appearance, currently all equal
func select_pattern(tile_field : TileMapLayer) -> int:
	return randi_range(0, tile_field.tile_set.get_patterns_count() - 1)


func flush() -> void:
	noize = FastNoiseLite.new()
	noize.noise_type = FastNoiseLite.TYPE_SIMPLEX
	noize.frequency = 0.9
	noize.seed = randi()
	#var test_image = noize.get_image(width,height)
	#test_image.save_png("res://Terrain/noise_test_image.png")
	
	peaks_map = {}
	
	banned_area = []
	platforms_spawned = 0
















# pesonal space comment thanks godot
