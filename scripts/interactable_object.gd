extends Node2D
class_name InteractableObject

# Сигналы: сообщаем менеджеру, что игрок рядом/ушёл
signal player_entered(obj)
signal player_exited(obj)

@export var text_lines_dark: Array[String] = []
@export var text_lines_light: Array[String] = []

@export var light_texture: Texture2D
@export var dark_texture: Texture2D

# Флаги поведения
@export var toggles_light_on_interact: bool = false
@export var one_time_only: bool = true  # можно ли повторно переключать
var has_triggered := false

@onready var sprite := $Sprite2D
var is_light_on := false

@export var collision_size: Vector2 = Vector2(64, 64)

func _ready() -> void:
	WorldStateManager.connect("lighting_changed", _on_lighting_changed)
	_on_lighting_changed(WorldStateManager.is_light_on())

	Dialogues.connect_object(self)

func _on_lighting_changed(value: bool) -> void:
	is_light_on = value
	if sprite:
		sprite.texture = light_texture if value else dark_texture

# Возвращает массив из текущей реплики
func get_current_text_lines() -> Array[String]:
	var text_lines = text_lines_light if is_light_on else text_lines_dark
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
	var text_lines = text_lines_light if is_light_on else text_lines_dark
	if text_lines.size() > 1:
		var object_path = get_path()
		WorldStateManager.advance_dialog_index(object_path, text_lines.size())
	
func on_interacted() -> void:
	if toggles_light_on_interact and (not one_time_only or not has_triggered):
		has_triggered = true
		
		#показать темный экран
		var dark_screen := get_tree().current_scene.get_node("CanvasLayer/DarkScreen")
		dark_screen.visible = true
		SoundManager.play_sfx("curtains")
		
		#через 3 секунды убрать экран и включить свет
		var timer := Timer.new()
		timer.one_shot = true
		timer.wait_time = 3.0
		timer.timeout.connect(func() -> void:
			dark_screen.visible = false
			WorldStateManager.set_light_state(true)
		)
		add_child(timer)
		timer.start()


func _on_area_2d_body_entered(body) -> void:
	if body.is_in_group("player"):
		emit_signal("player_entered", self)

func _on_area_2d_body_exited(body) -> void:
	if body.is_in_group("player"):
		emit_signal("player_exited", self)
