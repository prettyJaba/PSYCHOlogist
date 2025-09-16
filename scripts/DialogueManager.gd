extends Node

class_name DialogueManager

var dialogues = {}          # Словарь со всеми диалогами
var current_id: String = "" # Текущий узел диалога

func _ready():
	load_dialogues("res://data/dialogues.json")
	start("start")

# Загружаем JSON
func load_dialogues(path: String):
	var file = FileAccess.open(path, FileAccess.READ)
	if file:
		var content = file.get_as_text()
		dialogues = JSON.parse_string(content)
		if typeof(dialogues) != TYPE_DICTIONARY:
			push_error("Ошибка загрузки JSON!")
			dialogues = {}

# Начать диалог с узла
func start(dialogue_id: String):
	if dialogue_id in dialogues:
		current_id = dialogue_id
	else:
		push_error("Диалог не найден: " + dialogue_id)

# Получить текущую реплику
func get_current():
	if current_id in dialogues:
		return dialogues[current_id]
	return null

# Перейти к следующему узлу (без выборов)
func next():
	var current = get_current()
	if current and "next" in current:
		current_id = current["next"]
	else:
		push_warning("Нет 'next' у текущего диалога")

# Сделать выбор
func choose(index: int):
	var current = get_current()
	if current and "choices" in current:
		var choices = current["choices"]
		if index >= 0 and index < choices.size():
			current_id = choices[index]["next"]
		else:
			push_warning("Неверный выбор: " + str(index))
