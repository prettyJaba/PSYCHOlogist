extends Node

class_name ResolutionManager

# Предопределённые разрешения
var preset_resolutions = {
	"1024x768": Vector2i(1024, 768),
	"1280x720": Vector2i(1280, 720),
	"1366x768": Vector2i(1366, 768),
	"1920x1080": Vector2i(1920, 1080),
	"2560x1440": Vector2i(2560, 1440),
	"3840x2160": Vector2i(3840, 2160)
}

# Текущее разрешение
var current_resolution: Vector2i
# Режим окна (0 - оконный, 1 - полноэкранный, 2 - полноэкранный без рамки)
var window_mode: int = 0

func _ready():
	# Инициализация текущего разрешения
	current_resolution = DisplayServer.window_get_size()
	_apply_settings()

# Установка разрешения
func set_resolution(width: int, height: int):
	var new_resolution = Vector2i(width, height)
	current_resolution = new_resolution
	_apply_settings()

# Установка разрешения по ключу из пресетов
func set_resolution_by_key(resolution_key: String):
	if preset_resolutions.has(resolution_key):
		current_resolution = preset_resolutions[resolution_key]
		_apply_settings()
	else:
		push_error("Разрешение " + resolution_key + " не найдено в пресетах")

# Переключение режима окна
func set_window_mode(mode: int):
	window_mode = mode
	_apply_settings()

# Получение списка доступных разрешений
func get_available_resolutions() -> Array:
	return preset_resolutions.keys()

# Получение текущего разрешения
func get_current_resolution() -> Vector2i:
	return current_resolution

# Применение всех настроек
func _apply_settings():
	# Устанавливаем режим окна
	match window_mode:
		0: # Оконный
			DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED)
			DisplayServer.window_set_flag(DisplayServer.WINDOW_FLAG_BORDERLESS, false)
		1: # Полноэкранный
			DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_FULLSCREEN)
		2: # Полноэкранный без рамки
			DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED)
			DisplayServer.window_set_flag(DisplayServer.WINDOW_FLAG_BORDERLESS, true)
			# Устанавливаем на весь экран
			var screen_size = DisplayServer.screen_get_size()
			DisplayServer.window_set_size(screen_size)
			return
	
	# Для оконного режима устанавливаем конкретное разрешение
	if window_mode == 0:
		DisplayServer.window_set_size(current_resolution)
		# Центрируем окно
		_center_window()

# Центрирование окна
func _center_window():
	var screen_size = DisplayServer.screen_get_size()
	var window_size = DisplayServer.window_get_size()
	var centered_position = (screen_size - window_size) / 2
	DisplayServer.window_set_position(centered_position)
