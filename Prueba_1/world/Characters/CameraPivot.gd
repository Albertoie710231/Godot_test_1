extends Spatial

export var mouse_sensitivity := 0.05
export var controller_sesitivity = 0.1

func _unhandled_input(event):
	if get_node("Camera").current == true:
		if event is InputEventMouseMotion and Input.get_mouse_mode() == Input.MOUSE_MODE_CAPTURED:
			rotation_degrees.y -= event.relative.x * mouse_sensitivity
			rotation_degrees.y = wrapf(rotation_degrees.y, 0, 360.0)
