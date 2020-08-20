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
extends ImmediateGeometry
#warning-ignore-all:unused_argument

enum SHAPE { box,sphere,cylinder }
export(SHAPE) var shape = 0
export(Vector3) var dimensions = Vector3.ONE
export(float) var margin = 0.05
export(NodePath) var _zone setget _set_zone
var zone
export var _blackList = [] setget _set_blackList
var blackList = []


export(bool) var disabled = false setget _set_disabled

var _is_inside_last_time = false
var _viewportSprite
var _is_ready = false

signal area_entered
signal area_exited

func get_class():
	return "dzPortalsArea"

#---------------------------------------- processing
func _ready():
	if Engine.editor_hint:
		_add_viewport_sprite()
	_register_zone( )
	_register_blackList( )
	material_override =  load("res://addons/dzPortals/materials/area.material")
	add_to_group("dzPortalsAreas")
	_is_ready = true

func _add_viewport_sprite():
	if _viewportSprite:
		return
	_viewportSprite = Sprite3D.new()
	_viewportSprite.pixel_size = 0.0004
	_viewportSprite.offset.y = 100
	_viewportSprite.cast_shadow = false
	_viewportSprite.material_override = load("res://addons/dzPortals/materials/iconArea.material")
	_viewportSprite.texture = _viewportSprite.material_override.albedo_texture
	add_child(_viewportSprite)


func do_prepare():
	pass


func do_portal():
	if disabled:
		return
	if zone:
		var camera = get_viewport().get_camera()
		if not camera:
			return
		if is_inside( camera.global_transform.origin ):
			zone._is_active = true
			if not _is_inside_last_time:
				emit_signal("area_entered")
			_is_inside_last_time = true
			for blackZone in blackList:
				blackZone._is_active = false
				blackZone._is_visible = false
				blackZone._is_processed = true
		else:
			if _is_inside_last_time:
				emit_signal("area_exited")
				_is_inside_last_time = false


func do_inspector():
	pass


#-------------------------------- black list
func _set_blackList( value ):
	_blackList = value
	_register_blackList( )

func _register_blackList( ):
	blackList = []
	for zonePath in _blackList:
		if typeof(zonePath) == TYPE_NODE_PATH:
			var new_zone = get_node_or_null(zonePath)
			if new_zone and new_zone.get_class() == "dzPortalsZone":
				blackList.append(new_zone)

#----------------------------------- disabled
func _set_disabled(value):
	disabled = value
	redraw()

#-------------------------------- zone
func _set_zone( value ):
	_zone = value
	_register_zone()

func _register_zone( ):
	zone = get_node_or_null(_zone)


#-------------------------------- state
func is_inside( vec ):
	match shape:
		SHAPE.box:
			return _is_inside_box(vec)
		SHAPE.sphere:
			return _is_inside_sphere(vec)
		SHAPE.cylinder:
			return _is_inside_cylinder( vec )
	return false


func _is_inside_box( vec ):
	var d = dimensions / 2.0 + Vector3(margin,margin,margin)
	var v = to_local(vec)
	if abs(v.x) > d.x:
		return false
	if abs(v.y) > d.y:
		return false
	if abs(v.z) > d.z:
		return false
	return true


func _is_inside_sphere( vec ):
	var d = dimensions / 2.0 + Vector3(margin,margin,margin)
	var v = to_local(vec)
	if v.length() > d.x:
		return false
	return true


func _is_inside_cylinder( vec ):
	var d = dimensions / 2.0 + Vector3(margin,margin,margin)
	var v = to_local(vec)
	if abs(v.y) > d.y:
		return false
	if Vector2(v.x,v.z).length() > d.x:
		return false
	return true


#-------------------------------- drawing
func _getDrawColor():
	if disabled:
		return Color(0.5,0.5,0.5,0.25)
	if zone and zone._is_visible:
		return Color(0,1,0,0.25)
	else:
		return Color(1,0,0,0.25)

func _setDrawColor():
	set_color(_getDrawColor())


var _last_color
var _last_shape
var _last_dimensions

func _process(delta):
	if not Engine.editor_hint:
		return
	var update = false
	if _last_color != _getDrawColor().to_rgba32():
		_last_color = _getDrawColor().to_rgba32()
		update = true
	if _last_shape != shape:
		_last_shape = shape
		update = true
	if _last_dimensions != dimensions:
		_last_dimensions = dimensions
		update = true
	if update:
		redraw()


