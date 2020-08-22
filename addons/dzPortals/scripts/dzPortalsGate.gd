######################################################################
#
# Project           : dzPortals
# Author            : Klaas Janneck
# Date              : Aug 2020
# Purpose           : Godot portal engine plugin
# License           : MIT
# contact           : kj@deck-zwei.de
# Source at         : https://github.com/D2klaas/dzPortals
#
######################################################################
tool
extends "res://addons/dzPortals/scripts/dzPortalsVolume.gd"
#warning-ignore-all:unused_argument

const BLUE_SIDE = 1
const RED_SIDE = 2

export(bool) var arealess = false setget _set_arealess

#const margin = 0.05

export(bool) var do_frustum_check = true

export(NodePath) var _blue_zone setget set_blue_zone
export(NodePath) var _red_zone setget set_red_zone

export(bool) var is_magnetic = false
export(bool) var auto_magnetic = false

export var magnetic_distance = 0.2
export var magnetic_angle = 0.1
export var magnetic_dimension = 0.1

export(NodePath) var _magnetic_gate setget _set_magnetic_gate
var magnetic_gate

export(bool) var disabled = false setget _set_disabled

var blue_zone
var red_zone

var cornerPoints = [Vector3.ZERO,Vector3.ZERO,Vector3.ZERO,Vector3.ZERO]
var _plane
var _viewportSprite
var _is_init = false
var _is_tree = true

func _init():
	_magnetic_gate = NodePath("")


func _set_arealess(value):
	arealess = value
	redraw()

var last_blue_zone_visible
var last_red_zone_visible
func _process(delta):
	var update = false
	var zone = get_blue_zone()
	if zone and last_blue_zone_visible != zone._is_visible:
		last_blue_zone_visible = zone._is_visible
		update = true
	zone = get_red_zone()
	if zone and last_red_zone_visible != zone._is_visible:
		last_red_zone_visible = zone._is_visible
		update = true
	if update:
		redraw()

func get_class():
	return "dzPortalsGate"

func _ready():
	_is_init = true
	_is_tree = true
	if Engine.editor_hint:
		set_notify_transform ( true )
		material_override = load("res://addons/dzPortals/materials/gate.material")
		_add_viewport_sprite()
	_register_blue_zone()
	_register_red_zone()
	add_to_group("dzPortalsGates")


func _add_viewport_sprite():
	if _viewportSprite:
		return
	_viewportSprite = Sprite3D.new()
	_viewportSprite.pixel_size = 0.0004
	_viewportSprite.offset.y = 100
	_viewportSprite.cast_shadow = false
	_viewportSprite.material_override = load("res://addons/dzPortals/materials/iconGate.material")
	_viewportSprite.texture = _viewportSprite.material_override.albedo_texture
	add_child(_viewportSprite)


func _notification( what ):
	if what == Spatial.NOTIFICATION_TRANSFORM_CHANGED:
		if is_magnetic and auto_magnetic:
			auto_find_magnetic_gate()
		redraw()


#----------------------------------- processing
func do_prepare():
	if is_disabled():
		return
	_plane = Plane(to_global(cornerPoints[1]),to_global(cornerPoints[0]),to_global(cornerPoints[2]))
	pass


func do_portal():
	if arealess:
		var zone
		var camera = get_viewport().get_camera()
		var blue_zone = get_blue_zone()
		var red_zone = get_red_zone()
		if not camera:
			return
		if is_inside( camera.global_transform.origin ):
			if get_side( camera.global_transform.origin ) == BLUE_SIDE:
				if blue_zone:
					dzPortals.current_zone = blue_zone
				if red_zone:
					red_zone._is_visible = true
			else:
				if blue_zone:
					dzPortals.current_zone = red_zone
				if red_zone:
					blue_zone._is_visible = true


func do_inspector():
	pass


#----------------------------------- state
func get_side( vec ):
	if _is_behind( vec, self ):
		return BLUE_SIDE
	else:
		return RED_SIDE


func _is_invisible( vec, cam ):
	if is_disabled():
		return true
	if _is_behind( vec, cam ):
		return true
	
	var checkFrustum = (cam == get_viewport().get_camera())
	
	if do_frustum_check and checkFrustum:
		if _is_in_frustum( vec,cam ):
			return false
		else:
			return true
	else:
		return false


