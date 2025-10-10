extends CharacterBody2D

@export var speed := 100
@onready var animated_sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var step_timer: Timer = $StepTimer  # добавим этот таймер в сцену Player

var can_move := true
var last_direction := "down"
var moving := false

func _ready() -> void:
	step_timer.wait_time = 0.5
	step_timer.one_shot = false
	step_timer.autostart = false
	step_timer.timeout.connect(_on_step_timer_timeout)

func _process(delta: float) -> void:
	if not can_move:
		velocity = Vector2.ZERO
		move_and_slide()
		play_idle_animation()
		step_timer.stop()  # прекращаем шаги
		return

	var direction := Vector2.ZERO

	if Input.is_action_pressed("right"):
		direction.x += 1
	elif Input.is_action_pressed("left"):
		direction.x -= 1

	if Input.is_action_pressed("down"):
		direction.y += 1
	elif Input.is_action_pressed("up"):
		direction.y -= 1

	# движение
	if direction != Vector2.ZERO:
		direction = direction.normalized()
		velocity = direction * speed
		update_animation(direction)

		if not moving:
			moving = true
			SoundManager.play_sfx("step")
			step_timer.start()  # начинаем "топот"
	else:
		if moving:
			moving = false
			step_timer.stop()  # прекращаем шаги
		velocity = Vector2.ZERO
		play_idle_animation()

	move_and_slide()

func start(pos): 
	position = pos 
	show() 
	$CollisionShape2D.disabled = false

func update_animation(direction: Vector2) -> void:
	if abs(direction.x) > abs(direction.y):
		last_direction = "right" if direction.x > 0 else "left"
	else:
		last_direction = "down" if direction.y > 0 else "up"

	if not animated_sprite.is_playing() or animated_sprite.animation != last_direction:
		animated_sprite.play(last_direction)


func play_idle_animation() -> void:
	var idle_anim := "%s_idle" % last_direction
	if animated_sprite.animation != idle_anim:
		animated_sprite.play(idle_anim)

func block_movement(block: bool): 
	can_move = not block

func _on_step_timer_timeout() -> void:
	SoundManager.play_sfx("step")  # звук теперь ровно один раз за “шаг”
