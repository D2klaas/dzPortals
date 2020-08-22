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

var shape:int
enum SHAPE { box,sphere,cylinder }
var dimensions:Vector3 = Vector3.ONE
export(float) var margin = 0.05

func _ready():
	pass


func _process(delta):
	pass


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


#----------------------------------- drae shapes
func _getDrawColor():
	return Color(0.5,0.5,0.5,0.25)


func _setDrawColor():
	set_color(_getDrawColor())


func _drawBox( d, vec = Vector3.ZERO ):
	begin(Mesh.PRIMITIVE_TRIANGLES)
	_setDrawColor()
	
	set_uv(Vector2( d.x, d.y))
	add_vertex(Vector3(vec.x +  d.x, vec.y + d.y, vec.z + d.z))
	set_uv(Vector2(-d.x, d.y))
	add_vertex(Vector3(vec.x + -d.x, vec.y + d.y, vec.z + d.z))
	set_uv(Vector2(-d.x,-d.y))
	add_vertex(Vector3(vec.x + -d.x, vec.y + d.y,vec.z + -d.z))
	set_uv(Vector2(-d.x,-d.y))
	add_vertex(Vector3(vec.x + -d.x, vec.y + d.y,vec.z + -d.z))
	set_uv(Vector2( d.x,-d.y))
	add_vertex(Vector3(vec.x +  d.x, vec.y + d.y,vec.z + -d.z))
	set_uv(Vector2( d.x, d.y))
	add_vertex(Vector3(vec.x +  d.x, vec.y + d.y, vec.z + d.z))
	
	set_uv(Vector2(-d.x, d.y))
	add_vertex(Vector3(vec.x + -d.x,vec.y + -d.y, vec.z + d.z))
	set_uv(Vector2( d.x, d.y))
	add_vertex(Vector3(vec.x +  d.x,vec.y + -d.y, vec.z + d.z))
	set_uv(Vector2(-d.x,-d.y))
	add_vertex(Vector3(vec.x + -d.x,vec.y + -d.y,vec.z + -d.z))
	set_uv(Vector2( d.x,-d.y))
	add_vertex(Vector3(vec.x +  d.x,vec.y + -d.y,vec.z + -d.z))
	set_uv(Vector2(-d.x,-d.y))
	add_vertex(Vector3(vec.x + -d.x,vec.y + -d.y,vec.z + -d.z))
	set_uv(Vector2( d.x, d.y))
	add_vertex(Vector3(vec.x +  d.x,vec.y + -d.y, vec.z + d.z))
	
	set_uv(Vector2( d.x, d.y))
	add_vertex(Vector3(vec.x +  d.x, vec.y + d.y,vec.z + -d.z))
	set_uv(Vector2(-d.x, d.y))
	add_vertex(Vector3(vec.x + -d.x, vec.y + d.y,vec.z + -d.z))
	set_uv(Vector2(-d.x,-d.y))
	add_vertex(Vector3(vec.x + -d.x,vec.y + -d.y,vec.z + -d.z))
	set_uv(Vector2(-d.x,-d.y))
	add_vertex(Vector3(vec.x + -d.x,vec.y + -d.y,vec.z + -d.z))
	set_uv(Vector2( d.x,-d.y))
	add_vertex(Vector3(vec.x +  d.x,vec.y + -d.y,vec.z + -d.z))
	set_uv(Vector2( d.x, d.y))
	add_vertex(Vector3(vec.x +  d.x, vec.y + d.y,vec.z + -d.z))
	
	set_uv(Vector2(-d.x, d.y))
	add_vertex(Vector3(vec.x + -d.x, vec.y + d.y,vec.z +  d.z))
	set_uv(Vector2( d.x, d.y))
	add_vertex(Vector3(vec.x +  d.x, vec.y + d.y,vec.z +  d.z))
	set_uv(Vector2(-d.x,-d.y))
	add_vertex(Vector3(vec.x + -d.x,vec.y + -d.y,vec.z +  d.z))
	set_uv(Vector2( d.x,-d.y))
	add_vertex(Vector3(vec.x +  d.x,vec.y + -d.y,vec.z +  d.z))
	set_uv(Vector2(-d.x,-d.y))
	add_vertex(Vector3(vec.x + -d.x,vec.y + -d.y,vec.z +  d.z))
	set_uv(Vector2( d.x, d.y))
	add_vertex(Vector3(vec.x +  d.x, vec.y + d.y,vec.z +  d.z))
	
	set_uv(Vector2( d.x, d.y))
	add_vertex(Vector3(vec.x +  d.x, vec.y + d.y,vec.z +  d.z))
	set_uv(Vector2( d.x,-d.y))
	add_vertex(Vector3(vec.x +  d.x, vec.y + d.y,vec.z + -d.z))
	set_uv(Vector2(-d.x,-d.y))
	add_vertex(Vector3(vec.x +  d.x,vec.y + -d.y,vec.z + -d.z))
	set_uv(Vector2(-d.x,-d.y))
	add_vertex(Vector3(vec.x +  d.x,vec.y + -d.y,vec.z + -d.z))
	set_uv(Vector2(-d.x, d.y))
	add_vertex(Vector3(vec.x +  d.x,vec.y + -d.y,vec.z +  d.z))
	set_uv(Vector2( d.x, d.y))
	add_vertex(Vector3(vec.x +  d.x, vec.y + d.y,vec.z +  d.z))
	
	set_uv(Vector2( d.x,-d.y))
	add_vertex(Vector3(vec.x + -d.x, vec.y + d.y,vec.z + -d.z))
	set_uv(Vector2( d.x, d.y))
	add_vertex(Vector3(vec.x + -d.x, vec.y + d.y,vec.z +  d.z))
	set_uv(Vector2(-d.x,-d.y))
	add_vertex(Vector3(vec.x + -d.x,vec.y + -d.y,vec.z + -d.z))
	set_uv(Vector2(-d.x, d.y))
	add_vertex(Vector3(vec.x + -d.x,vec.y + -d.y,vec.z +  d.z))
	set_uv(Vector2(-d.x,-d.y))
	add_vertex(Vector3(vec.x + -d.x,vec.y + -d.y,vec.z + -d.z))
	set_uv(Vector2( d.x, d.y))
	add_vertex(Vector3(vec.x + -d.x, vec.y + d.y,vec.z +  d.z))
	
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