func _is_in_frustum( vec, cam ):
	var screenSize = Vector2(ProjectSettings.get_setting("display/window/size/width"),ProjectSettings.get_setting("display/window/size/height"))
	var screenPosition
	var horizontal = 0
	var vertical = 0
	
	var global_p
	for p in cornerPoints:
		global_p = to_global(p)
		global_p += cam.to_global(Vector3(0,0,-cam.near)) - cam.global_transform.origin
		
		screenPosition = cam.unproject_position(global_p) / screenSize
		
		if _is_position_behind(global_p,cam):
			if screenPosition.x > 0.5:
				screenPosition.x = -2
			else:
				screenPosition.x = 2
				
			if screenPosition.y > 0.5:
				screenPosition.y = -2
			else:
				screenPosition.y = 2
		
		if screenPosition.x > 1:
			horizontal += 1
		elif screenPosition.x < 0:
			horizontal -= 1
		if abs(horizontal) == 4:
			return false
		
		if screenPosition.y > 1:
			vertical += 1
		elif screenPosition.y < 0:
			vertical -= 1
		if abs(vertical) == 4:
			return false
	
	return true


func _is_behind( vec, cam ):
	for p in cornerPoints:
#		if not cam.is_position_behind ( vec + (vec - to_global(p)) ):
		if not _is_position_behind ( vec + (vec - to_global(p)), cam ):
			return false
	return true


func is_position_behind( vec ):
	return _plane.is_point_over(vec)


func _is_position_behind( vec, cam ):
	var plane = Plane(cam.to_global(Vector3(0,0,0)),cam.to_global(Vector3(1,1,0)),cam.to_global(Vector3(1,0,0)))
	return plane.is_point_over(vec)


#----------------------------------- planes
func get_red_plane():
	var plane = Plane(to_global(Vector3(0,0,0)),to_global(Vector3(1,1,0)),to_global(Vector3(1,0,0)))
	return plane


func get_blue_plane():
	var plane = Plane(to_global(Vector3(0,0,0)),to_global(Vector3(1,-1,0)),to_global(Vector3(1,0,0)))
	return plane


func get_zone_facing_plane(zone):
	if zone == get_red_zone():
		return get_red_plane()
	if zone == get_blue_zone():
		return get_blue_plane()

func get_zone_averted_plane(zone):
	if zone == get_red_zone():
		return get_blue_plane()
	if zone == get_blue_zone():
		return get_red_plane()


#----------------------------------- set dimensions
func _set_dimensions( value ):
	dimensions = value
	var d = dimensions / 2.0
	cornerPoints = [
		Vector3(-d.x, d.y, 0),
		Vector3(-d.x,-d.y, 0),
		Vector3( d.x, d.y, 0),
		Vector3( d.x,-d.y, 0)
	]
	redraw()

func get_global_corner(id):
	return.to_global(cornerPoints[id])
	

#----------------------------------- magnets
func _is_magnetic():
	if not is_magnetic:
		return false
	if red_zone and blue_zone:
		return false
	return true


func _set_magnetic_gate( value:NodePath, stop_propagate=false ):
	if magnetic_gate:
		if not stop_propagate:
			magnetic_gate._set_magnetic_gate( "", true )
#	if not value:
#		_magnetic_gate = ""
#		_register_magnetic_gate()
#		return
	if red_zone and blue_zone:
		_magnetic_gate = ""
		_register_magnetic_gate()
		return
	var node = get_node_or_null(value)
	if node and node.get_class() != "dzPortalsGate":
		_magnetic_gate = ""
		_register_magnetic_gate()
		return
	_magnetic_gate = value
	_register_magnetic_gate(  )
	property_list_changed_notify()


func _register_magnetic_gate(  ):
	magnetic_gate = get_node_or_null(_magnetic_gate)
	redraw()

func set_magnetic_gate( value:Object ):
	if not value:
		_set_magnetic_gate( "" )
		return
	_set_magnetic_gate( get_path_to(value) )



func get_magnetic_zone():
	if not blue_zone:
		return red_zone
	if not red_zone:
		return blue_zone


