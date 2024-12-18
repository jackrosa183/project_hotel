extends CharacterBody3D


const SPEED = 5.0
const JUMP_VELOCITY = 4.5
@onready var cam_pivot: Node3D = $CameraOrigin
@export var look_sensitivity = 1.0

func _ready():
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED	

func _input(event):
	if event is InputEventMouseMotion:
		rotate_y(deg_to_rad(-event.relative.x * look_sensitivity))
		cam_pivot.rotate_x(deg_to_rad(-event.relative.y * look_sensitivity))
		cam_pivot.rotation.x = clamp(cam_pivot.rotation.x, deg_to_rad(-90), deg_to_rad(45))
			
			#cam_pivot.rotation_degrees.z = 0
		print(cam_pivot.rotation_degrees)
		#else: 
			##TODO LERP CAMERA BACK BEHIND PLAYER?
			#rotate_y(deg_to_rad(-event.relative.x * look_sensitivity))
			#cam_pivot.rotate_x(deg_to_rad(-event.relative.y * look_sensitivity))
		

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
