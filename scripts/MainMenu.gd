extends Control

@onready var options_menu = $OptionsMenu

func _ready() -> void:
	SoundManager.play_music("main")

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func _on_newGameButton_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/cabinet.tscn")

func _on_continueButton_pressed() -> void:
	pass

func _on_optionsButton_pressed() -> void:
	options_menu.popup_centered()
	
func _on_exitButton_pressed() -> void:
	get_tree().quit()