func auto_find_magnetic_gate():
	if not _is_magnetic():
		return
	var gates = get_tree().get_nodes_in_group("dzPortalsGates")
	
	set_magnetic_gate(null)
	
	for gate in gates:
		if gate == self:
			continue
		if not gate._is_magnetic():
			continue
		if global_transform.origin.distance_to(gate.global_transform.origin) > magnetic_distance:
			continue
		var my_orientation = to_global(Vector3.FORWARD) - global_transform.origin
		var gate_orientation = gate.to_global(Vector3.FORWARD) - gate.global_transform.origin
		var off_orientation = my_orientation.angle_to(gate_orientation)
		if off_orientation > magnetic_angle and off_orientation < PI - magnetic_angle:
			continue
		if abs(dimensions.x - gate.dimensions.x) > magnetic_dimension:
			continue
		if abs(dimensions.y - gate.dimensions.y) > magnetic_dimension:
			continue
		set_magnetic_gate(gate)
		gate.set_magnetic_gate(self)
		return


#----------------------------------- disabled
func _set_disabled(value):
	disabled = value
	redraw()


func is_disabled():
	if disabled:
		return true
	if is_magnetic and magnetic_gate and magnetic_gate.disabled:
		return true


#----------------------------------- set zones
func get_red_zone():
	if red_zone:
		return red_zone
	elif magnetic_gate:
		return magnetic_gate.get_magnetic_zone()


func get_blue_zone():
	if blue_zone:
		return blue_zone
	elif magnetic_gate:
		return magnetic_gate.get_magnetic_zone()


func set_blue_zone( value ):
	_blue_zone = value
	_register_blue_zone()



func _register_blue_zone():
	if blue_zone:
		blue_zone.remove_gate( self )
	blue_zone = get_node_or_null(_blue_zone)
	if not blue_zone:
		redraw()
		return
	if blue_zone.get_class() != "dzPortalsZone":
		blue_zone = null
		_blue_zone = ""
		redraw()
		return
	
	blue_zone.add_gate(self)
	redraw()


func set_red_zone( value ):
	_red_zone = value
	_register_red_zone()


func _register_red_zone():
	if red_zone:
		red_zone.remove_gate( self )
	red_zone = get_node_or_null(_red_zone)
	if not red_zone:
		redraw()
		return
	if red_zone.get_class() != "dzPortalsZone":
		red_zone = null
		_red_zone = ""
		redraw()
		return
	
	red_zone.add_gate(self)
	redraw()


func _is_visible( zone ):
	if disabled:
		return false
	if not get_red_zone() or not get_blue_zone():
		return false
	var camera = get_viewport().get_camera()
	if zone == get_red_zone():
		if _is_invisible( global_transform.origin, camera ):
				return false
		if _is_behind( camera.global_transform.origin, self ):
				return false
		return true
	else:
		if _is_invisible( global_transform.origin, camera ):
				return false
		if not _is_behind( camera.global_transform.origin, self ):
				return false
		return true


func get_other_zone( zone ):
	if zone == get_red_zone():
		return get_blue_zone()
	else:
		return get_red_zone()


var draw_color = Color(0.5,0.5,0.5,0.25)
func _getDrawColor():
	return draw_color


func _setDrawColor():
	set_color(_getDrawColor())

