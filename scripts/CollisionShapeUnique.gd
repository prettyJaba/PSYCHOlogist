@tool
extends CollisionShape2D

# Этот метод вызывается при добавлении узла в сцену (в редакторе или игре)
func _enter_tree():
	# Проверяем, что мы в редакторе
	if Engine.is_editor_hint():
		make_shape_unique()

# Делает shape уникальным, если он есть
func make_shape_unique():
	if shape:
		# Если shape уже уникален, duplicate() создаст новую копию
		shape = shape.duplicate()
