extends InteractableObject
class_name InteractableObjectChoice

@export var first_choice_text: String = ""
@export var second_choice_text: String = ""

# Пути к кнопкам (настраиваемые, если структура вдруг поменяется)
@export var choice_container_path: NodePath = ^"../../CanvasLayer/ChoiceContainer"
@export var choice1_path: NodePath = ^"../../CanvasLayer/ChoiceContainer/Choice1"
@export var choice2_path: NodePath = ^"../../CanvasLayer/ChoiceContainer/Choice2"


func on_interacted() -> void:
	# Сначала выполняем стандартное поведение базового класса
	super.on_interacted()

	if is_light_on:
		if not Dialogues.is_connected("dialog_finished", Callable(self, "_on_dialog_finished")):
			Dialogues.connect("dialog_finished", Callable(self, "_on_dialog_finished"))


func _show_choices():
	var ui_container: Control = get_tree().current_scene.get_node_or_null("CanvasLayer/ChoiceContainer")
	if ui_container == null:
		push_warning("Не найден ChoiceContainer по пути CanvasLayer/ChoiceContainer")
		return

	var choice1: Button = ui_container.get_node("Choice1")
	var choice2: Button = ui_container.get_node("Choice2")

	# Устанавливаем текст кнопок
	choice1.text = first_choice_text
	choice2.text = second_choice_text

	# Убираем старые сигналы (если уже были подключены)
	for btn in [choice1, choice2]:
		if btn.is_connected("pressed", Callable(self, "_on_choice_pressed")):
			btn.disconnect("pressed", Callable(self, "_on_choice_pressed"))
		btn.connect("pressed", Callable(self, "_on_choice_pressed").bind(btn))

	# Показываем контейнер
	ui_container.visible = true

func _on_dialog_finished(interactable):
	if interactable != self:
		return  # сигнал не для нас
	
	_show_choices()
	
	var player_node = get_tree().get_nodes_in_group("player")[0] if get_tree().has_group("player") else null
	if player_node:
		player_node.block_movement(true)  # блокируем движение, пока не выбран вариант

func _on_choice_pressed(button: Button):
	print("Выбран вариант: ", button.text)

	# Скрываем меню после выбора
	var ui_container = get_tree().current_scene.get_node_or_null("CanvasLayer/ChoiceContainer")
	if ui_container:
		ui_container.visible = false
		
	var player_node = get_tree().get_nodes_in_group("player")[0] if get_tree().has_group("player") else null
	if player_node:
		player_node.block_movement(false)
	
	if Dialogues.is_connected("dialog_finished", Callable(self, "_on_dialog_finished")):
		Dialogues.disconnect("dialog_finished", Callable(self, "_on_dialog_finished"))
