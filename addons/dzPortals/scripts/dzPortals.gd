tool
extends Node
#warning-ignore-all:unused_argument


var is_init = false

var _ig

var _material_gate
var _material_area
var _set_startzone = false

var camera = null
var visible_zones = 0
var gates_processed = 0

func _ready():
	init()
	
	var zones = get_tree().get_nodes_in_group("dzPortalsZones")
	for zone in zones:
		zone._gates = []

	var gates = get_tree().get_nodes_in_group("dzPortalsGates")
	for gate in gates:
		gate.register_zone()



func init_materials():
	_material_gate = SpatialMaterial.new()
	_material_gate.albedo_color = Color.white
	_material_gate.flags_transparent = true
	_material_gate.vertex_color_use_as_albedo= true
	_material_gate.params_line_width = 5
	
	_material_area = SpatialMaterial.new()
	_material_area.albedo_color = Color.white
	_material_area.vertex_color_use_as_albedo = true
	_material_area.flags_transparent = true
	_material_area.params_cull_mode = SpatialMaterial.CULL_DISABLED

func init():
	if is_init:
		return
	init_materials()
	
	is_init = true

func _process(delta):
	visible_zones = 0
	gates_processed = 0
	#print_debug(get_viewport().get_camera().name)
	
	get_tree().call_group("dzPortalsAreas","do_prepare")
	get_tree().call_group("dzPortalsGates","do_prepare")
	get_tree().call_group("dzPortalsZones","do_prepare")
	
	get_tree().call_group("dzPortalsAreas","do_portal")
	get_tree().call_group("dzPortalsGates","do_portal")
	get_tree().call_group("dzPortalsZones","do_portal")
	
	if camera:
		get_tree().call_group("dzPortalsAreas","do_camera")
		get_tree().call_group("dzPortalsGates","do_camera")
		get_tree().call_group("dzPortalsZones","do_camera")
		get_tree().call_group("dzPortalsCameras","do_camera")

