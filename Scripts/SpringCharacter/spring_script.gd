extends CharacterBody3D

const GROUND_SPEED = 6.0							# Speed of spring in ground bounce
const AIR_SPEED = 0.05								# Influence on speed that alters spring velocity in air
const GROUND_BOUNCE_IMPULSE = 4.0					# y velocity impulse for bounce in ground bounce
const CHARGE_JUMP_IMPULSE = 2.0
const AIM_VERTICAL_OFFSET = 0.2						# For charge jump vector
const AIM_VERTICAL_MINIMUM = 0.2					# For charge jump vector
const CHARGE_JUMP_RATE = 0.4						# Rate at which velocity accumulates in charge
const CHARGE_JUMP_POWER_MAX = 18.0					# Accumulated velocity cap for charge
const CAMERA_VERTICAL_OFFSET = 1.0				
const CAMERA_INTERPOLATION_WEIGHT = 0.1				# AMONG 1
const CAMERA_VERTICAL_MOVEMENT_DEADZONE = 1.4
const COIL_SPEED: float = 4							# Speed of coil animation

@onready var camPivot: Node3D = $CamPivot
@onready var camera: Node3D = $CamPivot/SpringArm3D/Camera3D
@onready var animationTree: AnimationTree = $"Spring Model"/AnimationTree
@export var mouse_sens = 0.15						# Adjustable mouse sensitivity for camera
@export var ground_bounce_wait_time = 20			# Time spring holds on ground in ground bounce
@export var ground_anim_speed = 0.5					# Spring ground stretch/squash anim speed in ground state

var bounce_timer = 0								# Enables spring ground movement after wait time expires
var charge_velocity = 0								# Var to accumulate velocity in charge jump
var camera_target = Vector3(0, 2, 0)
var lerp_y = 0
var most_recent_groundpoint = Vector3()
var aim_vector = Vector3()
var bonk_timer = 0									# bonq :3
var reset_position = Vector3()						#Initializes spring reset position
var rotationSpeed: float = 1						# Speed the rings rotate in the animation

signal charging										#for use in charge UI
signal spring_pos(spring_pos_x, spring_pos_y, spring_pos_z)	#for positioning compass above spring

func _ready():
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED	# Locks mouse to window and hides
	animationTree.active = true
	
func _input(event):
	if event is InputEventMouseMotion:				# Camera control from mouse motion
		rotate_y(deg_to_rad(-event.relative.x * mouse_sens))
		camPivot.rotate_x(deg_to_rad(-event.relative.y * mouse_sens))
		camPivot.rotation.x = clamp(camPivot.rotation.x, deg_to_rad(-75), deg_to_rad(75))
	if event.is_action_pressed("escape"):
		Input.mouse_mode = Input.MOUSE_MODE_VISIBLE			# Mouse made visible, can move outside game window
	if event.is_action_pressed("reset"):
		reset()
		
func _process(_delta) -> void:
	move_camera()
	if Input.is_action_pressed("left_click"):
		Input.mouse_mode = Input.MOUSE_MODE_CAPTURED		# Locks mouse to window
		
	#emits position for compass to connect its position to the spring (this is me being lazy lol)
	spring_pos.emit(position.x, position.y, position.z)

func _physics_process(delta: float) -> void:
	'''For anything to do with physics in the world'''
	var input = ""
	if is_on_floor():
		velocity = Vector3.ZERO 	# Kills ground velocity. May have to change for ragdoll or physics interactions.
		most_recent_groundpoint = position
		if Input.is_action_just_released("jump"):			# Charge jump release, going airborne
			charge_jump()
			input = "charge end"
		elif not Input.is_action_pressed("jump"):
			# Will fix jumping once this condition is revised
			bounce_timer += 1
			if bounce_timer >= ground_bounce_wait_time:							# Bounce after hold period expires
				ground_move_spring()
			input = "bounce"
		elif Input.is_action_pressed("jump"):
			velocity = Vector3.ZERO							# Stop all movement, freeze in spot
			if charge_velocity <= CHARGE_JUMP_POWER_MAX:	# Caps charge velocity
				charge()
			charging.emit()  #ui signal
			input = "charge start"
		
	if not is_on_floor():
		bounce_timer = 0 			# Reset idle bounce timer	
		velocity += get_gravity() * delta					# Applies gravity while not on floor
		air_move_spring()
		
	animate(input)
	move_and_slide()										# NECESSARY for this stuff to actually all work
	
