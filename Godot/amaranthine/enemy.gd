class_name Enemy extends Node2D
@onready var floor = %Floor
@onready var spawn_position = Vector2i(-8 , -28)
@onready var current_position = spawn_position
const VISION_TILE = preload("res://Scenes/vision_tile.tscn")
var vision_cone_range = 8
@onready var player = $"../Player"
var visible_tiles
@onready var main = $".."

# Called when the node enters the scene tree for the first time.
func _ready():
	position = floor.get_snap_position_from_tile(spawn_position)
	_update_vision_cone()
	
	# Change to bounding box
	player.tile_changed.connect(_on_player_tile_changed)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

# Upates visible tiles around the enemy
func _update_vision_cone():
	visible_tiles = _flood_fill()
	for tile in visible_tiles:
		_create_vision_tile(tile)


func _flood_fill():
	var valid_moves = {
		Vector2i(0, 0): vision_cone_range
	}
	
	var flood_queue
	
	var diagonal_movement_cost = sqrt(2)
	var movement_vectors = [
		[Vector2i(1, 0), 1], 
		[Vector2i(-1, 0), 1], 
		[Vector2i(0, 1), 1], 
		[Vector2i(0, -1), 1], 
		[Vector2i(1, 1), diagonal_movement_cost], 
		[Vector2i(1, -1), diagonal_movement_cost],
		[Vector2i(-1, 1), diagonal_movement_cost],
		[Vector2i(-1, -1), diagonal_movement_cost]
	]
	
	flood_queue = [Vector2i(0, 0)]
	
	while flood_queue.size() >= 1:
		# Pop an updated tile
		var tile = flood_queue.pop_front()
		
		# Get the remaining moves from the tile
		var moves_remaining = valid_moves[tile]
		
		# For each possible movement away from the tile, check if the resulting
		# move is possible. If it is, update the tile (push into queue) and 
		# update the remaining moves
		for movement_vector in movement_vectors:
			
			# Check if moves reamining allow movement into the tile
			if movement_vector[1] <= moves_remaining:
				
				# If move is valid, get the resulting move and tile
				var resulting_moves = moves_remaining - movement_vector[1]
				var resulting_tile = tile + movement_vector[0]
				
				# If the move has been seen before, only update if the new
				# movement results in a higher movement count
				if valid_moves.has(resulting_tile):
					if valid_moves[resulting_tile] < resulting_moves:
						valid_moves[resulting_tile] = resulting_moves
						flood_queue.push_back(resulting_tile)
				else:
					valid_moves[resulting_tile] = resulting_moves
					flood_queue.push_back(resulting_tile)
	return valid_moves

func _create_vision_tile(tile):
	var new_vision_tile = VISION_TILE.instantiate()
	new_vision_tile.position = to_local(floor.get_snap_position_from_tile(current_position + tile))
	add_child(new_vision_tile)
	
func _on_player_tile_changed(new_tile):
	var localized_tile = current_position - new_tile
	if visible_tiles.has(localized_tile):
		main.player_detected(self)
