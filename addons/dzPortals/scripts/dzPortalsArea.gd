tool
extends ImmediateGeometry
#warning-ignore-all:unused_argument

enum SHAPES { box,sphere,cylinder }
export(SHAPES) var shape = 0
export(Vector3) var dimensions = Vector3.ONE
export(float) var margin = 0.05
export(NodePath) var _zone setget _set_zone
var zone
export var _blackList = [] setget _set_blackList
var blackList = []

export(bool) var asign_to_parent = false setget _assign_to_parent
export(bool) var resize_to_mesh = false setget _resize_to_mesh

var _is_inside_last_time = false

signal area_entered
signal area_exited

func _set( property, value ):
	set( property, value )
	redraw()

#---------------------------------------- processing
func _ready():
	register_zone( )
	register_blackList( )
	material_override = dzPortals._material_area
	add_to_group("dzPortalsAreas")

func do_prepare():
	pass


func do_portal():
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


func do_camera():
	pass

#-------------------------------- black list
func _set_blackList( value ):
	_blackList = value
	register_blackList( )

func register_blackList( ):
	blackList = []
	for zonePath in _blackList:
		if typeof(zonePath) == TYPE_NODE_PATH:
			var new_zone = get_node_or_null(zonePath)
			if new_zone and new_zone.get_class() == "dzPortalsZone":
				blackList.append(new_zone)


#-------------------------------- zone
func _set_zone( value ):
	_zone = value
	register_zone()

func register_zone( ):
	zone = get_node_or_null(_zone)


#-------------------------------- state
func is_inside( vec ):
	match shape:
		SHAPES.box:
			return is_inside_box(vec)
		SHAPES.sphere:
			return is_inside_sphere(vec)
		SHAPES.cylinder:
			return is_inside_cylinder( vec )


func is_inside_box( vec ):
	var d = dimensions / 2.0 + Vector3(margin,margin,margin)
	var v = to_local(vec)
	if abs(v.x) > d.x:
		return false
	if abs(v.y) > d.y:
		return false
	if abs(v.z) > d.z:
		return false
	return true


func is_inside_sphere( vec ):
	var d = dimensions / 2.0 + Vector3(margin,margin,margin)
	var v = to_local(vec)
	if v.length() > d.x:
		return false
	return true


func is_inside_cylinder( vec ):
	var d = dimensions / 2.0 + Vector3(margin,margin,margin)
	var v = to_local(vec)
	if abs(v.y) > d.y:
		return false
	if Vector2(v.x,v.z).length() > d.x:
		return false
	return true


#-------------------------------- drawing
func getDrawColor():
	if zone and zone._is_visible:
		return Color(0,1,0,0.25)
	else:
		return Color(1,0,0,0.25)

func setDrawColor():
	set_color(getDrawColor())


var _last_color
var _last_shape

func _process(delta):
	if not Engine.editor_hint:
		return
	var update = false
	if _last_color != getDrawColor().to_rgba32():
		_last_color = getDrawColor().to_rgba32()
		update = true
	if _last_shape != shape:
		_last_shape = shape
		update = true
	if update:
		redraw()


func redraw():
	if not Engine.editor_hint:
		return
	
	var d = dimensions / 2.0 + Vector3(margin,margin,margin)
	clear()
	
	match shape:
		SHAPES.box:
			drawBox(d)
		SHAPES.sphere:
			drawSphere(d.x)
		SHAPES.cylinder:
			drawCylinder( 18, d.x, d.y)


