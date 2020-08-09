tool
extends Camera
#warning-ignore-all:unused_argument

export var visible_zones = 0
export var gates_processed = 0

func _ready():
	dzPortals.camera = self
	add_to_group("dzPortalsCameras")


func do_camera():
	var update = false
	if dzPortals.visible_zones != visible_zones:
		visible_zones = dzPortals.visible_zones
		update = true
	if dzPortals.gates_processed != gates_processed:
		gates_processed = dzPortals.gates_processed
		update = true
	if update:
		property_list_changed_notify()
