extends Camera

# Rotation accumulators on the X and Y axis
# (This is part of the documentation code)
var rot_x = 0
var rot_y = 0
# The variables below may need adjusting...
# Movement speed
export var MOVE_SPEED = 3
# Rotation speed/sensitivity
# (The documentation does not define this constant, so
# I have no idea what it should be set to. I'm assuming a small value)
export var LOOKAROUND_SPEED = 0.01
# A boolean to track whether the right mouse button is down or not.
var is_right_mouse_button_down = false


func _process(delta):
	# The code below could be done in _input, but then it is a tad harder
	# to use input actions.
	if is_right_mouse_button_down == true:
		# Move the camera based on the key pressed
		if Input.is_action_pressed("ui_left"):
			translate(Vector3.LEFT * delta * MOVE_SPEED)
		if Input.is_action_pressed("ui_right"):
			translate(Vector3.RIGHT * delta * MOVE_SPEED)
		if Input.is_action_pressed("ui_up"):
			translate(Vector3.FORWARD * delta * MOVE_SPEED)
		if Input.is_action_pressed("ui_down"):
			translate(Vector3.BACK * delta * MOVE_SPEED)


func _input(event):
	if event is InputEventMouseMotion:
		# Only rotate if the right mouse button is down...
		if is_right_mouse_button_down == true:
			# (The code below is from the documentation)
			# modify accumulated mouse rotation
			rot_x -= event.relative.x * LOOKAROUND_SPEED
			rot_y -= event.relative.y * LOOKAROUND_SPEED
			transform.basis = Basis() # reset rotation
			rotate_object_local(Vector3(0, 1, 0), rot_x) # first rotate in Y
			rotate_object_local(Vector3(1, 0, 0), rot_y) # then rotate in X
	# check whether the right mouse button is down...
	if event is InputEventMouseButton:
		if event.button_index == BUTTON_RIGHT:
			is_right_mouse_button_down = event.pressed
