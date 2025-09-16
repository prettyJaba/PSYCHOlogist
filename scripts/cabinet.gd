extends Node

func _ready():
	new_game()

func new_game():
	$Player.start($StartPosition.position)
