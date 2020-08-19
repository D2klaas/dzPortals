extends Spatial

var myGate
var open = 0.0
var target = 0.0
export var disabled = false

func _ready():
	myGate = dzPortals.get_nearest_gate($point.global_transform.origin)

func _process(delta):
	if disabled:
		return
	
	if $point.global_transform.origin.distance_to(get_viewport().get_camera().global_transform.origin) < 4.0:
		target = 2
	else:
		target = 0
	
	var d = target - open
	if abs(d) > 0.05:
		open += d * delta * 4.0
	else:
		open = target
	$point/upperDoor.translation.y = open
	$point/lowerDoor.translation.y = -open
	
	if myGate:
		if open > 0:
			myGate.disabled = false
		else:
			myGate.disabled = true
