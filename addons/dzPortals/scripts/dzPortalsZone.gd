tool
extends Position3D
#warning-ignore-all:unused_argument


var _gates = []

var _is_active = false
var _is_processed = false
var _is_visible = false

var _is_inside_last_time = false

signal area_entered
signal area_exited


func get_class():
	return "dzPortalsZone"

func _ready():
	add_to_group("dzPortalsZones")

#---------------------------------- processing
func _process( delta ):
	if not Engine.editor_hint:
		visible = _is_visible

func do_prepare():
	_is_processed = false
	_is_active = false
	_set_visible( false )


func do_portal():
	if _is_active:
		_set_visible( true )
		if not _is_inside_last_time:
			emit_signal("area_entered")
		_is_inside_last_time = true
		do_portal_gates()
	else:
		if _is_inside_last_time:
			emit_signal("area_exited")
		_is_inside_last_time = false


func do_camera():
	if _is_visible:
		dzPortals.visible_zones += 1


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


#------------------------------- setter
func _set_visible( value ):
	if _is_processed:
		return
	_is_visible = value


