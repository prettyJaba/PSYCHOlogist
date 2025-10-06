extends Node

func _ready():
	new_game()
	
	print("--- Тест диалог менеджера ---")
	Dialogues.load_dialogues("res://resources/DialogueResource.json")
	Dialogues.start("start")
	var current = Dialogues.get_current()
	print("Говорящий:", current.get("speaker"))
	print("Текст:", current.get("text"))
	
	# Варианты выбора
	for i in range(current["choices"].size()):
		print(str(i) + ": " + current["choices"][i]["text"])

	# Тест выбора игрока
	Dialogues.choose(1)

	# Проверка работы выбора
	current = Dialogues.get_current()
	print("-- После выбора --")
	print("Говорящий:", current.get("speaker"))
	print("Текст:", current.get("text"))


func new_game():
	$Player.start($StartPosition.position)

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("menu"):
		if $CanvasLayer/OptionsMenu.is_visible():
			$CanvasLayer/OptionsMenu.hide()
		else:
			$CanvasLayer/OptionsMenu.popup()
