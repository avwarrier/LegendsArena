extends CharacterBody3D


var speed = 5.0
const JUMP_VELOCITY = 4.5

var sens_horizontal = 0.09
var sens_vertical = 0.09

var horizontal: float = 0
var vertical: float = 0

var camera_input_direction := Vector2.ZERO
var last_direction = Vector3.FORWARD
var rotation_speed = 8

# ACTIONS
var walking: bool
var idle: bool
var sprinting: bool
var attacking: bool = false
var nextAttack: bool = false
var jumping: bool
var attackAgain: bool = false
var baseAttackAgain: bool = false
var shielding: bool = false

@onready var camera_pivot: Node3D = $CameraPivot
@onready var body: Node3D = $Armature
@onready var animation_tree: AnimationTree = $AnimationTree

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
	
	if Input.is_action_just_pressed("slash") and not jumping:
		if attacking:
			attackAgain = true
		else:
			print("HERE")
			attacking = true
		
	if Input.is_action_just_pressed("shield"):
		shielding = true
	if Input.is_action_just_released("shield"):
		shielding = false
	
	if not is_on_floor():
		velocity += get_gravity() * delta

	# Handle jump.
	if Input.is_action_just_pressed("jump") and is_on_floor():
		jumping = true
		velocity.y = JUMP_VELOCITY

	# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace UI actions with custom gameplay actions.
	var input_dir := Input.get_vector("move_left", "move_right", "move_forward", "move_backward")
	var direction := (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	
	if direction.length() > 0.2:
		last_direction = direction
	var target_angle := Vector3.BACK.signed_angle_to(last_direction, Vector3.UP)

	body.global_rotation.y = lerp_angle(body.global_rotation.y, target_angle, rotation_speed * delta)
	
	if Input.is_action_pressed("sprint") and input_dir != Vector2.ZERO:
		sprinting = true
		speed = 7.0

	if Input.is_action_just_released("sprint") or input_dir == Vector2.ZERO:
		sprinting = false
		speed = 5
	
	if direction:
		velocity.x = direction.x * speed
		velocity.z = direction.z * speed
		
		#body.look_at(position + direction)
		#body.rotation.x = deg_to_rad(90)
	else:
		velocity.x = move_toward(velocity.x, 0, speed * delta * 6)
		velocity.z = move_toward(velocity.z, 0, speed * delta * 6)

	idle = input_dir == Vector2.ZERO and is_on_floor()
	walking = !sprinting and input_dir != Vector2.ZERO and is_on_floor()

	if (walking and attacking) or (sprinting and attacking):
		speed = 2.0
	else:
		speed = 5.0
		
	
	#print(attacking)

	animation_tree.set("parameters/conditions/idle", idle)
	animation_tree.set("parameters/conditions/walkForward", walking)
	animation_tree.set("parameters/conditions/jump", !is_on_floor())
	animation_tree.set("parameters/conditions/run", sprinting)
	animation_tree.set("parameters/conditions/attack", attacking)
	animation_tree.set("parameters/conditions/attackAgain", attackAgain)
	animation_tree.set("parameters/conditions/shieldEngage", shielding)
	animation_tree.set("parameters/conditions/shieldRetract", !shielding)

	move_and_slide()




func _on_animation_tree_animation_finished(anim_name: StringName) -> void:
	print(anim_name)
	if anim_name == "Slash" or anim_name == "UpSlash" or anim_name == "SideSlash":
		attacking = false
		attackAgain = false
	
	if anim_name == "Jump" or anim_name == "RunJumpInPlace":
		jumping = false


func _on_animation_tree_animation_started(anim_name: StringName) -> void:
	if anim_name == "SideSlash":
		attacking = false
