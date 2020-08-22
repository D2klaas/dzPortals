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


export(SHAPE) var _shape setget _set_shape


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

#---------------------------------------- shape
func _set_shape( value:int ):
	_shape = value
	shape = _shape
	redraw()


func _set_dimensions(value):
	dimensions = value
	redraw()

#---------------------------------------- processing
func _ready():
	if Engine.editor_hint:
		_add_viewport_sprite()
	_register_zone( )
	_register_blackList( )
	material_override =  load("res://addons/dzPortals/materials/area.material")
	add_to_group("dzPortalsAreas")
	_is_ready = true
	redraw()

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
			if zone:
				dzPortals.inc_stat("entered_areas", 1)
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



#-------------------------------- drawing
func _getDrawColor():
	if disabled:
		return Color(0.5,0.5,0.5,0.25)
	if zone and zone._is_visible:
		return Color(0,1,0,0.25)
	else:
		return Color(1,0,0,0.25)

var _last_color
var _last_shape = -1
var _lastdimensions

func _process(delta):
	if not Engine.editor_hint:
		return
	var update = false
	if _last_color != _getDrawColor().to_rgba32():
		_last_color = _getDrawColor().to_rgba32()
		update = true
	if _last_shape != _shape:
		_last_shape = _shape
		update = true
	if _lastdimensions != dimensions:
		_lastdimensions = dimensions
		update = true
	if update:
		redraw()


func redraw():
	if not Engine.editor_hint:
		return

	var d = dimensions / 2.0 + Vector3(margin,margin,margin)
	clear()
	
	match _shape:
		SHAPE.box:
			_drawBox(d)
		SHAPE.sphere:
			_drawSphere(d.x)
		SHAPE.cylinder:
			_drawCylinder( 18, d.x, d.y)




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
	_set_dimensions(size.abs())


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
	_set_dimensions(size.abs())
	
	property_list_changed_notify()

