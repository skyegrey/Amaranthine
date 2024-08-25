class_name Enemy extends Node2D
@onready var floor = %Floor

@onready var spawn_position = Vector2i(-8 , -28)

# Called when the node enters the scene tree for the first time.
func _ready():
	position = floor.get_snap_position_from_tile(spawn_position)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass
