extends CharacterBody3D

const SPEED = 5.0
const JUMP_IMPULSE = 4.5
const CAMERA_VERTICAL_OFFSET = 1.0
const CAMERA_INTERPOLATION_WEIGHT = 0.1

@onready var cam_pivot: Node3D = $CamPivot
@export var sens = 0.15

var can_ground_bounce = true
var charge_velocity = 0
var camera_anchor = Vector3(0, 2, 0)
var slerp_y = 2.0
var most_recent_groundpoint = Vector3(0, 0, 0)

func _ready():
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	
func _input(event):
	if event is InputEventMouseMotion:
		rotate_y(deg_to_rad(-event.relative.x * sens))
		cam_pivot.rotate_x(deg_to_rad(-event.relative.y * sens))
		cam_pivot.rotation.x = clamp(cam_pivot.rotation.x, deg_to_rad(-60), deg_to_rad(45))
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
		most_recent_groundpoint = self.position
		if Input.is_action_just_released("jump"):		#charge jump release
			velocity.y = JUMP_IMPULSE/3 + charge_velocity 				#temporary until charge is handled
			charge_velocity = 0							#reset charge velocity upon jump
		elif not Input.is_action_pressed("jump"):
			can_ground_bounce = true					#not starting a jump, ground bounce
			velocity.y = JUMP_IMPULSE					#regular bounce impulse
		elif Input.is_action_pressed("jump"):
			can_ground_bounce = false					#stops ground movement upon charge start
			velocity = Vector3.ZERO						#stop all movement, freeze in spot
			if charge_velocity <= 18:					#caps charge velocity
				charge()								#call charge function
		
	if not is_on_floor():
		velocity += get_gravity() * delta				#gravity. Can be changed in settings			
		can_ground_bounce = false						#keeps spring from using ground controls in the air
	
	if can_ground_bounce:
		ground_move_spring()
		
	move_and_slide()									#NECESSARY for this stuff to actually all work
	
#functions block ----------
func charge() -> void:
	'''Charge function for spring jump.'''
	charge_velocity += .40
	
func ground_move_spring():
	# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace UI actions with custom gameplay actions.
	var input_dir := Input.get_vector("move_left", "move_right", "move_forward", "move_back")
	var direction := (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	if direction:
		velocity.x = direction.x * SPEED
		velocity.z = direction.z * SPEED
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)
		velocity.z = move_toward(velocity.z, 0, SPEED)
		
func move_camera():
	# Use slerp to move the camera. The camera will only fall if the spring falls more than 1.2 units from
	# the peak of its height. This number is just large enough to keep the camera steady during idle bounce.
	# !! If Spring is on Collision Layer 1, the SpringArm3D gets confused and starts clipping the spring.
	# I suspect slerp is behind this.
	if self.global_position.y >= slerp_y:
		slerp_y = self.global_position.y
	elif slerp_y - self.global_position.y > 1.2:
		slerp_y = self.global_position.y + 1.2
	camera_anchor = camera_anchor.slerp(
		Vector3(self.global_position.x, slerp_y + CAMERA_VERTICAL_OFFSET, self.global_position.z), 
		CAMERA_INTERPOLATION_WEIGHT)
	$CamPivot/SpringArm3D.global_position = camera_anchor
	
func reset() -> void:
	'''Reset player to state on startup'''
	position = Vector3(0, 2, 0) #Reset position to center +2 y height to not clip into ground
	velocity = Vector3(0, 0, 0)	#Reset velocity
