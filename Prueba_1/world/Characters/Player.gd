extends KinematicBody

export var max_speed : float = 10.0
export var acceleration : float = 70
export var friction : float = 60.0
export var air_friction : float = 10.0
export var gravity : float = 50.0
export var jump_impulse : float = 20.0

var is_valid_area = false
var _velocity : Vector3 = Vector3.ZERO
var _snap_vector : Vector3 = Vector3.DOWN
var ready_flag : bool = false
var temp_rotation : float = 0.0
var body_entered_exited_list : Array = []

enum state_name {
	NORMAL,
	READY,
	ACTION
}

var state = state_name.NORMAL

onready var _spring_arm : SpringArm = $SpringArm
onready var _model : Spatial = $Pivot
onready var _collision_shape : CollisionShape = $CollisionShape
onready var _area_shape : CollisionShape = $Area/CollisionShape
onready var _secundary_camera : SpringArm = $SecondarySpringarm


signal ready_signal()

func _unhandled_key_input(_event):
	if Input.is_action_just_pressed("ready_button"):
		emit_signal("ready_signal")
		if state == state_name.NORMAL:
			state = state_name.READY
		elif state == state_name.READY:
			state = state_name.NORMAL
	elif Input.is_action_just_pressed("action_button") and state == state_name.READY and is_valid_area:
		state = state_name.ACTION
		
	#print(state_name.keys()[state])

func _process(_delta:float) -> void:
	_spring_arm.translation = self.translation
	_secundary_camera.translation = self.translation

func _physics_process(delta:float) -> void:
	match state:
		state_name.NORMAL:
			movement_func(delta)
		state_name.READY:
			is_valid_area = ready_func()
			ready_movement(delta)
		state_name.ACTION:
			action_func()
			ready_movement(delta)

func imput_movement(input_vector:Vector3, rotating_object:Node) -> Vector3:
	input_vector.x = Input.get_action_strength("move_right") - Input.get_action_strength("move_left")
	input_vector.z = Input.get_action_strength("move_back") - Input.get_action_strength("move_forward")
	input_vector = input_vector.rotated(Vector3.UP, rotating_object.rotation.y).normalized()
	return input_vector

func movement_func(delta:float) -> void:
	var input_vector = Vector3.ZERO
	input_vector = imput_movement(input_vector, _spring_arm)
	
	if _snap_vector == Vector3.DOWN:
		_velocity.x = input_vector.x * max_speed
		_velocity.z = input_vector.z * max_speed
	
	_velocity.y -= gravity * delta
	
	var is_jumping : bool = is_on_floor() and Input.is_action_just_pressed("jump")
	var just_landing : bool = is_on_floor() and _snap_vector == Vector3.ZERO
	
	if is_jumping:
		_velocity.y = jump_impulse
		_snap_vector = Vector3.ZERO
	elif just_landing:
		_snap_vector = Vector3.DOWN
		
	_velocity = move_and_slide_with_snap(_velocity, _snap_vector, Vector3.UP, true)
	
	var is_moving_on_floor : bool = Vector2(_velocity.z,_velocity.x).length() > 0.2
	
	if is_moving_on_floor:
		var look_direction = Vector2(-_velocity.z, -_velocity.x)
		_model.rotation.y = lerp_angle(_model.rotation.y,look_direction.angle(),0.7)

func ready_movement(delta) -> void:
	var input_vector = Vector3.ZERO
	input_vector = imput_movement(input_vector, _secundary_camera)
	
	if state == state_name.READY:
		_velocity.x = input_vector.x * max_speed
		_velocity.z = input_vector.z * max_speed
		_velocity.y -= gravity * delta
	elif state == state_name.ACTION:
		_velocity.x = 0.0
		_velocity.z = 0.0
		_velocity.y = 10
	
	_velocity = move_and_slide(_velocity, Vector3.UP)
	
	var is_moving_on_floor : bool = Vector2(_velocity.z,_velocity.x).length() > 0.2
	
	if is_moving_on_floor:
		var look_direction = Vector2(-_velocity.z, -_velocity.x)
		_model.rotation.y = lerp_angle(_model.rotation.y,look_direction.angle(),0.7)

func ready_func() -> bool:
	var valid_area = false
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
		valid_area = true
	
	return valid_area
		#action_just_pressed("action_button"):
			#_spring_arm.get_node("Camera").current = true
			#_secundary_camera.get_node("SecondaryCamera").current = false
			#state = ACTION
			#_collision_shape.disabled = true
			#_area_shape.disabled = false

func action_func():
	if is_valid_area:
		emit_signal("ready_signal")
		state = state_name.ACTION
		_collision_shape.disabled = true
		_area_shape.disabled = false
		is_valid_area = false
	
	if body_entered_exited_list.size() > 1:
		for i in range(1,body_entered_exited_list.size(),2):
			if body_entered_exited_list[i] == 0:
				_collision_shape.disabled = false
				_area_shape.disabled = true
				body_entered_exited_list = []
				state = state_name.NORMAL

func _on_Area_body_entered(_body:Node):
	body_entered_exited_list.append(1)


func _on_Area_body_exited(_body:Node):
	body_entered_exited_list.append(0)
