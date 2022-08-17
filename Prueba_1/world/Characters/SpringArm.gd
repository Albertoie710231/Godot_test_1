extends SpringArm

export var mouse_sensitivity := 0.05
export var controller_sesitivity = 0.1

func _ready():
	set_as_toplevel(true)
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	
func _unhandled_input(event):
	if event.is_action_pressed("click"):
		Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	
	if event.is_action_pressed("toggle_mouse_captured"):
		if Input.get_mouse_mode() == Input.MOUSE_MODE_CAPTURED:
			Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
		else:
			Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	
	if get_node("Camera").current == true:
		if event is InputEventMouseMotion and Input.get_mouse_mode() == Input.MOUSE_MODE_CAPTURED:
			rotation_degrees.x -= event.relative.y * mouse_sensitivity
			rotation_degrees.x = clamp(rotation_degrees.x, -90.0, 30.0)
			rotation_degrees.y -= event.relative.x * mouse_sensitivity
			rotation_degrees.y = wrapf(rotation_degrees.y, 0, 360.0)
