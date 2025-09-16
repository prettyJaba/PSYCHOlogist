extends Node2D

@onready var open_button = $OpenButton  # Кнопка открытия
@onready var close_button = $CloseButton  # Кнопка закрытия
@onready var sprite = $Sprite2D  # Сам блокнот


var is_open = false  # Флаг состояния блокнота
var original_scale: Vector2  # Переменная для хранения размера

func _ready():
	close_button.visible = false  # Скрываем кнопку закрытия
	original_scale = sprite.scale  # Сохраняем исходный размер

func _on_open_button_pressed():
	print("Открытие блокнота")  # Проверяем, вызывается ли функция
	if not is_open:
		open_notebook()

func _on_close_button_pressed():
	print("Закрытие блокнота")  # Проверяем, вызывается ли функция
	if is_open:
		close_notebook()

func open_notebook():
	is_open = true
	open_button.visible = false
	close_button.visible = true  # Показываем кнопку закрытия
	var tween = create_tween()
	tween.tween_property(sprite, "scale", original_scale * 2, 0.3)  # Увеличиваем в 2 раза

func close_notebook():
	is_open = false
	open_button.visible = true
	close_button.visible = false  # Скрываем кнопку закрытия
	var tween = create_tween()
	tween.tween_property(sprite, "scale", original_scale, 0.3)  # Возвращаем к оригинальному размеру