func redraw():
	if not Engine.editor_hint:
		return
	if not _is_ready:
		return
	
	var d = dimensions / 2.0 + Vector3(margin,margin,margin)
	clear()
	
	match shape:
		SHAPE.box:
			_drawBox(d)
		SHAPE.sphere:
			_drawSphere(d.x)
		SHAPE.cylinder:
			_drawCylinder( 18, d.x, d.y)


func _drawBox( d ):
	begin(Mesh.PRIMITIVE_TRIANGLES)
	_setDrawColor()
	
	set_uv(Vector2( d.x, d.y))
	add_vertex(Vector3( d.x, d.y, d.z))
	set_uv(Vector2(-d.x, d.y))
	add_vertex(Vector3(-d.x, d.y, d.z))
	set_uv(Vector2(-d.x,-d.y))
	add_vertex(Vector3(-d.x, d.y,-d.z))
	set_uv(Vector2(-d.x,-d.y))
	add_vertex(Vector3(-d.x, d.y,-d.z))
	set_uv(Vector2( d.x,-d.y))
	add_vertex(Vector3( d.x, d.y,-d.z))
	set_uv(Vector2( d.x, d.y))
	add_vertex(Vector3( d.x, d.y, d.z))
	
	set_uv(Vector2(-d.x, d.y))
	add_vertex(Vector3(-d.x,-d.y, d.z))
	set_uv(Vector2( d.x, d.y))
	add_vertex(Vector3( d.x,-d.y, d.z))
	set_uv(Vector2(-d.x,-d.y))
	add_vertex(Vector3(-d.x,-d.y,-d.z))
	set_uv(Vector2( d.x,-d.y))
	add_vertex(Vector3( d.x,-d.y,-d.z))
	set_uv(Vector2(-d.x,-d.y))
	add_vertex(Vector3(-d.x,-d.y,-d.z))
	set_uv(Vector2( d.x, d.y))
	add_vertex(Vector3( d.x,-d.y, d.z))
	
	set_uv(Vector2( d.x, d.y))
	add_vertex(Vector3( d.x, d.y,-d.z))
	set_uv(Vector2(-d.x, d.y))
	add_vertex(Vector3(-d.x, d.y,-d.z))
	set_uv(Vector2(-d.x,-d.y))
	add_vertex(Vector3(-d.x,-d.y,-d.z))
	set_uv(Vector2(-d.x,-d.y))
	add_vertex(Vector3(-d.x,-d.y,-d.z))
	set_uv(Vector2( d.x,-d.y))
	add_vertex(Vector3( d.x,-d.y,-d.z))
	set_uv(Vector2( d.x, d.y))
	add_vertex(Vector3( d.x, d.y,-d.z))
	
	set_uv(Vector2(-d.x, d.y))
	add_vertex(Vector3(-d.x, d.y, d.z))
	set_uv(Vector2( d.x, d.y))
	add_vertex(Vector3( d.x, d.y, d.z))
	set_uv(Vector2(-d.x,-d.y))
	add_vertex(Vector3(-d.x,-d.y, d.z))
	set_uv(Vector2( d.x,-d.y))
	add_vertex(Vector3( d.x,-d.y, d.z))
	set_uv(Vector2(-d.x,-d.y))
	add_vertex(Vector3(-d.x,-d.y, d.z))
	set_uv(Vector2( d.x, d.y))
	add_vertex(Vector3( d.x, d.y, d.z))
	
	set_uv(Vector2( d.x, d.y))
	add_vertex(Vector3( d.x, d.y, d.z))
	set_uv(Vector2( d.x,-d.y))
	add_vertex(Vector3( d.x, d.y,-d.z))
	set_uv(Vector2(-d.x,-d.y))
	add_vertex(Vector3( d.x,-d.y,-d.z))
	set_uv(Vector2(-d.x,-d.y))
	add_vertex(Vector3( d.x,-d.y,-d.z))
	set_uv(Vector2(-d.x, d.y))
	add_vertex(Vector3( d.x,-d.y, d.z))
	set_uv(Vector2( d.x, d.y))
	add_vertex(Vector3( d.x, d.y, d.z))
	
	set_uv(Vector2( d.x,-d.y))
	add_vertex(Vector3(-d.x, d.y,-d.z))
	set_uv(Vector2( d.x, d.y))
	add_vertex(Vector3(-d.x, d.y, d.z))
	set_uv(Vector2(-d.x,-d.y))
	add_vertex(Vector3(-d.x,-d.y,-d.z))
	set_uv(Vector2(-d.x, d.y))
	add_vertex(Vector3(-d.x,-d.y, d.z))
	set_uv(Vector2(-d.x,-d.y))
	add_vertex(Vector3(-d.x,-d.y,-d.z))
	set_uv(Vector2( d.x, d.y))
	add_vertex(Vector3(-d.x, d.y, d.z))
	
	end()


