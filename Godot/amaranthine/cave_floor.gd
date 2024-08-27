class_name CaveFloor extends TileMap


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

# Gets the closes tile snap position for a given node
func snap_node(node: Node2D):
	node.global_position = map_to_local(get_map_coordinates(node))

func get_map_coordinates(node):
	var global_pos = node.global_position
	var map_local_position = to_local(global_pos)
	var map_tile = local_to_map(map_local_position)
	return map_tile


func get_snap_position_from_tile(tile: Vector2i):
	var map_tile_position = map_to_local(tile)
	var gloabl_position = to_global(map_tile_position)
	return gloabl_position
