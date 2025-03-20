extends MeshInstance3D

signal target_pos(target_position)

func _process(_delta: float) -> void:
	var x = position
	target_pos.emit(x)
