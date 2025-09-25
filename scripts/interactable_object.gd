extends Node2D

@export var text_lines: Array[String] = [
	"Это старая картина...",
	"Она кажется знакомой...",
	"Но ты не можешь вспомнить, где её видел."
]


var player_in_area = false
var current_text_index = 0
var typing_speed = 0.05  # Скорость печати (секунды между буквами)
var is_typing = false  # Флаг, чтобы не прерывать печать

@onready var label = $CanvasLayer/Panel/RichTextLabel
@onready var panel = $CanvasLayer/Panel
@onready var sprite = $Sprite2D

func _ready():
	panel.visible = false  # Скрываем текстовое окно в начале
	
func _process(delta):
	if player_in_area and Input.is_action_just_pressed("interact"):
		show_next_text()

func show_next_text():
	var player = get_tree().get_nodes_in_group("player")[0]  # Получаем игрока
	
	if is_typing:
		label.text = text_lines[current_text_index]  # Показываем весь текст сразу
		is_typing = false
		return
	
	elif current_text_index < text_lines.size():
		panel.visible = true
		player.block_movement(true)  # Отключаем передвижение
		is_typing = true  # Запрещаем спамить кнопкой
		await type_text(text_lines[current_text_index])  # Вызываем печать текста
		is_typing = false
		current_text_index += 1
	
	else:
		panel.visible = false
		player.block_movement(false)  # Возвращаем управление
		current_text_index = 0  # Сбрасываем для следующего взаимодействия

func type_text(full_text):
	label.text = ""  # Очищаем текст перед печатью
	for i in range(full_text.length()):
		if not is_typing:
			return
		label.text += full_text[i]  # Добавляем по одной букве
		SoundManager.play_sfx("text")
		await get_tree().create_timer(typing_speed).timeout  # Ждём
		
		if Input.is_action_just_pressed("interact"):
			label.text = full_text
			break

func _on_area_2d_body_entered(body):
	if body is CharacterBody2D:  # Проверяем, что это игрок
		player_in_area = true

func _on_area_2d_body_exited(body):
	if body is CharacterBody2D:
		player_in_area = false
