extends CharacterBody3D

const SPEED = 5.0
const JUMP_VELOCITY = 4.5

var _camera_input_dir := Vector2.ZERO

#For controlling camera in the editor. This property will appear at the top of
#the properties in a node in the Inspector, and will be assigned the name "Camera".
@export_group("Camera") 	
@export_range(0.0, 1.0) var mouse_sensitivity := 0.25
@export_range(0.0, 1.0) var controller_sensitivity := 1

#Assisgns variables to nodes for camera control
@onready var _camera_pivot: Node3D = %SpringCameraPivot
@onready var _camera_springarm: SpringArm3D = %SpringArm
@onready var _camera: Camera3D = %SpringCamera

func _input(event: InputEvent) -> void:
	'''Block for handling mouse control and exiting window'''
	if event.is_action_pressed("ui_cancel"):	#bound to esc by default
		Input.mouse_mode = Input.MOUSE_MODE_VISIBLE	#mouse made visible, can go outside game window
	if event is InputEventMouseMotion and Input.get_mouse_mode() == Input.MOUSE_MODE_CAPTURED:
		_camera_input_dir = event.screen_relative * mouse_sensitivity
		
func _process(_delta: float) -> void:
	if Input.is_action_just_pressed("reset"):
		reset()
		
	if Input.is_action_pressed("left_click"):
		Input.mouse_mode = Input.MOUSE_MODE_CAPTURED	#locks mouse to window
		
	move_camera()	#constantly runs camera control

func _physics_process(delta: float) -> void:
	# Add the gravity.
	if not is_on_floor():
		velocity += get_gravity() * delta

	# Handle jump.
	if Input.is_action_just_pressed("jump") and is_on_floor():
		velocity.y = JUMP_VELOCITY
		
	ground_move_spring()
	print(velocity.x)

	move_and_slide()
	
# function list --------------------------
func ground_move_spring() -> void:
	'''Get the input direction and handle the movement/deceleration.'''
	var input_dir := Input.get_vector("move_left", "move_right", "move_forward", "move_back")
	var move_forward := _camera.global_basis.z
	var move_right := _camera.global_basis.x
	var move_direction := (move_forward * input_dir.y + move_right * input_dir.x).normalized()
	if move_direction:
		velocity.x = move_direction.x * SPEED
		velocity.z = move_direction.z * SPEED
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)
		velocity.z = move_toward(velocity.z, 0, SPEED)
		
func move_camera() -> void:
	'''Handles moving the camera for both keyboard and controller'''
	#Note: If kb and controller clamps mismatch, there may be issues
	#camera handling for keyboard
	_camera_springarm.rotation.x += (-_camera_input_dir.y) * 1/120
	_camera_springarm.rotation.x = clamp(_camera_springarm.rotation.x, -PI / 4.0, PI / 10.0)	#Limits up/down rotation for pivot
	_camera_pivot.rotation.y -= _camera_input_dir.x * 1/120
	_camera_input_dir = Vector2.ZERO	#stop rotating if the mouse stops being moved
	
	#camera handling for controller
	#Up is zoom in, down is zoom out. Zoom with springarm vector?
	var axis_vector = Input.get_vector("cam_left", "cam_right", "cam_up", "cam_down")
	if axis_vector.length() >= 0.05: #Will only move camera if controller stick is pushed far enough in any direction
		_camera_pivot.rotate_y(deg_to_rad(-axis_vector.x * controller_sensitivity))
		_camera_springarm.rotate_x(deg_to_rad(-axis_vector.y * controller_sensitivity))
		_camera_springarm.rotation.x = clamp(_camera_springarm.rotation.x, -PI / 4.0, PI / 10.0)

func reset() -> void:
	'''Reset player to state on startup'''
	position = Vector3(0, 2, 0) #Reset position to center +2 y height to not clip into ground
	velocity = Vector3(0, 0, 0)	#Reset velocity
	
