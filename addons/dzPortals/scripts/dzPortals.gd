tool
extends Node
#warning-ignore-all:unused_argument


var is_init = false

var _ig

var plugin
var control

var _material_gate
var _material_area
var _set_startzone = false

var camera = null
var visible_zones = 0
var gates_processed = 0
var clipped_polys = 0
var processing_time = 0
var processing_time_measure = 0
var processing_time_start = 0

signal stats_updated

func _ready():
	init()
	
	var zones = get_tree().get_nodes_in_group("dzPortalsZones")
	for zone in zones:
		zone._gates = []

	var gates = get_tree().get_nodes_in_group("dzPortalsGates")
	for gate in gates:
		gate.register_red_zone()
		gate.register_blue_zone()



func init_materials():
	_material_gate = preload("res://addons/dzPortals/materials/gate.material")
#	_material_gate = SpatialMaterial.new()
#	_material_gate.albedo_color = Color.white
#	_material_gate.flags_transparent = true
#	_material_gate.vertex_color_use_as_albedo= true
#	_material_gate.params_line_width = 5
	
	_material_area = preload("res://addons/dzPortals/materials/area.material")
#	_material_area = SpatialMaterial.new()
#	_material_area.albedo_color = Color.white
#	_material_area.vertex_color_use_as_albedo = true
#	_material_area.flags_transparent = true
#	_material_area.params_cull_mode = SpatialMaterial.CULL_DISABLED

func init():
	if is_init:
		return
	init_materials()
	
	is_init = true

func _process(delta):
	var _visible_zones = visible_zones
	var _gates_processed = gates_processed
	var _clipped_polys = clipped_polys
	var _processing_time = processing_time
	
	var start = OS.get_ticks_msec()
	visible_zones = 0
	gates_processed = 0
	clipped_polys = 0
	
	get_tree().call_group_flags(SceneTree.GROUP_CALL_REALTIME,"dzPortalsAreas","do_prepare")
	get_tree().call_group_flags(SceneTree.GROUP_CALL_REALTIME,"dzPortalsGates","do_prepare")
	get_tree().call_group_flags(SceneTree.GROUP_CALL_REALTIME,"dzPortalsZones","do_prepare")
	
	get_tree().call_group_flags(SceneTree.GROUP_CALL_REALTIME,"dzPortalsAreas","do_portal")
	get_tree().call_group_flags(SceneTree.GROUP_CALL_REALTIME,"dzPortalsGates","do_portal")
	get_tree().call_group_flags(SceneTree.GROUP_CALL_REALTIME,"dzPortalsZones","do_portal")
	
	processing_time_measure += OS.get_ticks_msec() - start 
	
	if control:
		if processing_time_start + 1000 < OS.get_ticks_msec():
			processing_time_start = OS.get_ticks_msec()
			processing_time = processing_time_measure / 1000
			processing_time_measure = 0
		
		get_tree().call_group_flags(SceneTree.GROUP_CALL_REALTIME,"dzPortalsAreas","do_inspector")
		get_tree().call_group_flags(SceneTree.GROUP_CALL_REALTIME,"dzPortalsGates","do_inspector")
		get_tree().call_group_flags(SceneTree.GROUP_CALL_REALTIME,"dzPortalsZones","do_inspector")
	
		if _visible_zones != visible_zones:
			emit_signal("stats_updated")
#			control.update()
			return
		if _gates_processed != gates_processed:
			emit_signal("stats_updated")
#			control.update()
			return
		if _clipped_polys != clipped_polys: 
			emit_signal("stats_updated")
#			control.update()
			return
		if _processing_time != processing_time:
			emit_signal("stats_updated")
#			control.update()
			return
