extends MeshInstance3D

#WARNING!!!
#Upon adding this object to scene, you must hook up the target_pos signal to the scene's compass node.
#The Compass needs a signal from a ship_part to point to one, otherwise it will point to the world origin.

signal target_pos(target_position)

func _process(_delta: float) -> void:
	var x = position
	target_pos.emit(x)
