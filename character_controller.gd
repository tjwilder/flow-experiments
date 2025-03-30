extends CharacterBody2D


const SPEED = 300.0
const JUMP_VELOCITY = -400.0

func _physics_process(delta: float) -> void:
	# Add the gravity.
	#if not is_on_floor():
		#velocity += get_gravity() * delta

	# Handle jump.
	if Input.is_action_just_pressed("ui_accept") and is_on_floor():
		velocity.y = JUMP_VELOCITY
		
	#print(Input.get("attack"))
	if Input.get_action_strength("attack"):
		$AnimationPlayer.play("attack")

	# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace UI actions with custom gameplay actions.
	
	var mouse_position = get_viewport().get_mouse_position()
	mouse_position = (get_viewport().get_screen_transform() * get_viewport().get_canvas_transform()).affine_inverse() * mouse_position
	#$Transform.rotation = Basis.looking_at(Vector3(mouse_position.x, mouse_position.y, 0))
	var dir = (mouse_position - position).normalized()
	rotation = atan2(dir.y, dir.x)
	var lr = Input.get_axis("move_left", "move_right")
	var ud = Input.get_axis("move_up", "move_down")
	var direction = Vector2(lr, ud)
	velocity += direction.normalized()
	#if direction:
		#velocity.x = direction * SPEED
	#else:
		#velocity.x = move_toward(velocity.x, 0, SPEED)

	move_and_slide()
