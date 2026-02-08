extends Node2D


# Called when the node enters the scene tree for the first time.
func _ready():
	DisplayServer.window_set_size(Vector2(325,45))
	print(DisplayServer.screen_get_size())
	DisplayServer.window_set_position(Vector2(DisplayServer.screen_get_size().x,DisplayServer.screen_get_size().y))


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass
