extends Node2D
class_name SimpleInteractableObject

# Сигналы: сообщаем менеджеру, что игрок рядом/ушёл
signal player_entered(obj)
signal player_exited(obj)

@export var text_lines: Array[String] = []  # Единственный набор реплик

@export var texture: Texture2D  # Единственный спрайт

# Флаги поведения
@export var one_time_only: bool = true  # можно ли повторно переключать
var has_triggered := false

@onready var sprite := $Sprite2D
@onready var area := $Area2D

@export var collision_size: Vector2 = Vector2(64, 64)

func _ready() -> void:
	# Подключаемся к системе диалогов
	Dialogues.connect_object(self)

func get_current_text_lines() -> Array[String]:
	if text_lines.is_empty():
		return []

	# Получаем текущий индекс из WorldState
	var object_path = get_path()
	var current_index = WorldStateManager.get_dialog_index(object_path)

	# Для объектов с одной репликой всегда возвращаем её
	if text_lines.size() == 1:
		return [text_lines[0]]

	# Для объектов с несколькими репликами возвращаем текущую
	if current_index < text_lines.size():
		return [text_lines[current_index]]

	# На случай ошибки возвращаем первую реплику
	return [text_lines[0]]

# Метод для перехода к следующей реплике (вызывается после показа диалога)
func advance_to_next_line() -> void:
	if text_lines.size() > 1:
		var object_path = get_path()
		WorldStateManager.advance_dialog_index(object_path, text_lines.size())

func _on_area_2d_body_entered(body) -> void:
	if body.is_in_group("player"):
		emit_signal("player_entered", self)

func _on_area_2d_body_exited(body) -> void:
	if body.is_in_group("player"):
		emit_signal("player_exited", self)
