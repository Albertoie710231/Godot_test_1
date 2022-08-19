extends SpringArm

export var mouse_sensitivity := 0.05
export var controller_sesitivity = 0.1

func _ready():
	set_as_toplevel(true)
	var player_node = get_parent()
	#player_node.connect("ready_signal", self, "tilt_secondary_camera")

func _physics_process(delta):
	if get_node("SecondaryCamera").current == true:
		var direct_state = get_world().direct_space_state
		var collider = direct_state.intersect_ray(get_parent().transform.origin, Vector3(0, 1000.0, 0))
		if collider:
			var hypotenuse = 0.0
			var co = 0.0
			var degrees_x = 0.0
			collider.position.y -= (get_parent().transform.origin.y)
			co = collider.position.y
			hypotenuse = sqrt(co*co + spring_length*spring_length)
			degrees_x = rad2deg(acos(spring_length/hypotenuse))
			get_node("SecondaryCamera").rotation_degrees.x = degrees_x
		#print(degrees_x)
		
		#if event is InputEventMouseMotion and Input.get_mouse_mode() == Input.MOUSE_MODE_CAPTURED:
			#look_at(collider.position, Vector3.UP)
			#rotation_degrees.y -= event.relative.x * mouse_sensitivity
			#rotation_degrees.y = wrapf(rotation_degrees.y, 0, 360.0)