func redraw():
	if not Engine.editor_hint:
		return
	if not _is_init:
		return

	var d = dimensions / 2.0
	var d2 = dimensions / 2.0 + Vector3(margin,margin,margin)
	d2.z = d2.z / 2.0
	
	clear()
	
	if arealess:
		var zone = get_blue_zone()
		if zone and zone._is_visible:
			draw_color = Color(0,1,0,0.5)
		else:
			draw_color = Color(0.5,0.5,0.5,0.25)
		_drawBox(d2,Vector3(0,0,d2.z))
			
		zone = get_red_zone()
		if zone and zone._is_visible:
			draw_color = Color(0,1,0,0.5)
		else:
			draw_color = Color(0.5,0.5,0.5,0.25)
		_drawBox(d2,Vector3(0,0,-d2.z))
	
	begin(Mesh.PRIMITIVE_TRIANGLES)
	if disabled:
		set_color(Color(0.5,0.5,0.5,0.5))
	else:
		set_color(Color(1,0,0,0.5))
	set_uv(Vector2( d.x, d.y))
	add_vertex(Vector3( d.x, d.y,-margin))
	set_uv(Vector2(-d.x, d.y))
	add_vertex(Vector3(-d.x, d.y,-margin))
	set_uv(Vector2(-d.x,-d.y))
	add_vertex(Vector3(-d.x,-d.y,-margin))
	set_uv(Vector2(-d.x,-d.y))
	add_vertex(Vector3(-d.x,-d.y,-margin))
	set_uv(Vector2( d.x,-d.y))
	add_vertex(Vector3( d.x,-d.y,-margin))
	set_uv(Vector2( d.x, d.y))
	add_vertex(Vector3( d.x, d.y,-margin))

	if disabled:
		set_color(Color(0.5,0.5,0.5,0.5))
	else:
		set_color(Color(0,0,1,0.5))
	set_uv(Vector2(-d.x, d.y))
	add_vertex(Vector3(-d.x, d.y, margin))
	set_uv(Vector2( d.x, d.y))
	add_vertex(Vector3( d.x, d.y, margin))
	set_uv(Vector2(-d.x,-d.y))
	add_vertex(Vector3(-d.x,-d.y, margin))
	set_uv(Vector2( d.x,-d.y))
	add_vertex(Vector3( d.x,-d.y, margin))
	set_uv(Vector2(-d.x,-d.y))
	add_vertex(Vector3(-d.x,-d.y, margin))
	set_uv(Vector2( d.x, d.y))
	add_vertex(Vector3( d.x, d.y, margin))
	end()
	
	var pointerWidth = 0.15
	if red_zone:
		begin(Mesh.PRIMITIVE_TRIANGLES)
		if disabled:
			set_color(Color(0.5,0.5,0.5,0.5))
		else:
			set_color(Color(1,0,0,0.5))
		add_vertex(Vector3( 1, -1, 0) * pointerWidth)
		add_vertex(Vector3( 1, 1, 0) * pointerWidth)
		add_vertex(to_local(red_zone.global_transform.origin))
		add_vertex(Vector3( -1, 1, 0) * pointerWidth)
		add_vertex(Vector3( -1, -1, 0) * pointerWidth)
		add_vertex(to_local(red_zone.global_transform.origin))
		add_vertex(Vector3( 1, 1, 0) * pointerWidth)
		add_vertex(Vector3( -1, 1, 0) * pointerWidth)
		add_vertex(to_local(red_zone.global_transform.origin))
		add_vertex(Vector3( -1, -1, 0) * pointerWidth)
		add_vertex(Vector3( 1, -1, 0) * pointerWidth)
		add_vertex(to_local(red_zone.global_transform.origin))
		end()

	if blue_zone:
		begin(Mesh.PRIMITIVE_TRIANGLES)
		if disabled:
			set_color(Color(0.5,0.5,0.5,0.5))
		else:
			set_color(Color(0,0,1,0.5))
		add_vertex(Vector3( 1, 1, 0) * pointerWidth)
		add_vertex(Vector3( 1, -1, 0) * pointerWidth)
		add_vertex(to_local(blue_zone.global_transform.origin))
		add_vertex(Vector3( -1, -1, 0) * pointerWidth)
		add_vertex(Vector3( -1, 1, 0) * pointerWidth)
		add_vertex(to_local(blue_zone.global_transform.origin))
		add_vertex(Vector3( -1, 1, 0) * pointerWidth)
		add_vertex(Vector3( 1, 1, 0) * pointerWidth)
		add_vertex(to_local(blue_zone.global_transform.origin))
		add_vertex(Vector3( 1, -1, 0) * pointerWidth)
		add_vertex(Vector3( -1, -1, 0) * pointerWidth)
		add_vertex(to_local(blue_zone.global_transform.origin))
		end()


#-------------------------------------- tools
func auto_connect_zones():
	var areas = get_tree().get_nodes_in_group("dzPortalsAreas")
	for area in areas:
		if area.is_inside( global_transform.origin ):
			if get_side( area.zone.global_transform.origin ) == BLUE_SIDE:
				set_blue_zone( get_path_to(area.zone))
			else:
				set_red_zone( get_path_to(area.zone))
	property_list_changed_notify()


