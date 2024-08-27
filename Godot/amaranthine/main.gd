extends Node2D
@onready var player = %Player
@onready var camera = %Camera


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

func player_detected(enemy):
	_enter_combat()
	camera.pan_to_enemy(enemy)
	player.enter_combat()

func _enter_combat():
	pass
