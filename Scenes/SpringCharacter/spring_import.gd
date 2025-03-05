extends Node3D

@onready var aniTree: AnimationTree = $AnimationTree
@onready var masterTree: AnimationTree = $Hmmm

var coilSpeed: float = 1.8
var rotationSpeed: float = 1

func _ready() -> void:
	aniTree.active = false#true
	masterTree.active = true
	aniTree["parameters/Charge/CoilSpeed/scale"] = coilSpeed #Charging coils
	aniTree["parameters/Jump/Coil Speed/scale"] = coilSpeed-0.6 #Bouncing coils
	

func _process(_delta: float) -> void:
	if(Input.is_action_just_pressed("move_forward")):
		masterTree["parameters/CoilSpeed/scale"] = coilSpeed
		masterTree["parameters/Coils/conditions/coil"] = true
		masterTree["parameters/Coils/conditions/uncoil"] = true
		
		masterTree["parameters/Rings Rotation/conditions/charging"] = false
		masterTree["parameters/Rings Rotation/conditions/rotateFinish"] = true
		
	elif(Input.is_action_pressed("move_back")):
		if(not masterTree["parameters/Rings Rotation/conditions/charging"]):
			rotationSpeed = 0.05
			masterTree["parameters/RingsSpeed/scale"] = rotationSpeed
		
		masterTree["parameters/CoilSpeed/scale"] = coilSpeed - 0.6
		masterTree["parameters/Coils/conditions/coil"] = true
		masterTree["parameters/Coils/conditions/uncoil"] = false
		
		masterTree["parameters/Rings Rotation/conditions/charging"] = true
		masterTree["parameters/Rings Rotation/conditions/rotateFinish"] = false
		
	elif(Input.is_action_just_released("move_back")):
		masterTree["parameters/Coils/conditions/coil"] = false
		masterTree["parameters/Coils/conditions/uncoil"] = true
		
		masterTree["parameters/Rings Rotation/conditions/charging"] = false
		masterTree["parameters/Rings Rotation/conditions/rotateFinish"] = true

	else:
		masterTree["parameters/Coils/conditions/coil"] = false
		masterTree["parameters/Coils/conditions/uncoil"] = true
		
		masterTree["parameters/Rings Rotation/conditions/charging"] = false
		masterTree["parameters/Rings Rotation/conditions/rotateFinish"] = true
		
	if(masterTree["parameters/Rings Rotation/conditions/charging"]):
		if(rotationSpeed < 2):
			rotationSpeed += 0.01
			masterTree["parameters/RingsSpeed/scale"] = rotationSpeed
	else:
		if(rotationSpeed > 1):
			rotationSpeed -= 0.05
			masterTree["parameters/RingsSpeed/scale"] = rotationSpeed
	
	
	"""
	if(Input.is_action_just_pressed("move_forward")):
		aniTree["parameters/conditions/jump"] = true #Jump
		aniTree["parameters/conditions/charging"] = false #Stop charge
	elif(Input.is_action_pressed("move_back")):
		if(not aniTree["parameters/conditions/charging"]):
			rotationSpeed = 0.05
			aniTree["parameters/Charge/RotateSpeed/scale"] = rotationSpeed
		aniTree["parameters/conditions/jump"] = false #Stop jump
		#Set Blend stuff
		aniTree["parameters/Charge/StateMachine/conditions/rotateFinish"] = false #Don't stop rotating
		aniTree["parameters/Charge/StateMachine 2/conditions/Uncharge"] = false #Don't uncoil
		aniTree["parameters/conditions/charging"] = true #Start charge
	elif(Input.is_action_just_released("move_back")):
		aniTree["parameters/conditions/jump"] = false #Stop jump
		aniTree["parameters/conditions/charging"] = false #Stop charge
		aniTree["parameters/Charge/StateMachine/conditions/rotateFinish"] = true #Finish rotation
		aniTree["parameters/Charge/StateMachine 2/conditions/Uncharge"] = true #uncoil
	else:
		aniTree["parameters/conditions/jump"] = false #Stop jump
		aniTree["parameters/conditions/charging"] = false #Stop charge
		
	if(aniTree["parameters/conditions/charging"]):
		if(rotationSpeed < 2):
			rotationSpeed += 0.01
			aniTree["parameters/Charge/RotateSpeed/scale"] = rotationSpeed
	else:
		if(rotationSpeed > 1):
			rotationSpeed -= 0.05
			aniTree["parameters/Charge/RotateSpeed/scale"] = rotationSpeed
	"""
