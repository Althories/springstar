extends Node3D

@onready var masterTree: AnimationTree = $AnimationTree
@onready var spring: Node3D = $Spring
@onready var innerRing: MeshInstance3D = $Capsule/InnerRing
@onready var middleRing: MeshInstance3D = $Capsule/InnerRing/MiddleRing
@onready var outerRing: MeshInstance3D = $Capsule/InnerRing/MiddleRing/OuterRing

var coilSpeed: float = 2
var rotationSpeed: float = 1

func _ready() -> void:
	masterTree.active = true
	
func _process(delta: float) -> void:
	#Basic spring rotation
	if(Input.is_action_pressed("move_left")):
		spring.rotate_x(-2*delta)
	if(Input.is_action_pressed("move_right")):
		spring.rotate_x(2*delta)
	if(Input.is_action_pressed("jump")):
		spring.rotate_z(-2*delta)
	
	animate()

func animate() -> void:
	if(Input.is_action_just_pressed("move_forward")): #Bounce
		masterTree["parameters/CoilSpeed/scale"] = coilSpeed
		masterTree["parameters/Coils/conditions/coil"] = true
		masterTree["parameters/Coils/conditions/uncoil"] = true
		
		masterTree["parameters/Rings Rotation/conditions/charging"] = false
		masterTree["parameters/Rings Rotation/conditions/rotateFinish"] = true
		
	elif(Input.is_action_pressed("move_back")): #Charge start
		#Lower intial ring rotation
		if(masterTree["parameters/Rings Rotation/playback"].get_current_node() == "RESET"):
			rotationSpeed = 0.05
			masterTree["parameters/RingsSpeed/scale"] = rotationSpeed
		
		masterTree["parameters/CoilSpeed/scale"] = coilSpeed - 1
		masterTree["parameters/Coils/conditions/coil"] = true
		masterTree["parameters/Coils/conditions/uncoil"] = false
		
		masterTree["parameters/Rings Rotation/conditions/charging"] = true
		masterTree["parameters/Rings Rotation/conditions/rotateFinish"] = false
		
	elif(Input.is_action_just_released("move_back")): #Charge release
		if(rotationSpeed < 0.5):
			rotationSpeed = 0.5
			masterTree["parameters/RingsSpeed/scale"] = rotationSpeed
		masterTree["parameters/Coils/conditions/coil"] = false
		masterTree["parameters/Coils/conditions/uncoil"] = true
		
		masterTree["parameters/CoilSpeed/scale"] = coilSpeed
		masterTree["parameters/Rings Rotation/conditions/charging"] = false
		masterTree["parameters/Rings Rotation/conditions/rotateFinish"] = true

	else:											#Nothing
		masterTree["parameters/Coils/conditions/coil"] = false
		masterTree["parameters/Coils/conditions/uncoil"] = true
		
		masterTree["parameters/Rings Rotation/conditions/charging"] = false
		masterTree["parameters/Rings Rotation/conditions/rotateFinish"] = true
	
	#Slow/speed up rotation speed
	if(masterTree["parameters/Rings Rotation/conditions/charging"]):
		if(rotationSpeed < 2.5):
			rotationSpeed += 0.01
			masterTree["parameters/RingsSpeed/scale"] = rotationSpeed
	else:
		if(rotationSpeed > 1):
			rotationSpeed -= 0.05
			masterTree["parameters/RingsSpeed/scale"] = rotationSpeed
