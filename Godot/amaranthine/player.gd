class_name Player extends Node2D
@onready var floor = %Floor
@onready var camera = %Camera

@onready var is_roaming: bool = true

var player_speed = 300

# Called when the node enters the scene tree for the first time.
func _ready():
	floor.snap_node(self)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	_process_movement(delta)


func _process_movement(delta):
	var movement_vector = Input.get_vector("ui_left", "ui_right", "ui_up", "ui_down")
	if movement_vector != Vector2.ZERO:
		movement_vector.y /= 2
		position += movement_vector * player_speed * delta
		if is_roaming:
			camera.position = camera.position*0.975 + position*0.025