func _drawCylinder( sides, r, h):
	var angle = (360.0 / sides) * 0.01745329252
	var halfHeight = h
	sides += 1
	
	# draw top of the tube
	begin(Mesh.PRIMITIVE_TRIANGLE_FAN )
	_setDrawColor()
	for i in range(0,sides):
		var x = cos( ( i * angle ) ) * r;
		var y = sin( ( i * angle ) ) * r;
		set_uv(Vector2(x,y))
		add_vertex( Vector3(x, -halfHeight, y))
	end()
	
	# draw bottom of the tube
	begin(Mesh.PRIMITIVE_TRIANGLE_FAN )
	_setDrawColor()
	for i in range(0,sides):
		var x = cos( ( i * angle ) ) * r
		var y = sin( ( i * angle ) ) * r
		set_uv(Vector2(x,y))
		add_vertex( Vector3(x, halfHeight, y))
	end()
	
	# draw sides
	begin(Mesh.PRIMITIVE_TRIANGLE_STRIP )
	_setDrawColor()
	for i in range(0,sides):
		var x = cos( ( i * angle ) ) * r;
		var y = sin( ( i * angle ) ) * r;
		set_uv(Vector2(i, halfHeight))
		add_vertex( Vector3(x, halfHeight, y))
		set_uv(Vector2(i,-halfHeight))
		add_vertex( Vector3(x, -halfHeight, y))
	end()


func _drawSphere( d ):
	begin(Mesh.PRIMITIVE_TRIANGLES )
	_setDrawColor()
	add_sphere( 8, 14, d )
	end()


#----------------------------------- tool functions
func assign_to_parent():
	var o = self
	while o:
		if o.get_class() == "dzPortalsZone":
			_set_zone( get_path_to(o) )
			property_list_changed_notify()
			return
		o = o.get_parent()

func resize_to_mesh( child ):
	if not child:
		return
	var lowest = Vector3(99999,99999,99999)
	var highest = Vector3(-99999,-99999,-99999)
	if child.get_class() == "MeshInstance":
		var aabb = child.get_aabb()
		var v = child.to_global(aabb.position)
		if v.x < lowest.x:
			lowest.x = v.x
		if v.y < lowest.y:
			lowest.y = v.y
		if v.z < lowest.z:
			lowest.z = v.z
		if v.x > highest.x:
			highest.x = v.x
		if v.y > highest.y:
			highest.y = v.y
		if v.z > highest.z:
			highest.z = v.z
			
		v = child.to_global(aabb.end)
		if v.x < lowest.x:
			lowest.x = v.x
		if v.y < lowest.y:
			lowest.y = v.y
		if v.z < lowest.z:
			lowest.z = v.z
		if v.x > highest.x:
			highest.x = v.x
		if v.y > highest.y:
			highest.y = v.y
		if v.z > highest.z:
			highest.z = v.z
	rotation = Vector3.ZERO
	
	var size = highest - lowest
	var center = lowest + size / 2.0
	translation = get_parent().to_local(center)
	
	lowest = to_local(lowest)
	highest = to_local(highest)
	size = highest - lowest
	dimensions = size.abs()


func resize_to_zone():
	if not zone:
		return
	var lowest = Vector3(99999,99999,99999)
	var highest = Vector3(-99999,-99999,-99999)
	var child_count = 0
	for child in zone.get_children():
		if child.get_class() == "MeshInstance":
			child_count += 1
			var aabb = child.get_aabb()
			var v = child.to_global(aabb.position)
			if v.x < lowest.x:
				lowest.x = v.x
			if v.y < lowest.y:
				lowest.y = v.y
			if v.z < lowest.z:
				lowest.z = v.z
			if v.x > highest.x:
				highest.x = v.x
			if v.y > highest.y:
				highest.y = v.y
			if v.z > highest.z:
				highest.z = v.z
				
			v = child.to_global(aabb.end)
			if v.x < lowest.x:
				lowest.x = v.x
			if v.y < lowest.y:
				lowest.y = v.y
			if v.z < lowest.z:
				lowest.z = v.z
			if v.x > highest.x:
				highest.x = v.x
			if v.y > highest.y:
				highest.y = v.y
			if v.z > highest.z:
				highest.z = v.z
	rotation = Vector3.ZERO
	if child_count == 0:
		return
	var size = highest - lowest
	var center = lowest + size / 2.0
	translation = get_parent().to_local(center)
	
	lowest = to_local(lowest)
	highest = to_local(highest)
	size = highest - lowest
	dimensions = size.abs()
	
	property_list_changed_notify()

