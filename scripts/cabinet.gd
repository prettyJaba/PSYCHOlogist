extends Node

func _ready():
	new_game()
	SoundManager.stop_music()
	
	for obj in get_tree().get_nodes_in_group("interactable"):
		Dialogues.connect_object(obj)
	Dialogues._init_ui()

func new_game():
	$SubViewport/cabinet_inside/Player.start($SubViewport/cabinet_inside/StartPosition.position)
	SoundManager.play_sfx("street")
	SoundManager.play_sfx("clock")

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("menu"):
		if $CanvasLayer/OptionsMenu.is_visible():
			$CanvasLayer/OptionsMenu.hide()
		else:
			$CanvasLayer/OptionsMenu.popup()
