extends Node3D
#Used in compass functionality. From compass.gd:
#2. Connect target_pos signal from target.gd to _on_ship_part_target_pos in compass.gd

@onready var ship_area = get_node("Part/Ship_Area")
@onready var spring = get_node("%TestSpring")
signal target_pos(target_position)		#sends target position for compass to point to

@export var partNum: int = 1
signal part_collected(partNum: int)

func _process(_delta: float) -> void:
	if visible:
		target_pos.emit(position)			#compass receives this so it can point to ship part
		
		if ship_area.overlaps_body(spring):
			part_collected.emit(partNum)
			visible = false
			target_pos.emit(Vector3(0,-1000,0))
		
