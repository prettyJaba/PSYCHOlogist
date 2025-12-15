extends PopupPanel

# --------------------------------------------------
# Узлы страниц
# --------------------------------------------------
@onready var audio_page: Control = $ContentRoot/AudioTab
@onready var graphic_page: Control = $ContentRoot/GraphicPage
@onready var save_page: Control = $ContentRoot/SavePage

# --------------------------------------------------
# Кнопки закладок
# --------------------------------------------------
@onready var tab_sound: TextureButton = $ContentRoot/TabsContainer/TabButtonSound
@onready var tab_screen: TextureButton = $ContentRoot/TabsContainer/TabButtonScreen
@onready var tab_save: TextureButton = $ContentRoot/TabsContainer/TabButtonSave
@onready var tab_exit: TextureButton = $ContentRoot/TabButtonExit

# --------------------------------------------------
# Popup на подтверждение выхода
# --------------------------------------------------
@onready var exit_popup: PopupPanel = $ContentRoot/PopupConfirmExit
@onready var exit_yes: TextureButton = $ContentRoot/PopupConfirmExit/Layout/OkExitConfirm
@onready var exit_no: TextureButton = $ContentRoot/PopupConfirmExit/Layout/NotExitConfirm

# --------------------------------------------------
# При инициализации
# --------------------------------------------------
func _ready() -> void:
	# --- Создаём группу вкладок ---
	var group = ButtonGroup.new()
	tab_sound.button_group = group
	tab_screen.button_group = group
	tab_save.button_group = group

	# --- Скрываем все страницы кроме первой ---
	graphic_page.visible = false
	save_page.visible = false
	audio_page.visible = true
	tab_sound.button_pressed = true

	# --- Настраиваем аудио-слайдеры ---
	_setup_audio_sliders()

	# --- Загружаем настройки ---
	load_settings()

	# --- Подключаем кнопки закладок ---
	tab_sound.pressed.connect(Callable(self, "_switch_page").bind(audio_page))
	tab_screen.pressed.connect(Callable(self, "_switch_page").bind(graphic_page))
	tab_save.pressed.connect(Callable(self, "_switch_page").bind(save_page))
	tab_exit.pressed.connect(Callable(self, "_show_exit_popup"))
	exit_yes.pressed.connect(_confirm_exit)
	exit_no.pressed.connect(_cancel_exit)



# --------------------------------------------------
# Переключение страниц
# --------------------------------------------------
func _switch_page(target_page: Control) -> void:
	audio_page.visible = false
	graphic_page.visible = false
	save_page.visible = false

	target_page.visible = true


# --------------------------------------------------
# Аудио-слайдеры
# --------------------------------------------------
func _setup_audio_sliders() -> void:
	var music_slider: HSlider = audio_page.get_node("RightPage/HBoxContainer/MarginContainer2/HSlider")
	var sfx_slider: HSlider = audio_page.get_node("RightPage/HBoxContainer2/MarginContainer2/HSlider")

	music_slider.value_changed.connect(_on_music_slider_value_changed)
	sfx_slider.value_changed.connect(_on_sfx_slider_value_changed)

func _on_music_slider_value_changed(value: float) -> void:
	SoundManager.set_music_volume(value)
	save_settings()

func _on_sfx_slider_value_changed(value: float) -> void:
	SoundManager.set_sfx_volume(value)
	save_settings()


# --------------------------------------------------
# Сохранение / загрузка настроек
# --------------------------------------------------
func save_settings() -> void:
	var config = ConfigFile.new()
	var music_slider: HSlider = audio_page.get_node("RightPage/HBoxContainer/MarginContainer2/HSlider")
	var sfx_slider: HSlider = audio_page.get_node("RightPage/HBoxContainer2/MarginContainer2/HSlider")

	config.set_value("audio", "music_volume", music_slider.value)
	config.set_value("audio", "sfx_volume", sfx_slider.value)
	config.save("user://settings.cfg")

func load_settings() -> void:
	var config = ConfigFile.new()
	if config.load("user://settings.cfg") == OK:
		var music = config.get_value("audio", "music_volume", 1.0)
		var sfx = config.get_value("audio", "sfx_volume", 1.0)

		var music_slider: HSlider = audio_page.get_node("RightPage/HBoxContainer/MarginContainer2/HSlider")
		var sfx_slider: HSlider = audio_page.get_node("RightPage/HBoxContainer2/MarginContainer2/HSlider")

		music_slider.value = music
		sfx_slider.value = sfx

		SoundManager.set_music_volume(music)
		SoundManager.set_sfx_volume(sfx)


# --------------------------------------------------
# Popup выхода
# --------------------------------------------------
func _show_exit_popup() -> void:
	exit_popup.popup_centered()

# --------------------------------------------------
# Выход в меню
# --------------------------------------------------
func _confirm_exit() -> void:
	exit_popup.hide()
	WorldStateManager.reset()
	call_deferred("_go_to_main_menu")

func _go_to_main_menu() -> void:
	get_tree().change_scene_to_file("res://scenes/main/main_menu.tscn")


func _cancel_exit() -> void:
	exit_popup.hide()
