extends PopupPanel

@onready var music_slider: HSlider = $TabContainer/AudioTab/HBoxContainer/HSlider
@onready var sfx_slider: HSlider = $TabContainer/AudioTab/HBoxContainer2/HSlider

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	# загружаем настройки
	load_settings()
	
	# Подписываемся на изменение значений
	music_slider.value_changed.connect(_on_music_slider_value_changed)
	sfx_slider.value_changed.connect(_on_sfx_slider_value_changed)

func _on_music_slider_value_changed(value: float) -> void:
	SoundManager.set_music_volume(value)
	save_settings()
	

func _on_sfx_slider_value_changed(value: float) -> void:
	SoundManager.set_sfx_volume(value)
	save_settings()	
	
func save_settings() -> void:
	var config = ConfigFile.new()
	config.set_value("audio", "music_volume", music_slider.value)
	config.set_value("audio", "sfx_volume", sfx_slider.value)
	config.save("user://settings.cfg")	
	
func load_settings() -> void:
	var config = ConfigFile.new()
	if config.load("user://settings.cfg") == OK:
		var music = config.get_value("audio", "music_volume", 1.0)
		var sfx = config.get_value("audio", "sfx_volume", 1.0)
		
		music_slider.value = music
		sfx_slider.value = sfx
		
		SoundManager.set_music_volume(music)
		SoundManager.set_sfx_volume(sfx)
