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
extends Node
#warning-ignore-all:unused_argument

var plugin
var control

var processing_time_measure = 0
var processing_time_start = 0

var process_stat = false
var stats = {}
var last_stats
var _stats_need_update = false

signal stats_updated

func _ready():
	# the singleton is now ready
	# lets find the plugin and complete the initialisation
	var c = get_tree().get_nodes_in_group("___dzPortalsPlugin___")
	if c.size() == 1:
		plugin = c[0]
		plugin.init()
	else:
		printerr("cannot find dzPortalsPlugin")
	reset_stats()


func set_stat(name,value):
	if last_stats[name] != value:
		_stats_need_update = true
	stats[name] = value

func inc_stat(name,value):
	_stats_need_update = true
	stats[name] += value

func get_stat(name):
	return stats[name] 


func reset_stats():
	stats = {
		"visible_zones": 0,
		"gates_processed": 0,
		"clipped_polys": 0,
		"processing_time": 0
	}

func _process(delta):
	last_stats = stats.duplicate()
	_stats_need_update = false
	
	reset_stats()

	
	var start = OS.get_ticks_msec()

	
	get_tree().call_group_flags(SceneTree.GROUP_CALL_REALTIME,"dzPortalsAreas","do_prepare")
	get_tree().call_group_flags(SceneTree.GROUP_CALL_REALTIME,"dzPortalsGates","do_prepare")
	get_tree().call_group_flags(SceneTree.GROUP_CALL_REALTIME,"dzPortalsZones","do_prepare")
	
	get_tree().call_group_flags(SceneTree.GROUP_CALL_REALTIME,"dzPortalsAreas","do_portal")
	get_tree().call_group_flags(SceneTree.GROUP_CALL_REALTIME,"dzPortalsGates","do_portal")
	get_tree().call_group_flags(SceneTree.GROUP_CALL_REALTIME,"dzPortalsZones","do_portal")
	
	processing_time_measure += OS.get_ticks_msec() - start 
	
	if process_stat:
		if processing_time_start + 1000 < OS.get_ticks_msec():
			processing_time_start = OS.get_ticks_msec()
			set_stat("processing_time", processing_time_measure / 1000)
			processing_time_measure = 0
		
		get_tree().call_group_flags(SceneTree.GROUP_CALL_REALTIME,"dzPortalsAreas","do_inspector")
		get_tree().call_group_flags(SceneTree.GROUP_CALL_REALTIME,"dzPortalsGates","do_inspector")
		get_tree().call_group_flags(SceneTree.GROUP_CALL_REALTIME,"dzPortalsZones","do_inspector")
		
		if _stats_need_update:
			emit_signal("stats_updated")


func get_nearest_gate( vec ):
	return
	var lowest = 9999999999999
	var lowestNode = null
	var nodes = get_tree().get_nodes_in_group("dzPortalsGates")
	for node in nodes:
		if node.get_class() == "dzPortalsGate":
			var d = node.global_transform.origin.distance_to(vec)
			if d < lowest:
				lowest = d
				lowestNode = node
	return lowestNode

