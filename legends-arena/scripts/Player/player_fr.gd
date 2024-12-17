extends CharacterBody3D


const SPEED = 5.0
const JUMP_VELOCITY = 4.5

var sens_horizontal = 0.09
var sens_vertical = 0.09

var horizontal: float = 0
var vertical: float = 0

var camera_input_direction := Vector2.ZERO
var last_direction = Vector3.FORWARD
var rotation_speed = 8

@onready var camera_pivot: Node3D = $CameraPivot
@onready var body: Node3D = $Armature

func _ready() -> void:
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	
	
func _input(event: InputEvent) -> void:
	if event.is_action_pressed("left_click"):
		Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	elif event.is_action_pressed("ui_cancel"):
		Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	
	if Input.get_mouse_mode() == Input.MOUSE_MODE_CAPTURED and event is InputEventMouseMotion:
		rotate_y(deg_to_rad(-event.relative.x * sens_horizontal))
		body.rotate_y(deg_to_rad(event.relative.x * sens_horizontal))
		camera_pivot.rotate_x(deg_to_rad(-event.relative.y * sens_vertical))
		camera_pivot.rotation.x = clamp(camera_pivot.rotation.x, deg_to_rad(-40), deg_to_rad(65))
		
		#horizontal = event.relative.x * sens_horizontal
		#vertical = event.relative.y * sens_vertical


func _physics_process(delta: float) -> void:
	
	#rotation.y = lerpf(rotation.y, rotation.y - horizontal * delta, 10 * delta)
	#camera_pivot.rotation.x = lerpf(camera_pivot.rotation.x, camera_pivot.rotation.x - vertical * delta, 10 * delta)
	#camera_pivot.rotation.x = clamp(camera_pivot.rotation.x, deg_to_rad(-40), deg_to_rad(65))
	#
	#horizontal = 0
	#vertical = 0
	
	if not is_on_floor():
		velocity += get_gravity() * delta

	# Handle jump.
	if Input.is_action_just_pressed("jump") and is_on_floor():
		velocity.y = JUMP_VELOCITY

	# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace UI actions with custom gameplay actions.
	var input_dir := Input.get_vector("move_left", "move_right", "move_forward", "move_backward")
	var direction := (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	
	if direction.length() > 0.2:
		last_direction = direction
	var target_angle := Vector3.BACK.signed_angle_to(last_direction, Vector3.UP)

	body.global_rotation.y = lerp_angle(body.global_rotation.y, target_angle, rotation_speed * delta)
	
	if direction:
		velocity.x = direction.x * SPEED
		velocity.z = direction.z * SPEED
		
		#body.look_at(position + direction)
		#body.rotation.x = deg_to_rad(90)
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED * delta * 6)
		velocity.z = move_toward(velocity.z, 0, SPEED * delta * 6)

	move_and_slide()
