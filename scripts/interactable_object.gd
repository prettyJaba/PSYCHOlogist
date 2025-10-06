extends Node2D
class_name InteractableObject

# Сигналы: сообщаем менеджеру, что игрок рядом/ушёл
signal player_entered(obj)
signal player_exited(obj)

@export var text_lines: Array[String] = [
	"Это старая картина...",
	"Она кажется знакомой...",
	"Но ты не можешь вспомнить, где её видел."
]
@export var collision_size: Vector2 = Vector2(64, 64)

func _ready() -> void:
	var shape = $Area2D/CollisionShape2D.shape
	if shape is RectangleShape2D:
		shape.extents = collision_size / 2

	# опционально: если DialogueManager (autoload) доступен как "Dialogues", зарегистрируемся автоматически
	if Engine.has_singleton("Dialogues"):
		Dialogues.connect_object(self)

# Объявляем события входа/выхода — без обработки Input!
func _on_area_2d_body_entered(body) -> void:
	if body.is_in_group("player"):
		emit_signal("player_entered", self)

func _on_area_2d_body_exited(body) -> void:
	if body.is_in_group("player"):
		emit_signal("player_exited", self)
