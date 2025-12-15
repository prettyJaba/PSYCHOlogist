extends Node
class_name WorldState

signal lighting_changed(is_light_on: bool)

var _is_light_on := false
# Словарь для хранения текущих индексов реплик для каждого объекта
# Формат: { "путь_к_объекту": индекс_реплики }
var object_dialog_indices := {}

func set_light_state(enabled: bool) -> void:
	if _is_light_on == enabled:
		return
	_is_light_on = enabled
	emit_signal("lighting_changed", _is_light_on)

func is_light_on() -> bool:
	return _is_light_on

func toggle_light() -> void:
	set_light_state(not _is_light_on)

# --- Методы для управления прогрессом диалогов ---

# Получить текущий индекс реплики для объекта
func get_dialog_index(object_path: String) -> int:
	return object_dialog_indices.get(object_path, 0)

# Установить индекс реплики для объекта
func set_dialog_index(object_path: String, index: int) -> void:
	object_dialog_indices[object_path] = index

# Перейти к следующей реплике для объекта
func advance_dialog_index(object_path: String, max_lines: int) -> int:
	var current_index = get_dialog_index(object_path)
	var next_index = (current_index + 1) % max_lines
	set_dialog_index(object_path, next_index)
	return next_index

# сброс при выходе
func reset() -> void:
	# Сброс света
	set_light_state(false)

	# Сброс диалогов
	object_dialog_indices.clear()
	
	SoundManager.stop_all_sfx()
	SoundManager.stop_music()
