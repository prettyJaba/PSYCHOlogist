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

var current_interactable = null
var player_node: Node = null

signal dialog_finished(interactable)


# --- Подключение объектов ---
func connect_object(obj: Node) -> void:
	if not obj.is_connected("player_entered", Callable(self, "_on_interactable_entered")):
		obj.connect("player_entered", Callable(self, "_on_interactable_entered"))
	if not obj.is_connected("player_exited", Callable(self, "_on_interactable_exited")):
		obj.connect("player_exited", Callable(self, "_on_interactable_exited"))

func _on_interactable_entered(obj: Node) -> void:
	current_interactable = obj

func _on_interactable_exited(obj: Node) -> void:
	if current_interactable == obj:
		current_interactable = null

# --- Инициализация UI ---
func _init_ui() -> void:
	if get_tree().current_scene.has_node("UI/CanvasLayer/Panel"):
		panel = get_tree().current_scene.get_node("UI/CanvasLayer/Panel")
		label = panel.get_node("RichTextLabel")

# Запуск диалога (вызывается внутри _process при нажатии)
func _start_dialog(lines: Array[String]) -> void:
	if dialog_active:
		return
	dialog_active = true
	text_lines = lines.duplicate()
	current_text_index = 0
	player_node = get_tree().get_nodes_in_group("player")[0] if get_tree().has_group("player") else null
	panel.visible = true
	if player_node:
		player_node.block_movement(true)

	# стартуем первую строку
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

	# запускаем асинхронную печать (вызов без await — работает как корутина в GDScript)
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
	current_text_index += 1  # индекс увеличиваем только после окончания печати
	waiting_for_next = true

func _process(_delta: float) -> void:
	# 1) Если нет активного диалога — менеджер сам слушает нажатие и запускает диалог
	if not dialog_active:
		if current_interactable and Input.is_action_just_pressed("interact"):
			if current_interactable.has_method("on_interacted"):
				current_interactable.on_interacted()
			_start_dialog(current_interactable.get_current_text_lines())
		return

	# 2) Если диалог активен — обрабатываем пропуск / переход
	# если печатается — нажатие должно вызвать пропуск
	if is_typing:
		if Input.is_action_just_pressed("interact"):
			skip_requested = true
		return

	# если допечатано и ждём следующую — нажатие переходит к следующей или завершает
	if waiting_for_next:
		if Input.is_action_just_pressed("interact"):
			waiting_for_next = false
			_start_next_line()
		return

func _end_dialog() -> void:
	panel.visible = false
	if player_node:
		player_node.block_movement(false)

	if current_interactable:
		emit_signal("dialog_finished", current_interactable)

	# сброс состояния
	current_text_index = 0
	is_typing = false
	waiting_for_next = false
	dialog_active = false
	skip_requested = false
	text_lines.clear()
	current_interactable = null
