extends Node

@onready var music_player: AudioStreamPlayer2D = $MusicPlayer
@onready var sfx_player: AudioStreamPlayer2D = $SFXPlayer

var music_volume := 1.0
var sfx_volume := 1.0

# Словари для регистрации треков
var music_tracks := {}
var sfx_tracks := {}

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	init_tracks()
	apply_volumes()
	
	# --- Регистрация треков ---
func register_music(name: String, path: String):
	var stream = load(path)
	if stream:
		music_tracks[name] = stream
	else:
		push_error("Music not found: %s" % path)
		
func register_sfx(name: String, path: String):
	var stream = load(path)
	if stream:
		sfx_tracks[name] = stream
	else:
		push_error("SFX not found: %s" % path)

# --- Музыка ---
func play_music(name: String, loop := true):
	if not music_tracks.has(name):
		push_error("Music not registered: %s" % name)
		return
	var track = music_tracks[name]
	if music_player.stream != track:
		music_player.stop()
		music_player.stream = track
	music_player.play()
	
func stop_music():
	music_player.stop()
	
# --- Эффекты ---
func play_sfx(name: String):
	if not sfx_tracks.has(name):
		push_error("SFX not registered: %s" % name)
		return
	var track = sfx_tracks[name]
	var player = AudioStreamPlayer.new()
	player.bus = "SFX"
	player.stream = track
	add_child(player)
	player.play()
	player.finished.connect(func(): player.queue_free())

# --- Громкость ---
func set_music_volume(value: float):
	music_volume = clamp(value, 0.0, 1.0)
	apply_volumes()
	
func set_sfx_volume(value: float):
	sfx_volume = clamp(value, 0.0, 1.0)
	apply_volumes()

func apply_volumes():
	AudioServer.set_bus_volume_db(AudioServer.get_bus_index("Music"), linear_to_db(music_volume))
	AudioServer.set_bus_volume_db(AudioServer.get_bus_index("SFX"), linear_to_db(sfx_volume))

# --- Регистрация треков ---
# сюда нужно загрузить все звуки/музыку
func init_tracks():
	# Музыка
	register_music("main", "res://sounds/music/Peritune_Moonlit_Overture-chosic.com_.mp3")

	# Звуки
	register_sfx("text", "res://sounds/sfx/Press button.mp3")
	register_sfx("clock", "res://sounds/sfx/clock-tick.mp3")
	register_sfx("street", "res://sounds/sfx/a79e810c8566eee.mp3")
	register_sfx("step", "res://sounds/sfx/slow-careful-step.mp3")
	
# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta: float) -> void:
#	pass