#functions block ----------
func air_move_spring() -> void:
	'''Uses built-in methodology to apply horizontal influence to the spring. Because it is creating
	this velocity from nowhere, it is additive to midair spring velocity.'''
	var input_dir := Input.get_vector("move_left", "move_right", "move_forward", "move_back")
	var direction := (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	velocity.x += direction.x * AIR_SPEED
	velocity.z += direction.z * AIR_SPEED
	
func charge() -> void:
	'''Charge function for spring jump. Accumulates charge velocity based on charge rate'''
	charge_velocity += CHARGE_JUMP_RATE
	charging.emit() #ui signal

func charge_jump() -> void:
	'''Execute a charge jump in the direction the camera is facing. Takes a vector pointing 
	in the negative z direction with a vertical component dependent on camera rotation and 
	rotates it around a vector pointing straight up by the rotation of the player model.'''
	# TODO: stop using model rotation
	aim_vector = Vector3(
		0, 
		max((AIM_VERTICAL_OFFSET + camPivot.rotation.x), AIM_VERTICAL_MINIMUM) * CHARGE_JUMP_IMPULSE,
		-1).rotated(Vector3(0, 1, 0), 
		rotation.y).normalized()
	# debug lines ====
	# $aimIndicator.top_level = true
	# $aimIndicator.position = position + aim_vector
	# print(aim_vector)
	velocity = aim_vector * charge_velocity 	# aim_vector has length 1, multiply by charge strength
	charge_velocity = 0 						# Reset charge velocity upon jump
	
func ground_move_spring() -> void:
	'''Uses built-in methodology for recording and applying horizontal movement during ground bounce'''
	var input_dir := Input.get_vector("move_left", "move_right", "move_forward", "move_back")
	var direction := (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	# Use negative of floor normal to tilt direction with the floor
	var dir_floor_influenced = (-get_floor_normal()).direction_to(direction)
	# debug lines ====
	# $aimIndicator.top_level = true
	# $aimIndicator.position = position + dir_floor_influenced
	# print(get_floor_normal().direction_to(direction))
	# ================
	# Update velocity using direction and defined ground speeds
	velocity.x = dir_floor_influenced.x * GROUND_SPEED
	velocity.z = dir_floor_influenced.z * GROUND_SPEED
	velocity.y = dir_floor_influenced.y + GROUND_BOUNCE_IMPULSE
		
func move_camera() -> void:
	'''Uses lerp to move the camera. The camera will only fall if the spring falls more than a certain 
	distance from the peak of its height.
	!! If Spring is on Collision Layer 1, the SpringArm3D gets confused and starts clipping the spring.
	I suspect slerp is behind this.'''
	# raise camera target if player rises higher than it was
	if self.global_position.y >= lerp_y:
		lerp_y = self.global_position.y
	# lower camera target if player falls lower than it was, with some margin
	elif lerp_y - self.global_position.y > CAMERA_VERTICAL_MOVEMENT_DEADZONE:
		lerp_y = self.global_position.y + CAMERA_VERTICAL_MOVEMENT_DEADZONE
	# smoothly move the camera target point is looking at
	camera_target = camera_target.lerp(
		Vector3(self.global_position.x, lerp_y + CAMERA_VERTICAL_OFFSET, self.global_position.z), 
		CAMERA_INTERPOLATION_WEIGHT)
	# cant move camPivot, messes with rotation.
	# cant move Camera3D, messes with springArm.
	# moving SpringArm doesn't seem to have any glaring issues
	$CamPivot/SpringArm3D.global_position = camera_target
	
func reset() -> void:
	'''Reset player to state on startup'''
	position = reset_position 		#Reset position based off most recent checkpoint
	velocity = Vector3(0, 0, 0)			#Reset velocity
	
func animate(input: String) -> void:
	if(input == "bounce"): #Bounce
		animationTree["parameters/CoilSpeed/scale"] = COIL_SPEED
		animationTree["parameters/Coils/conditions/coil"] = true
		animationTree["parameters/Coils/conditions/uncoil"] = true
		
		animationTree["parameters/Rings Rotation/conditions/charging"] = false
		animationTree["parameters/Rings Rotation/conditions/rotateFinish"] = true
		
	elif(input == "charge start"): #Charge start
		#Lower intial ring rotation
		if(animationTree["parameters/Rings Rotation/playback"].get_current_node() == "RESET"):
			rotationSpeed = 0.05
			animationTree["parameters/RingsSpeed/scale"] = rotationSpeed
		
		animationTree["parameters/CoilSpeed/scale"] = COIL_SPEED - 3
		animationTree["parameters/Coils/conditions/coil"] = true
		animationTree["parameters/Coils/conditions/uncoil"] = false
		
		animationTree["parameters/Rings Rotation/conditions/charging"] = true
		animationTree["parameters/Rings Rotation/conditions/rotateFinish"] = false
		
	elif(input == "charge end"): #Charge release
		if(rotationSpeed < 0.5):
			rotationSpeed = 0.5
			animationTree["parameters/RingsSpeed/scale"] = rotationSpeed
		animationTree["parameters/Coils/conditions/coil"] = false
		animationTree["parameters/Coils/conditions/uncoil"] = true
		
		animationTree["parameters/CoilSpeed/scale"] = COIL_SPEED
		animationTree["parameters/Rings Rotation/conditions/charging"] = false
		animationTree["parameters/Rings Rotation/conditions/rotateFinish"] = true

	else:											#Nothing
		animationTree["parameters/Coils/conditions/coil"] = false
		animationTree["parameters/Coils/conditions/uncoil"] = true
		
		animationTree["parameters/Rings Rotation/conditions/charging"] = false
		animationTree["parameters/Rings Rotation/conditions/rotateFinish"] = true
	
	#Slow/speed up rotation speed
	if(animationTree["parameters/Rings Rotation/conditions/charging"]):
		if(rotationSpeed < 2.5):
			rotationSpeed += 0.01
			animationTree["parameters/RingsSpeed/scale"] = rotationSpeed
	else:
		if(rotationSpeed > 1):
			rotationSpeed -= 0.05
			animationTree["parameters/RingsSpeed/scale"] = rotationSpeed

#signals block -----------
func _on_cp_pos(cp_position: Variant) -> void:
	reset_position = cp_position
