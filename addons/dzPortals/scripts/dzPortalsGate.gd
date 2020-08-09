tool
extends ImmediateGeometry
#warning-ignore-all:unused_argument

const BLUE_SIDE = 1
const RED_SIDE = 2

export(Vector2) var dimensions = Vector2(1,1) setget _set_dimensions
export(float) var margin = 0.05

export(bool) var do_frustum_check = true

export(NodePath) var _blue_zone setget _set_blue_zone
export(NodePath) var _red_zone setget _set_red_zone

export(bool) var auto_detect_zones = false setget _auto_detect_zones

export var debug= []

var blue_zone
var red_zone

var cornerPoints = []
var _plane

func get_class():
	return "dzPortalsGate"

func _ready():
	register_blue_zone()
	register_red_zone()
	_set_dimensions(dimensions)
	add_to_group("dzPortalsGates")
	material_override = dzPortals._material_gate


#----------------------------------- processing
func go_prepare():
	_plane = Plane(to_global(cornerPoints[1]),to_global(cornerPoints[0]),to_global(cornerPoints[2]))
	pass


func go_portal():
	pass


func do_camera():
	pass


#----------------------------------- state
func get_side( vec ):
	if _is_behind( vec, self ):
		return BLUE_SIDE
	else:
		return RED_SIDE


func _is_invisible( vec, cam ):
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


#----------------------------------- set zones
func _set_blue_zone( value ):
	_blue_zone = value
	register_blue_zone()


func register_blue_zone():
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


func _set_red_zone( value ):
	_red_zone = value
	register_red_zone()


func register_red_zone():
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
	if not red_zone or not blue_zone:
		return false
	var camera = get_viewport().get_camera()
	if zone == red_zone:
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
	if zone == red_zone:
		return blue_zone
	else:
		return red_zone


func redraw():
	if not Engine.editor_hint:
		return

	var d = dimensions / 2.0
	
	clear()
	begin(Mesh.PRIMITIVE_TRIANGLES)
	set_color(Color(1,0,0,0.5))
	add_vertex(Vector3( d.x, d.y,-margin))
	add_vertex(Vector3(-d.x, d.y,-margin))
	add_vertex(Vector3(-d.x,-d.y,-margin))
	add_vertex(Vector3(-d.x,-d.y,-margin))
	add_vertex(Vector3( d.x,-d.y,-margin))
	add_vertex(Vector3( d.x, d.y,-margin))
	set_color(Color(0,0,1,0.5))
	add_vertex(Vector3(-d.x, d.y, margin))
	add_vertex(Vector3( d.x, d.y, margin))
	add_vertex(Vector3(-d.x,-d.y, margin))
	add_vertex(Vector3( d.x,-d.y, margin))
	add_vertex(Vector3(-d.x,-d.y, margin))
	add_vertex(Vector3( d.x, d.y, margin))
	end()
	
	var pointerWidth = 0.05
	if red_zone:
		begin(Mesh.PRIMITIVE_TRIANGLES)
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

	if red_zone:
		begin(Mesh.PRIMITIVE_LINES)
		set_color(Color(1,0,0,0.5))
		add_vertex(Vector3( 0, 0,0))
		add_vertex(to_local(red_zone.global_transform.origin))
		end()

	if blue_zone:
		begin(Mesh.PRIMITIVE_LINES)
		set_color(Color(0,0,1,0.5))
		add_vertex(Vector3( 0, 0,0))
		add_vertex(to_local(blue_zone.global_transform.origin))
		end()

#-------------------------------------- tools
func _auto_detect_zones(value):
	if value == false:
		return
	var areas = get_tree().get_nodes_in_group("dzPortalsAreas")
	for area in areas:
		if area.is_inside( global_transform.origin ):
			if get_side( area.zone.global_transform.origin ) == BLUE_SIDE:
				_set_blue_zone( get_path_to(area.zone))
			else:
				_set_red_zone( get_path_to(area.zone))
	property_list_changed_notify()
