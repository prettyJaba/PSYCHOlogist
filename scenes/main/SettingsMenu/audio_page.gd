extends Control

@onready var music_slider: HSlider = $RightPage/HBoxContainer/MarginContainer2/HSlider
@onready var sfx_slider: HSlider = $RightPage/HBoxContainer2/MarginContainer2/HSlider

func _ready() -> void:
	# Инициализация слайдеров текущими значениями из SoundManager
	music_slider.value = SoundManager.music_volume
	sfx_slider.value = SoundManager.sfx_volume

	music_slider.value_changed.connect(func(value): SoundManager.set_music_volume(value))
	sfx_slider.value_changed.connect(func(value): SoundManager.set_sfx_volume(value))
	
	SoundManager.play_music("main")


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

		# Применяем в SoundManager
		SoundManager.set_music_volume(music)
		SoundManager.set_sfx_volume(sfx)
