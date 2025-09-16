extends TextureButton

@export var next_scene: String = "res://scenes/computer.tscn"  # Путь к сцене

func _ready():
	connect("pressed", _on_pressed)  # Подключаем сигнал к функции

func _on_pressed():
	print("Монитор нажат! Переход к сцене: ", next_scene)
	if next_scene != "":
		get_tree().change_scene_to_file(next_scene)  # Меняем сцену
