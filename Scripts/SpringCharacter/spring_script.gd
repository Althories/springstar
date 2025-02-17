extends CharacterBody3D

const SPEED = 5.0
const JUMP_IDLE_IMPULSE = 4.5
const JUMP_CHARGE_IMPULSE = 2.0
const AIM_VERTICAL_OFFSET = 0.2
const AIM_VERTICAL_MINIMUM = 0.2
const JUMP_CHARGE_RATE = 0.4
const JUMP_CHARGE_POWER_MAX = 18.0
const CAMERA_VERTICAL_OFFSET = 1.0
const CAMERA_INTERPOLATION_WEIGHT = 0.1
const CAMERA_VERTICAL_MOVEMENT_DEADZONE = 1.2

@onready var camPivot: Node3D = $CamPivot
@onready var animationPlayer: AnimationPlayer = $SpringAnimation
@onready var camera: Node3D = $CamPivot/SpringArm3D/Camera3D
@export var sens = 0.15
@export var idle_bounce_wait_time = 20
@export var idle_anim_speed = 0.5

var can_ground_bounce = true
var bounce_timer = 0
var charge_velocity = 0
var camera_target = Vector3(0, 2, 0)
var lerp_y = 0
var most_recent_groundpoint = Vector3()
var aim_vector = Vector3()
var bonk_timer = 0

func _ready():
	animationPlayer.play_backwards("SpringSquish") # prevents error spam from having no animation while in the air
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	
func _input(event):
	if event is InputEventMouseMotion:
		rotate_y(deg_to_rad(-event.relative.x * sens))
		camPivot.rotate_x(deg_to_rad(-event.relative.y * sens))
		camPivot.rotation.x = clamp(camPivot.rotation.x, deg_to_rad(-75), deg_to_rad(75))
	if event.is_action_pressed("ui_cancel"):	#bound to esc by default
		Input.mouse_mode = Input.MOUSE_MODE_VISIBLE	#mouse made visible, can go outside game window
	if event.is_action_pressed("reset"):
		reset()
		
func _process(_delta: float) -> void:
	move_camera()
	if Input.is_action_pressed("left_click"):
		Input.mouse_mode = Input.MOUSE_MODE_CAPTURED	#locks mouse to window

func _physics_process(delta: float) -> void:
	'''For anything to do with physics in the world'''
	
	if is_on_floor():
		velocity = Vector3.ZERO # Kills ground velocity. May have to change for ragdoll or physics interactions.
		most_recent_groundpoint = position
		if Input.is_action_just_released("jump"):		#charge jump release
			charge_jump()
		elif not Input.is_action_pressed("jump"):
			# Will fix jumping once this condition is revised
			if animationPlayer.current_animation_position == 0.0:
				animationPlayer.play("SpringSquish",-1, idle_anim_speed) # begin idle bounce animation
			# bounce with delay
			bounce_timer += 1
			if bounce_timer >= idle_bounce_wait_time:
				ground_move_spring()
		elif Input.is_action_pressed("jump"):
			velocity = Vector3.ZERO						#stop all movement, freeze in spot
			if animationPlayer.current_animation_position == 0.0:
				animationPlayer.play("SpringSquish",-1, 0.3)		#Squish spring
			if charge_velocity <= JUMP_CHARGE_POWER_MAX:			#caps charge velocity
				charge()								#call charge function
		
	if not is_on_floor():
		bounce_timer = 0 # reset idle bounce timer
		if animationPlayer.current_animation_position != 0.0:
			animationPlayer.play_backwards("SpringSquish")				#Un charge spring movement		
		velocity += get_gravity() * delta				#gravity. Can be changed in settings
	
	move_and_slide()									#NECESSARY for this stuff to actually all work
	
#functions block ----------
func charge() -> void:
	'''Charge function for spring jump.'''
	charge_velocity += JUMP_CHARGE_RATE

func charge_jump() -> void:
	'''Execute a charge jump in the direction the camera is facing.'''
	# Takes a vector pointing in the negative z direction
	# with a vertical component dependant on camera rotation
	# and rotates it around a vector pointing straight up
	# by the rotation of the player model.
	# TODO: stop using model rotation
	aim_vector = Vector3(
		0, 
		max((AIM_VERTICAL_OFFSET + camPivot.rotation.x), AIM_VERTICAL_MINIMUM) * JUMP_CHARGE_IMPULSE,
		-1).rotated(Vector3(0, 1, 0), 
		rotation.y).normalized()
	# debug lines ====
	# $aimIndicator.top_level = true
	# $aimIndicator.position = position + aim_vector
	# print(aim_vector)
	# ================
	velocity = aim_vector * charge_velocity # aim_vector has length 1, multiply by charge strength
	charge_velocity = 0 # reset charge velocity upon jump
	
func ground_move_spring() -> void:
	# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace UI actions with custom gameplay actions.
	var input_dir := Input.get_vector("move_left", "move_right", "move_forward", "move_back")
	var direction := (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	velocity.y = JUMP_IDLE_IMPULSE					#regular bounce impulse
	if direction:
		velocity.x = direction.x * SPEED
		velocity.z = direction.z * SPEED
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)
		velocity.z = move_toward(velocity.z, 0, SPEED)
		
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
	position = Vector3(0, 2, 0) #Reset position to center +2 y height to not clip into ground
	velocity = Vector3(0, 0, 0)	#Reset velocity
