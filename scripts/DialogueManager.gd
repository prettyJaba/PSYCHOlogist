extends Node
class_name DialogueManager

var panel: Node = null
var label: RichTextLabel = null

var typing_speed := 0.05
var is_typing := false
var waiting_for_next := false
var dialog_active := false

var text_lines: Array[String] = []
var current_text_index := 0
var skip_requested := false

# ЗАМЕНА: вместо одного объекта используем стек
var interactables_stack: Array[Node] = []
var player_node: Node = null

# --- Подключение объектов ---
func connect_object(obj: Node) -> void:
	if not obj.is_connected("player_entered", Callable(self, "_on_interactable_entered")):
		obj.connect("player_entered", Callable(self, "_on_interactable_entered"))
	if not obj.is_connected("player_exited", Callable(self, "_on_interactable_exited")):
		obj.connect("player_exited", Callable(self, "_on_interactable_exited"))

func _on_interactable_entered(obj: Node) -> void:
	# Убираем объект если он уже есть в стеке (на случай дублирования сигналов)
	if obj in interactables_stack:
		interactables_stack.erase(obj)
	# Добавляем объект в конец стека (последний вошедший будет доступен для взаимодействия)
	interactables_stack.append(obj)

func _on_interactable_exited(obj: Node) -> void:
	# Удаляем объект из стека при выходе из зоны
	if obj in interactables_stack:
		interactables_stack.erase(obj)

# --- Инициализация UI ---
func _init_ui() -> void:
	if get_tree().current_scene.has_node("UI/CanvasLayer/Panel"):
		panel = get_tree().current_scene.get_node("UI/CanvasLayer/Panel")
		label = panel.get_node("RichTextLabel")

# Запуск диалога (теперь запускает только одну реплику)
func _start_dialog(lines: Array[String]) -> void:
	if dialog_active or lines.is_empty():
		return
	
	dialog_active = true
	text_lines = lines.duplicate()
	current_text_index = 0
	player_node = get_tree().get_nodes_in_group("player")[0] if get_tree().has_group("player") else null
	panel.visible = true
	if player_node:
		player_node.block_movement(true)

	# стартуем единственную строку
	_start_next_line()

func _start_next_line() -> void:
	if is_typing:
		return
	if current_text_index >= text_lines.size():
		_end_dialog()
		return

	var full_text := text_lines[current_text_index]
	label.text = ""
	skip_requested = false
	is_typing = true
	waiting_for_next = false

	# запускаем асинхронную печать
	_type_text(full_text)

# Асинхронная печать
func _type_text(full_text: String) -> void:
	for i in range(full_text.length()):
		if skip_requested:
			break
		label.text += full_text[i]
		# воспроизведение sfx — убери проверку, если SoundManager точно автолоад
		SoundManager.play_sfx("text")
		await get_tree().create_timer(typing_speed).timeout

	# если был запрос на пропуск — дописываем остаток
	if skip_requested:
		label.text = full_text

	is_typing = false
	current_text_index += 1
	waiting_for_next = true

func _process(_delta: float) -> void:
	# Получаем текущий активный объект (последний в стеке)
	var current_interactable = interactables_stack.back() if not interactables_stack.is_empty() else null
	
	# 1) Если нет активного диалога — менеджер сам слушает нажатие и запускает диалог
	if not dialog_active:
		if current_interactable and Input.is_action_just_pressed("interact"):
			if current_interactable.has_method("on_interacted"):
				current_interactable.on_interacted()
			
			# Получаем реплики (теперь только одну) и запускаем диалог
			var lines = current_interactable.get_current_text_lines()
			if not lines.is_empty():
				_start_dialog(lines)
		return

	# 2) Если диалог активен — обрабатываем пропуск / завершение
	# если печатается — нажатие должно вызвать пропуск
	if is_typing:
		if Input.is_action_just_pressed("interact"):
			skip_requested = true
		return

	# если допечатано и ждём — нажатие завершает диалог
	if waiting_for_next:
		if Input.is_action_just_pressed("interact"):
			# Переходим к следующей реплике для этого объекта
			if current_interactable and current_interactable.has_method("advance_to_next_line"):
				current_interactable.advance_to_next_line()
			_end_dialog()
		return

func _end_dialog() -> void:
	panel.visible = false
	if player_node:
		player_node.block_movement(false)

	# сброс состояния
	current_text_index = 0
	is_typing = false
	waiting_for_next = false
	dialog_active = false
	skip_requested = false
	text_lines.clear()
