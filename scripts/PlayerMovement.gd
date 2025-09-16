'''
extends CharacterBody2D

@export var speed = 2 # How fast the player will move (pixels/sec).
@onready var animated_sprite = $AnimatedSprite2D

var screen_size # Size of the game window.
var sprites = {Vector2(0, 1): 0, Vector2(-1, 0): 1, Vector2(1, 0): 2, Vector2(0, -1): 3}

func _ready():
	screen_size = get_viewport_rect().size
	hide()


func _process(delta):
	var velocity = Vector2.ZERO
	
	if Input.is_action_pressed(&"right"):
		update_sprite(Vector2(1, 0))
		velocity.x += 1
	if Input.is_action_pressed(&"left"):
		update_sprite(Vector2(-1, 0))
		velocity.x -= 1
	if Input.is_action_pressed(&"down"):
		update_sprite(Vector2(0, 1))
		velocity.y += 1
	if Input.is_action_pressed(&"up"):
		update_sprite(Vector2(0, -1))
		velocity.y -= 1	
	
	if velocity.length() > 0:
		velocity = velocity.normalized() * speed

	position += velocity
	position = position.clamp(Vector2.ZERO, screen_size)

func start(pos):
	position = pos
	rotation = 0
	show()
	$CollisionShape2D.disabled = false
	
func update_sprite(direction: Vector2) -> void:
	animated_sprite.frame = sprites[direction]
	'''
extends CharacterBody2D

@export var speed = 100  # Скорость в пикселях/сек.

@onready var animated_sprite = $AnimatedSprite2D

var sprites = {Vector2(0, 1): 0, Vector2(-1, 0): 1, Vector2(1, 0): 2, Vector2(0, -1): 3}
var can_move = true
var move = 1

func _process(delta):
	if can_move:
		move = 1
	else:
		move = 0
	
	var direction = Vector2.ZERO  # Вектор направления
	
	if Input.is_action_pressed("right"):
		direction.x += move
	if Input.is_action_pressed("left"):
		direction.x -= move
	if Input.is_action_pressed("down"):
		direction.y += move
	if Input.is_action_pressed("up"):
		direction.y -= move  

	if direction.length() > 0:
		direction = direction.normalized()
		update_sprite(direction)

	velocity = direction * speed
	move_and_slide()

func update_sprite(direction: Vector2) -> void:
	if direction in sprites:
		animated_sprite.frame = sprites[direction]

func start(pos: Vector2):
	position = pos
	show()
	$CollisionShape2D.disabled = false

func block_movement(block):
	can_move = not block
