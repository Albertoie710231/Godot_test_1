extends KinematicBody

export var max_speed = 10.0
export var acceleration = 70
export var friction = 60
export var air_friction = 10
export var gravity = 50.0
export var jump_impulse = 20.0

var temp_direction = 0.0
var temp_velocity = Vector2.ZERO
var _velocity = Vector3.ZERO
var _snap_vector = Vector3.DOWN
var ready_flag = false
var action_flag = false
var body_entered_exited_list = []

onready var _spring_arm = $SpringArm
onready var _model = $Pivot
onready var _collision_shape = $CollisionShape
onready var _area_shape = $Area/CollisionShape
onready var _secundary_camera = $CameraPivot
onready var _camera_pivot = $CameraPivot

func _process(_delta):
	_spring_arm.translation = self.translation

func _physics_process(delta):
	if ready_func() == false:
		movement_func(delta)
	else:
		warp_func()
		action_movement()
	
	#print(ready_flag)

func imput_movement(input_vector, rotating_object):
	input_vector.x = Input.get_action_strength("move_right") - Input.get_action_strength("move_left")
	input_vector.z = Input.get_action_strength("move_back") - Input.get_action_strength("move_forward")
	input_vector = input_vector.rotated(Vector3.UP, rotating_object.rotation.y).normalized()
	return input_vector

func movement_func(delta):
	var input_vector = Vector3.ZERO
	input_vector = imput_movement(input_vector, _spring_arm)
	
	if _snap_vector == Vector3.DOWN:
		_velocity.x = input_vector.x * max_speed
		_velocity.z = input_vector.z * max_speed
	
	_velocity.y -= gravity * delta
	
	if is_on_floor() and Input.is_action_just_pressed("jump"):
		_velocity.y = jump_impulse
		_snap_vector = Vector3.ZERO
	elif is_on_floor() and _snap_vector == Vector3.ZERO:
		_snap_vector = Vector3.DOWN
		
	_velocity = move_and_slide_with_snap(_velocity, _snap_vector, Vector3.UP, true)
	
	if _velocity.length() > 0.2:
		var look_direction = Vector2(-_velocity.z, -_velocity.x)
		if _snap_vector == Vector3.ZERO or _velocity.y < -1.7:
			_model.rotation.y = temp_direction
		else:
			_model.rotation.y = look_direction.angle()
			temp_direction = _model.rotation.y
	print(_velocity.y)

func action_movement():
	var input_vector = Vector3.ZERO
	input_vector = imput_movement(input_vector, _camera_pivot)
	
	if action_flag == false:
		_velocity.x = input_vector.x * max_speed
		_velocity.z = input_vector.z * max_speed
		_snap_vector = Vector3.DOWN
	else:
		_velocity.x = 0.0
		_velocity.z = 0.0
		_velocity.y = 5
		_snap_vector = Vector3.ZERO
	
	_velocity = move_and_slide_with_snap(_velocity, _snap_vector, Vector3.UP, true)
	
	if _velocity.length() > 0.2:
		var look_direction = Vector2(-_velocity.z, -_velocity.x)
		if action_flag == false:
			_model.rotation.y = look_direction.angle()
			temp_direction = _model.rotation.y

		

func ready_func():
	if Input.is_action_just_pressed("ready_button") and action_flag == false:
		ready_flag = !ready_flag
		_spring_arm.get_node("Camera").current = !ready_flag
		_secundary_camera.get_node("Camera").current = ready_flag
	return ready_flag

func warp_func():
	if ready_flag == true:
		var direct_state = get_world().direct_space_state
		var collider_1 = direct_state.intersect_ray(transform.origin + Vector3(0,0,1), Vector3(0, 1000.0, 0))
		var collider_2 = direct_state.intersect_ray(transform.origin + Vector3(0.8660,0,0.5), Vector3(0, 1000.0, 0))
		var collider_3 = direct_state.intersect_ray(transform.origin + Vector3(0.8660,0,-0.5), Vector3(0, 1000.0, 0))
		var collider_4 = direct_state.intersect_ray(transform.origin + Vector3(0,0,-1), Vector3(0, 1000.0, 0))
		var collider_5 = direct_state.intersect_ray(transform.origin + Vector3(-0.8660,0,0.5), Vector3(0, 1000.0, 0))
		var collider_6 = direct_state.intersect_ray(transform.origin + Vector3(-0.8660,0,-0.5), Vector3(0, 1000.0, 0))
		
		
		if collider_1 and collider_2 and collider_3 and collider_4 and collider_5 and collider_6:
			collider_1.position.y -= transform.origin.y 
			collider_2.position.y -= transform.origin.y 
			collider_3.position.y -= transform.origin.y 
			collider_4.position.y -= transform.origin.y 
			collider_5.position.y -= transform.origin.y 
			collider_6.position.y -= transform.origin.y 
			if Input.is_action_just_pressed("action_button"):
				_spring_arm.get_node("Camera").current = true
				_secundary_camera.get_node("Camera").current = false
				action_flag = true
				_collision_shape.disabled = true
				_area_shape.disabled = false
			#print(collider_1.position)
		
		if body_entered_exited_list.size() > 1 and action_flag == true:
			for i in range(1,body_entered_exited_list.size(),2):
				if body_entered_exited_list[i] == "o":
					ready_flag = false
					action_flag = false
					_collision_shape.disabled = false
					_area_shape.disabled = true
					body_entered_exited_list = []
		


func _on_Area_body_entered(_body):
	body_entered_exited_list.append("i")


func _on_Area_body_exited(_body):
	body_entered_exited_list.append("o")
