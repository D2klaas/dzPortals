tool
extends Position3D
#warning-ignore-all:unused_argument

export var _blackList = [] setget _set_blackList
var blackList = []

var _gates = []

var _is_active = false
var _is_processed = false
var _is_visible = false
var _is_visible_last_time = false

var _is_inside_last_time = false

var _polycount = 0
var _viewportSprite
var _whiteList

signal area_entered
signal area_exited
signal area_shown
signal area_hidden

export(bool) var disabled = false setget _set_disabled

func get_class():
	return "dzPortalsZone"

func _init():
	_blackList = []

func _ready():
	if Engine.editor_hint:
		set_notify_transform ( true )
		_add_viewport_sprite()
	add_to_group("dzPortalsZones")
	register_blackList( )


func _add_viewport_sprite():
	if _viewportSprite:
		return
	_viewportSprite = Sprite3D.new()
	_viewportSprite.pixel_size = 0.0004
	_viewportSprite.offset.y = 100
	_viewportSprite.cast_shadow = false
	_viewportSprite.material_override = load("res://addons/dzPortals/materials/iconZone.material")
	_viewportSprite.texture = _viewportSprite.material_override.albedo_texture
	add_child(_viewportSprite)


func _notification( what ):
	if what == Spatial.NOTIFICATION_TRANSFORM_CHANGED:
		for gate in _gates:
			gate.redraw()

#---------------------------------- processing
func _process( delta ):
	if not Engine.editor_hint:
		visible = _is_visible
	if _is_visible != _is_visible_last_time:
		if _is_visible:
			emit_signal("area_shown")
		else:
			emit_signal("area_hidden")
	_is_visible_last_time = _is_visible

func do_prepare():
	_is_processed = false
	_is_active = false
	_set_visible( false )


func do_portal():
	if disabled:
		return
	if _is_active:
		_set_visible( true )
		if not _is_inside_last_time:
			emit_signal("area_entered")
		_is_inside_last_time = true
		for blackZone in blackList:
			blackZone._is_active = false
			blackZone._is_visible = false
			blackZone._is_processed = true
		do_portal_gates()
	else:
		if _is_inside_last_time:
			emit_signal("area_exited")
		_is_inside_last_time = false


func do_inspector():
	if _is_visible:
		dzPortals.visible_zones += 1
	else:
		dzPortals.clipped_polys += _polycount

func do_portal_gates():
	if _is_processed:
		return
	
	_is_processed = true
	
	if _is_visible:
		for gate in _gates:
			dzPortals.gates_processed += 1
			
			if gate._is_visible( self ):
				gate.get_other_zone(self)._set_visible( true )
				gate.get_other_zone(self).do_portal_gates()

#------------------------------- gates
func add_gate( new_gate ):
	if new_gate.get_class() != "dzPortalsGate":
		return
	if _gates.find(new_gate) > -1:
		return
	_gates.append(new_gate)


func remove_gate( gate ):
	var id = _gates.find(gate)
	if id > -1:
		_gates.remove(id)


#----------------------------------- disabled
func _set_disabled(value):
	disabled = value

#------------------------------- setter
func _set_visible( value ):
	if _is_processed:
		return
	_is_visible = value

#------------------------------- tools
func _auto_blacklist():
	_whiteList = []
	for gate in _gates:
		var z = gate.get_other_zone(self)
		if z:
			var pathList = [self]
			pathList.append(gate)
			z.__auto_blacklist(pathList)

func __auto_blacklist( pathList ):
#	__print_array(pathList)
	
	var firstGate = pathList[1]
	var lastGate = pathList[pathList.size()-1]
	var firstZone = pathList[0]
	if pathList.size() > 5:
		#get all in between gates
		var betweenGates = []
		for gate in pathList:
			if gate != firstGate and gate != lastGate and gate.get_class() == "dzPortalsGate":
				betweenGates.append(gate)
#		print_debug("gates between:")
#		__print_array(betweenGates)
#		print_debug("angle to "+self.name+" through "+lastGate.name)
		
		for gate in betweenGates:
#			print_debug("-----Testing gate "+gate.name)
			var plane = gate.get_red_plane()
			var iPoints = []
			for firstGatePointId in range(4):
				for lastGatePointId in range(4):
					var p1 = firstGate.get_global_corner(firstGatePointId)
					var p2 = lastGate.get_global_corner(lastGatePointId)
					var point = plane.intersects_segment(p1,p2)
					if point:
						iPoints.append( gate.to_local(point) )
			
			if _is_points_inside_gate(gate,iPoints):
				firstZone.remove_blackList( self )
				firstZone.add_whiteList( self )
			else:
				if firstZone._whiteList.find(self) == -1:
					firstZone.add_blackList( self )
	#				print_debug(firstZone.name+" cannot see "+name+" through "+gate.name+" between "+gate.get_red_zone().name+" and "+gate.get_blue_zone().name)
					return
			
			
#		var startPlane = firstGate.get_zone_averted_plane(pathList[0])
#		var nowPLane = lastGate.get_zone_facing_plane(self)
#
#		var angle = startPlane.normal.angle_to(nowPLane.normal)
#		print_debug("angle: "+str(angle * (180/PI)))
	
	pathList.append(self)
	for gate in _gates:
		var z = gate.get_other_zone(self)
		if z:
			if pathList.find(z) != -1:
				#cyclic path, abort
				continue
			
			var _pathList = pathList.slice(0,pathList.size()-1)
			_pathList.append(gate)
			z.__auto_blacklist(_pathList)


func _is_points_inside_gate( gate, iPoints ):
		#are all aside?
	var d = gate.dimensions / 2.0
	var negative = false
	for point in iPoints:
		if point.x < d.x:
			negative = true
			break
	if not negative:
		#all points are left
#		print("all points are left")
		return false

	negative = false
	for point in iPoints:
		if point.x > -d.x:
			negative = true
			break
	if not negative:
		#all points are right
#		print("all points are right")
		return false

	negative = false
	for point in iPoints:
		if point.y < d.y:
			negative = true
			break
	if not negative:
		#all points are right
#		print("all points are higher")
		return false

	negative = false
	for point in iPoints:
		if point.y > -d.y:
			negative = true
			break
	if not negative:
		#all points are right
#		print("all points are lower")
		return false
	
	return true

func __print_array(array):
	var c = 0
	var p = ""
	for a in array:
		if c > 0:
			p += " -> "
		p += a.name
		c += 1
	print(p)

#-------------------- black/white list
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

func add_blackList( zone ):
	var nodePath = get_path_to(zone)
	if _blackList.find(nodePath) != -1:
		return
	_blackList.append(nodePath)
	register_blackList( )
	property_list_changed_notify()


func remove_blackList( zone ):
	var nodePath = get_path_to(zone)
	_blackList.erase(nodePath)
	register_blackList( )
	property_list_changed_notify()


func add_whiteList( zone ):
	var nodePath = get_path_to(zone)
	if _whiteList.find(nodePath) != -1:
		return
	_whiteList.append(nodePath)
