extends Node

func _ready():
	new_game()

func new_game():
	$Player.start($StartPosition.position)

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("menu"):
		if $CanvasLayer/OptionsMenu.is_visible():
			$CanvasLayer/OptionsMenu.hide()
		else:
			$CanvasLayer/OptionsMenu.popup()
