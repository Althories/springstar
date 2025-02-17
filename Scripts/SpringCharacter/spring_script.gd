extends CharacterBody3D

const GROUND_SPEED = 5.0						#Grounded move speed
const JUMP_IMPULSE = 4.5						#Velocity impulse for ground bounce
const CAMERA_VERTICAL_OFFSET = 1.0
const CAMERA_INTERPOLATION_WEIGHT = 0.1
const CAMERA_VERTICAL_MOVEMENT_DEADZONE = 1.2
const IDLE_ANIM_SPEED = 0.6						#Gounded bounce animation speed

@onready var camPivot: Node3D = $CamPivot
@onready var animationPlayer: AnimationPlayer = $SpringAnimation
@export var sens = 0.15							#mouse sensitivity for camera
@export var idle_bounce_wait_frames = 20		#determines number of frames held on ground in ground bounce

var can_ground_bounce = true
var bounce_timer = 0							#used for ground bounce and determining bounce wait
var charge_velocity = 0							#accumulates velocity for charge jump
var camera_anchor = Vector3(0, 2, 0)
var slerp_y = 0
var most_recent_groundpoint = Vector3(0, 0, 0)

func _ready():
	animationPlayer.play_backwards("SpringSquish") 				#prevents error spam from having no animation while in the air
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED				#locks mouse cursor to window
	
func _input(event):
	if event is InputEventMouseMotion:							#For mapping mouse input to cam control
		rotate_y(deg_to_rad(-event.relative.x * sens))
		camPivot.rotate_x(deg_to_rad(-event.relative.y * sens))
		camPivot.rotation.x = clamp(camPivot.rotation.x, deg_to_rad(-60), deg_to_rad(45))
	if event.is_action_pressed("escape"):
		Input.mouse_mode = Input.MOUSE_MODE_VISIBLE				#mouse made visible, can move outside game window
	if event.is_action_pressed("reset"):
		reset()
		
func _process(_delta: float) -> void:
	move_camera()
	if Input.is_action_pressed("left_click"):
		Input.mouse_mode = Input.MOUSE_MODE_CAPTURED			#locks mouse to window

func _physics_process(delta: float) -> void:
	'''For anything to do with physics in the world'''
	if is_on_floor():
		velocity = Vector3() 									#Kills ground velocity. May have to change for ragdoll or physics interactions.
		most_recent_groundpoint = self.position					#records spring position 
		if Input.is_action_just_released("jump"):				#charge jump release
			velocity.y = JUMP_IMPULSE/3 + charge_velocity 		#temporary until charge is handled
			charge_velocity = 0									#reset charge velocity upon jump
		elif not Input.is_action_pressed("jump"):				#on floor but not starting a charge jump
			#Will fix jumping once this condition is revised
			bounce_timer += 1
			if animationPlayer.current_animation_position == 0.0:
				animationPlayer.play("SpringSquish",-1, IDLE_ANIM_SPEED) #begin idle bounce animation
			if bounce_timer >= idle_bounce_wait_frames:			#apply bounce velocity after ground_bounce_wait
				can_ground_bounce = true						#not starting a jump, ground bounce
				velocity.y = JUMP_IMPULSE						#regular bounce impulse
		elif Input.is_action_pressed("jump"):
			can_ground_bounce = false							#stops ground movement upon charge start
			velocity = Vector3.ZERO								#stop all movement, freeze in spot
			if animationPlayer.current_animation_position == 0.0:
				animationPlayer.play("SpringSquish",-1, 0.3)	#Squish spring (flushed)
			if charge_velocity <= 18:							#arbitrary cap value on charge velocity
				charge()
		
	if not is_on_floor():
		bounce_timer = 0		#reset timer until next time spring is on the floor
		if animationPlayer.current_animation_position != 0.0:
			animationPlayer.play_backwards("SpringSquish")		#Uncharge spring movement		
		velocity += get_gravity() * delta						#Apply gravity. Can be changed in project settings			
		can_ground_bounce = false								#keeps spring from using ground controls in the air
	
	if can_ground_bounce:
		ground_move_spring()
		
	move_and_slide()			#NECESSARY for this stuff to actually all work
	
#functions block ----------
func charge() -> void:
	'''Charge function for spring jump.'''
	charge_velocity += .40		#hardcoded temp rate. Should be constant anyslay
	
func ground_move_spring():
	'''Record and apply input for on the ground bounces'''
	var input_dir := Input.get_vector("move_left", "move_right", "move_forward", "move_back")
	var direction := (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	if direction:
		velocity.x = direction.x * GROUND_SPEED
		velocity.z = direction.z * GROUND_SPEED
	else:
		velocity.x = move_toward(velocity.x, 0, GROUND_SPEED)
		velocity.z = move_toward(velocity.z, 0, GROUND_SPEED)
		
func move_camera():
	'''Uses slerp to move the camera. The camera will only fall if the spring falls more than 1.2 units from
	the peak of its height. This number is just large enough to keep the camera steady during idle bounce.
	!! If Spring is on Collision Layer 1, the SpringArm3D gets confused and starts clipping the spring.
	I suspect slerp is behind this.'''
	if self.global_position.y >= slerp_y:
		slerp_y = self.global_position.y
	elif slerp_y - self.global_position.y > CAMERA_VERTICAL_MOVEMENT_DEADZONE:
		slerp_y = self.global_position.y + CAMERA_VERTICAL_MOVEMENT_DEADZONE
	camera_anchor = camera_anchor.slerp(
		Vector3(self.global_position.x, slerp_y + CAMERA_VERTICAL_OFFSET, self.global_position.z), 
		CAMERA_INTERPOLATION_WEIGHT)
	$CamPivot/SpringArm3D.global_position = camera_anchor
	
func reset() -> void:
	'''Reset player to state on startup'''
	position = Vector3(0, 2, 0) 		#Reset position to center +2 y height to not clip into ground
	velocity = Vector3(0, 0, 0)			#Reset velocity
