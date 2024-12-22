extends CharacterBody3D

const SPEED = 5.0
const JUMP_VELOCITY = 4.5
@onready var cam_yaw: Node3D = $CamRoot/CamYaw
@onready var cam_pitch: Node3D = $CamRoot/CamYaw/CamPitch


@export var look_sensitivity = 1.0

func _ready():
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED	

func _input(event):
	if event is InputEventMouseMotion:
		cam_yaw.rotate_y(deg_to_rad(-event.relative.x * look_sensitivity))
		cam_pitch.rotate_x(deg_to_rad(-event.relative.y * look_sensitivity))
		cam_pitch.rotation.x = clamp(cam_pitch.rotation.x, deg_to_rad(-90), deg_to_rad(45))
		

func _physics_process(delta: float) -> void:
	# Add the gravity.
	if not is_on_floor():
		velocity += get_gravity() * delta

	# Handle jump.
	if Input.is_action_just_pressed("ui_accept") and is_on_floor():
		velocity.y = JUMP_VELOCITY
		
	if Input.is_action_just_pressed("escape"):
		print("quitting")
		get_tree().quit()

	# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace UI actions with custom gameplay actions.
	var input_dir := Input.get_vector("left", "right", "forward", "backward")
	var direction := (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	if direction:
		velocity.x = direction.x * SPEED
		velocity.z = direction.z * SPEED
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)
		velocity.z = move_toward(velocity.z, 0, SPEED)

	move_and_slide()
