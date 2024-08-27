class_name Player extends Node2D
@onready var floor = %Floor
@onready var camera = %Camera
@onready var animated_sprite_2d: AnimatedSprite2D = $AnimatedSprite2D

@onready var is_roaming: bool = true
@onready var current_tile = Vector2i(0, 0)

var player_speed = 300
var animation_state: String

signal tile_changed

# Called when the node enters the scene tree for the first time.
func _ready():
	floor.snap_node(self)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if is_roaming:
		_process_movement(delta)
		if camera.is_snapping:
			camera.position = camera.position*0.95 + position*0.05

func _process_movement(delta):
	var movement_vector = Input.get_vector("ui_left", "ui_right", "ui_up", "ui_down")
	if movement_vector != Vector2.ZERO:
		_animate_movement(movement_vector)
		movement_vector.y /= 2
		position += movement_vector * player_speed * delta
		var new_tile = floor.get_map_coordinates(self)
		if new_tile != current_tile:
			current_tile = new_tile
			tile_changed.emit(new_tile)
		camera.is_snapping = true
	else:
		_update_animation_state("idle", "down")
		
func _update_animation_state(new_state: String, direction):
	animation_state = new_state
	animated_sprite_2d.play(str(animation_state, "_", direction))

func _animate_movement(movement: Vector2):
	var direction
	if movement.x > 0:
		direction = "right"
	elif movement.x < 0:
		direction = "left"
	elif movement.y > 0:
		direction = "down"
	else:
		direction = "up"
	_update_animation_state("move", direction)

func enter_combat():
	# Exit roaming phase
	is_roaming = false
	
	# Snap to closest tile
	position = floor.get_snap_position_from_tile(current_tile)

	# Play idle aniomation
	_update_animation_state("idle", "down")
