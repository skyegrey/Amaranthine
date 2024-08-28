class_name Enemy extends Node2D
@onready var floor = %Floor
@onready var spawn_tile = Vector2i(-8 , -28)
@onready var current_tile = spawn_tile
const VISION_TILE = preload("res://Scenes/vision_tile.tscn")
var vision_cone_range = 8
@onready var player = $"../Player"
var visible_tiles
@onready var main = $".."
var animation_state
@onready var sprite = $AnimatedSprite2D
@onready var camera = %Camera
@onready var detection_indicator = $DetectionIndicator
@onready var patrol_locations = [
	Vector2i(-6, 0),
	Vector2i(6, 0)
]
@onready var patrol_location_index = 0
var current_patrol_steps = []
var current_patrol_step_index = 0
var is_patroling = true

@onready var patrol_wait_timer = $PatrolWaitTimer




# Called when the node enters the scene tree for the first time.
func _ready():
	position = floor.get_snap_position_from_tile(spawn_tile)
	_update_vision_cone()
	
	# Change to bounding box
	player.tile_changed.connect(_on_player_tile_changed)
	
	patrol_wait_timer.timeout.connect(_start_next_patrol)

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
	new_vision_tile.position = to_local(floor.get_snap_position_from_tile(current_tile + tile))
	add_child(new_vision_tile)
	
func _on_player_tile_changed(new_tile):
	var localized_tile = current_tile - new_tile
	if visible_tiles.has(localized_tile):
		main.player_detected(self)
		camera.enemy_lerp_finished.connect(_on_camera_lerp_finished)
		is_patroling = false
		patrol_wait_timer.stop()

func _on_camera_lerp_finished():
	# Turn sprite twoards player
	var direction_vector = player.position - position
	var direction = get_vector_facing_direction(direction_vector)
	_update_animation_state("idle", direction)
	
	# Display ! mark
	var tween = get_tree().create_tween()
	
	detection_indicator.visible = true
	var exclamation_animate_up_duration = .1 # Seconds
	var exclamation_sprite_detected_position = -64
	tween.tween_property(
		detection_indicator, 
		"position:y", 
		exclamation_sprite_detected_position, 
		exclamation_animate_up_duration)
	var exclamation_display_duration = .65 # Seconds
	tween.tween_interval(exclamation_display_duration)
	tween.tween_callback(func (): detection_indicator.visible = false)
	
func _update_animation_state(new_state: String, direction):
	animation_state = new_state
	sprite.play(str(animation_state, "_", direction))

func _move_to_tile(next_tile):
	# Calculate the snap positions
	var new_snap_position = floor.get_snap_position_from_tile(current_tile + next_tile)
	var sprite_movement_vector = new_snap_position - position
	
	# Play correct movement animation
	var direction = get_vector_facing_direction(sprite_movement_vector)
	_update_animation_state("move", direction)
	
	# Animate to edge of tile
	var tween = get_tree().create_tween()
	tween.tween_property(sprite, "position", Vector2(0, -32) + sprite_movement_vector / 2, .5)
	tween.tween_callback(
		_teleport_to_next_tile.bind(next_tile, new_snap_position, sprite_movement_vector)
	)

func _teleport_to_next_tile(next_tile, new_snap_position, sprite_movement_vector):
	position = new_snap_position
	sprite.position = Vector2(0, -32) - sprite_movement_vector / 2
	var tween = get_tree().create_tween()
	tween.tween_property(sprite, "position", sprite.position + sprite_movement_vector / 2, .5)
	tween.tween_callback(_tile_movement_finished_animating)
	current_tile += next_tile

func get_vector_facing_direction(vector):
	if vector.x > 0:
		return "right"
	elif vector.x < 0:
		return "left"
	elif vector.y > 0:
		return "down"
	else:
		return "up"
	
func _start_next_patrol():
	# TODO Astar or something??
	if patrol_location_index == 0:
		# Fuck you
		current_patrol_steps = [
			Vector2i(-1, 0), Vector2i(-1, 0), Vector2i(-1, 0), Vector2i(-1, 0), Vector2i(-1, 0)
		]
	else:
		current_patrol_steps = [
			Vector2i(1, 0), Vector2i(1, 0), Vector2i(1, 0), Vector2i(1, 0), Vector2i(1, 0)
		]
	_move_to_tile(current_patrol_steps[0])

func _tile_movement_finished_animating():
	if is_patroling:
		current_patrol_step_index += 1
		if current_patrol_step_index < current_patrol_steps.size():
			_move_to_tile(current_patrol_steps[current_patrol_step_index])
		else:
			# Fuck youuuuuuuuuuuuuu
			current_patrol_step_index = 0
			patrol_location_index += 1
			patrol_location_index %= 2
			patrol_wait_timer.start()
			_update_animation_state("idle", "down")
