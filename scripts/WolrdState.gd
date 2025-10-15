extends Node
class_name WorldState

signal lighting_changed(is_light_on: bool)

var _is_light_on := false

func set_light_state(enabled: bool) -> void:
	if _is_light_on == enabled:
		return
	_is_light_on = enabled
	emit_signal("lighting_changed", _is_light_on)

func is_light_on() -> bool:
	return _is_light_on

func toggle_light() -> void:
	set_light_state(not _is_light_on)
