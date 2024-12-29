extends CharacterBody3D

const SPEED = 5.0
const JUMP_VELOCITY = 4.5
@onready var cam_yaw: Node3D = $CamRoot/CamYaw
@onready var cam_pitch: Node3D = $CamRoot/CamYaw/CamPitch
@onready var player_cam: Camera3D = $CamRoot/CamYaw/CamPitch/SpringArm3D/Camera3D
@onready var armature: Node3D = $Armature
@onready var animation_player: AnimationPlayer = $AnimationPlayer
@onready var animation_tree: AnimationTree = $AnimationTree


@export var look_sensitivity = 1.0
@export var lerp_val = .1
@export var anim_blend_speed = 15

var walk_val = 0
enum {IDLE,WALK}
var current_anim = IDLE

func handle_animation(delta):
	match current_anim:
		IDLE:
			walk_val = lerpf(walk_val, 0, anim_blend_speed * delta)
		WALK:
			walk_val = lerpf(walk_val, 1, anim_blend_speed * delta)
	update_tree()

func update_tree():
	animation_tree["parameters/Walk/blend_amount"] = walk_val

func _ready():
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED	

func _input(event):
	if event is InputEventMouseMotion:
		cam_yaw.rotate_y(deg_to_rad(-event.relative.x * look_sensitivity))
		cam_pitch.rotate_x(deg_to_rad(-event.relative.y * look_sensitivity))
		cam_pitch.rotation.x = clamp(cam_pitch.rotation.x, deg_to_rad(-90), deg_to_rad(45))

func _physics_process(delta: float) -> void:
	handle_animation(delta)
	# Add gravity.
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
	direction = direction.rotated(Vector3.UP, cam_yaw.rotation.y)
	
	if direction:
		current_anim = WALK
		velocity.x = direction.x * SPEED
		velocity.z = direction.z * SPEED
		armature.rotation.y = lerp_angle(armature.rotation.y, atan2(-velocity.x, -velocity.z), lerp_val)
	else:
		current_anim = IDLE
		velocity.x = move_toward(velocity.x, 0, SPEED)
		velocity.z = move_toward(velocity.z, 0, SPEED)

	move_and_slide()
