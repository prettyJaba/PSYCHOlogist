extends Control

@onready var resolution_option: OptionButton = $"VBoxContainer/HBoxContainer (Res)/OptionButton (Res)"
@onready var window_mode_option: OptionButton = $"VBoxContainer/HBoxContainer (Wmod)/OptionButton (Wmod)"
@onready var apply_button: Button = $VBoxContainer/ApplyButton

var resolution_manager: ResolutionManager

func _ready():
	# Создаём менеджер разрешений
	resolution_manager = ResolutionManager.new()
	add_child(resolution_manager)
	
	# Заполняем выпадающие списки
	_populate_resolution_options()
	_populate_window_mode_options()
	
	# Подключаем сигналы
	apply_button.connect("pressed", _on_apply_pressed)

func _populate_resolution_options():
	resolution_option.clear()
	var resolutions = resolution_manager.get_available_resolutions()
	
	for i in range(resolutions.size()):
		var res_key = resolutions[i]
		resolution_option.add_item(res_key, i)
		
		# Устанавливаем текущее разрешение как выбранное
		var current_res = resolution_manager.get_current_resolution()
		var res_value = resolution_manager.preset_resolutions[res_key]
		if res_value == current_res:
			resolution_option.selected = i

func _populate_window_mode_options():
	window_mode_option.clear()
	window_mode_option.add_item("Оконный", 0)
	window_mode_option.add_item("Полноэкранный", 1)
	window_mode_option.add_item("Полноэкранный без рамки", 2)
	
	window_mode_option.selected = resolution_manager.window_mode

func _on_apply_pressed():
	# Применяем выбранное разрешение
	var selected_res_index = resolution_option.get_selected_id()
	var resolutions = resolution_manager.get_available_resolutions()
	var selected_res_key = resolutions[selected_res_index]
	
	resolution_manager.set_resolution_by_key(selected_res_key)
	
	# Применяем выбранный режим окна
	var selected_mode_index = window_mode_option.get_selected_id()
	resolution_manager.set_window_mode(selected_mode_index)
	
	# Сохраняем настройки
	_save_settings()

func _save_settings():
	var config = {
		"resolution": {
			"width": resolution_manager.current_resolution.x,
			"height": resolution_manager.current_resolution.y
		},
		"window_mode": resolution_manager.window_mode
	}
	
	var config_file = FileAccess.open("user://display_settings.cfg", FileAccess.WRITE)
	if config_file:
		config_file.store_string(JSON.stringify(config))
		config_file.close()

func _load_settings():
	var config_file = FileAccess.open("user://display_settings.cfg", FileAccess.READ)
	if config_file:
		var json = JSON.new()
		var parse_result = json.parse(config_file.get_as_text())
		if parse_result == OK:
			var config = json.data
			if config and config is Dictionary:
				var res = config.get("resolution", {})
				var width = res.get("width", 1280)
				var height = res.get("height", 720)
				var mode = config.get("window_mode", 0)
				
				resolution_manager.set_resolution(width, height)
				resolution_manager.set_window_mode(mode)
		
		config_file.close()
