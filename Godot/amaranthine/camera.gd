class_name Camera extends Camera2D

@export var max_zoom: int = 2
@export var min_zoom: float = .5
@export var zoom_speed: float = .15
@export var is_camera_dragging: bool = false

var zoom_level: float = 1
var mouse_drag_position: Vector2

# State variables
var is_snapping: bool = false
var is_lerping_to_enemy: bool = false
var lerp_enemy: Node2D = null

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	_process_zoom()
	if is_camera_dragging:
		_process_camera_move()
	if is_lerping_to_enemy:
		position = position * .95 + lerp_enemy.position * .05
		if (position - lerp_enemy.position).length() <= 0.01:
			is_lerping_to_enemy = false

func _process_zoom():
	if Input.is_action_just_pressed("ui_zoom_in"):
		zoom_level = min(zoom.x + zoom_speed, max_zoom)
		zoom.x = zoom_level
		zoom.y = zoom.x
	elif Input.is_action_just_pressed("ui_zoom_out"):
		zoom_level = max(zoom.x - zoom_speed, min_zoom)
		zoom.x = max(zoom.x - zoom_speed, min_zoom)
		zoom.y = zoom.x

func _process_camera_move():
	pass

func _input(event):
	if event is InputEventMouseButton:
		if event.pressed:
			if not is_camera_dragging:
				mouse_drag_position = event.position
				is_camera_dragging = true
				is_snapping = false
			
		elif not event.pressed:
			is_camera_dragging = false
	
	if event is InputEventMouseMotion:
		if is_camera_dragging:
			move_camera(mouse_drag_position - event.position)
			mouse_drag_position = event.position

func move_camera(movement_vector):
	position += movement_vector / zoom_level

func pan_to_enemy(enemy):
	is_lerping_to_enemy = true
	lerp_enemy = enemy