func drawBox( d ):
	begin(Mesh.PRIMITIVE_TRIANGLES)
	setDrawColor()

	add_vertex(Vector3( d.x, d.y, d.z))
	add_vertex(Vector3(-d.x, d.y, d.z))
	add_vertex(Vector3(-d.x, d.y,-d.z))
	add_vertex(Vector3(-d.x, d.y,-d.z))
	add_vertex(Vector3( d.x, d.y,-d.z))
	add_vertex(Vector3( d.x, d.y, d.z))
	
	add_vertex(Vector3(-d.x,-d.y, d.z))
	add_vertex(Vector3( d.x,-d.y, d.z))
	add_vertex(Vector3(-d.x,-d.y,-d.z))
	add_vertex(Vector3( d.x,-d.y,-d.z))
	add_vertex(Vector3(-d.x,-d.y,-d.z))
	add_vertex(Vector3( d.x,-d.y, d.z))
	
	add_vertex(Vector3( d.x, d.y,-d.z))
	add_vertex(Vector3(-d.x, d.y,-d.z))
	add_vertex(Vector3(-d.x,-d.y,-d.z))
	add_vertex(Vector3(-d.x,-d.y,-d.z))
	add_vertex(Vector3( d.x,-d.y,-d.z))
	add_vertex(Vector3( d.x, d.y,-d.z))
	
	add_vertex(Vector3(-d.x, d.y, d.z))
	add_vertex(Vector3( d.x, d.y, d.z))
	add_vertex(Vector3(-d.x,-d.y, d.z))
	add_vertex(Vector3( d.x,-d.y, d.z))
	add_vertex(Vector3(-d.x,-d.y, d.z))
	add_vertex(Vector3( d.x, d.y, d.z))
	
	add_vertex(Vector3( d.x, d.y, d.z))
	add_vertex(Vector3( d.x, d.y,-d.z))
	add_vertex(Vector3( d.x,-d.y,-d.z))
	add_vertex(Vector3( d.x,-d.y,-d.z))
	add_vertex(Vector3( d.x,-d.y, d.z))
	add_vertex(Vector3( d.x, d.y, d.z))
	
	add_vertex(Vector3(-d.x, d.y,-d.z))
	add_vertex(Vector3(-d.x, d.y, d.z))
	add_vertex(Vector3(-d.x,-d.y,-d.z))
	add_vertex(Vector3(-d.x,-d.y, d.z))
	add_vertex(Vector3(-d.x,-d.y,-d.z))
	add_vertex(Vector3(-d.x, d.y, d.z))
	
	end()


func drawCylinder( sides, r, h):
	var angle = (360.0 / sides) * 0.01745329252
	var halfHeight = h
	sides += 1
	
	# draw top of the tube
	begin(Mesh.PRIMITIVE_TRIANGLE_FAN )
	setDrawColor()
	for i in range(0,sides):
		var x = cos( ( i * angle ) ) * r;
		var y = sin( ( i * angle ) ) * r;
		add_vertex( Vector3(x, -halfHeight, y))
	end()
	
	# draw bottom of the tube
	begin(Mesh.PRIMITIVE_TRIANGLE_FAN )
	setDrawColor()
	for i in range(0,sides):
		var x = cos( ( i * angle ) ) * r
		var y = sin( ( i * angle ) ) * r
		add_vertex( Vector3(x, halfHeight, y))
	end()
	
	# draw sides
	begin(Mesh.PRIMITIVE_TRIANGLE_STRIP )
	setDrawColor()
	for i in range(0,sides):
		var x = cos( ( i * angle ) ) * r;
		var y = sin( ( i * angle ) ) * r;
		add_vertex( Vector3(x, halfHeight, y))
		add_vertex( Vector3(x, -halfHeight, y))
	end()


func drawSphere( d ):
	begin(Mesh.PRIMITIVE_TRIANGLES )
	setDrawColor()
	add_sphere( 8, 14, d )
	end()


#----------------------------------- tool functions
func _assign_to_parent(value):
	if not value:
		return
	var o = self
	while o:
		if o.get_class() == "dzPortalsZone":
			_set_zone( get_path_to(o) )
			property_list_changed_notify()
			return
		o = o.get_parent()

func _resize_to_mesh(value):
	if not value:
		return
	if not zone:
		return
	var lowest = Vector3(99999,99999,99999)
	var highest = Vector3(-99999,-99999,-99999)
	resize_to_mesh = value
	for child in zone.get_children():
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
	
	resize_to_mesh = false
	property_list_changed_notify()

