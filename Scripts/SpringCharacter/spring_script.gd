extends CharacterBody3D

const GROUND_SPEED = 5.0							#Speed of spring in ground bounce
const GROUND_BOUNCE_IMPULSE = 4.5					#Velocity impulse for bounce in ground bounce
const CHARGE_JUMP_IMPULSE = 2.0
const AIM_VERTICAL_OFFSET = 0.2						#For charge jump vector
const AIM_VERTICAL_MINIMUM = 0.2					#for charge jump vector
const CHARGE_JUMP_RATE = 0.4						#rate at which velocity accumulates in charge
const CHARGE_JUMP_POWER_MAX = 18.0					#accumulated velocity cap for charge
const CAMERA_VERTICAL_OFFSET = 1.0				
const CAMERA_INTERPOLATION_WEIGHT = 0.1
const CAMERA_VERTICAL_MOVEMENT_DEADZONE = 1.2

@onready var camPivot: Node3D = $CamPivot
@onready var animationPlayer: AnimationPlayer = $SpringAnimation
@onready var camera: Node3D = $CamPivot/SpringArm3D/Camera3D
@export var mouse_sens = 0.15						#adjustable mouse sensitivity for camera
@export var ground_bounce_wait_time = 20			#time spring holds on ground in ground bounce
@export var ground_anim_speed = 0.5					#spring ground stretch/squash anim speed in ground state

var bounce_timer = 0								#enables spring ground movement after wait time expires
var charge_velocity = 0								#var to accumulate velocity in charge jump
var camera_target = Vector3(0, 2, 0)
var lerp_y = 0
var most_recent_groundpoint = Vector3()
var aim_vector = Vector3()
var bonk_timer = 0									#bonq

signal charging

func _ready():
	animationPlayer.play_backwards("SpringSquish")  #prevents error spam from having no animation while in the air
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED	#locks mouse to window and hides
	
func _input(event):
	if event is InputEventMouseMotion:				#camera control from mouse motion
		rotate_y(deg_to_rad(-event.relative.x * mouse_sens))
		camPivot.rotate_x(deg_to_rad(-event.relative.y * mouse_sens))
		camPivot.rotation.x = clamp(camPivot.rotation.x, deg_to_rad(-75), deg_to_rad(75))
	if event.is_action_pressed("escape"):
		Input.mouse_mode = Input.MOUSE_MODE_VISIBLE			#mouse made visible, can move outside game window
	if event.is_action_pressed("reset"):
		reset()
		
func _process(_delta: float) -> void:
	move_camera()
	if Input.is_action_pressed("left_click"):
		Input.mouse_mode = Input.MOUSE_MODE_CAPTURED		#locks mouse to window

func _physics_process(delta: float) -> void:
	'''For anything to do with physics in the world'''
	if is_on_floor():
		velocity = Vector3.ZERO 	#Kills ground velocity. May have to change for ragdoll or physics interactions.
		most_recent_groundpoint = position
		if Input.is_action_just_released("jump"):			#charge jump release, going airborne
			charge_jump()
		elif not Input.is_action_pressed("jump"):
			# Will fix jumping once this condition is revised
			if animationPlayer.current_animation_position == 0.0:
				animationPlayer.play("SpringSquish",-1, ground_anim_speed) 		#begin idle bounce animation
			bounce_timer += 1
			if bounce_timer >= ground_bounce_wait_time:							#bounce after hold period expires
				ground_move_spring()
		elif Input.is_action_pressed("jump"):
			velocity = Vector3.ZERO							#stop all movement, freeze in spot
			if animationPlayer.current_animation_position == 0.0:

				animationPlayer.play("SpringSquish",-1, 0.3)					#Squish spring
			if charge_velocity <= CHARGE_JUMP_POWER_MAX:	#caps charge velocity
				charge()
			charging.emit()  #ui signal
		
	if not is_on_floor():
		bounce_timer = 0 			#reset idle bounce timer
		if animationPlayer.current_animation_position != 0.0:
			animationPlayer.play_backwards("SpringSquish")	#Uncharge spring movement		
		velocity += get_gravity() * delta					#applies gravity while not on floor
	
	move_and_slide()										#NECESSARY for this stuff to actually all work
	
#functions block ----------
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
	# ================
	velocity = aim_vector * charge_velocity 	#aim_vector has length 1, multiply by charge strength
	charge_velocity = 0 						#reset charge velocity upon jump
	
func ground_move_spring() -> void:
	'''Uses built-in methodology for recording and applying horizontal movement during ground bounce'''
	var input_dir := Input.get_vector("move_left", "move_right", "move_forward", "move_back")
	var direction := (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	velocity.y = GROUND_BOUNCE_IMPULSE					#applies impulse to height velocity
	if direction:										#this block should only run one time
		velocity.x = direction.x * GROUND_SPEED
		velocity.z = direction.z * GROUND_SPEED
	else:
		velocity.x = move_toward(velocity.x, 0, GROUND_SPEED)
		velocity.z = move_toward(velocity.z, 0, GROUND_SPEED)
		
func move_camera() -> void:
	'''Uses lerp to move the camera. The camera will only fall if the spring falls more than 1.2 units from
	the peak of its height. This number is just large enough to keep the camera steady during idle bounce.
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
	position = Vector3(0, 2, 0) 		#Reset position to center +2 y height to not clip into ground
	velocity = Vector3(0, 0, 0)			#Reset velocity
