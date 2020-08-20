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
extends Control
#warning-ignore-all:unused_argument

var StatsList
var polycount:float = 0


func init():
	dzPortals.connect("stats_updated",self,"update")
	dzPortals.process_stat = true
	if not StatsList:
		StatsList = find_node("StatsList",true,false)
		StatsList.clear()
		StatsList.add_item("visible zones ")
		StatsList.add_item("0")
		StatsList.add_item("gates processed ")
		StatsList.add_item("0")
		StatsList.add_item("clipped polys ")
		StatsList.add_item("0")
		StatsList.add_item("processing time ")
		StatsList.add_item("0")
	pass


func _on_RefreshPolycountButton_pressed():
	var root = get_tree().get_edited_scene_root()
	polycount = count_poly(root)
	update()


func count_poly( root ):
	var count = 0
	if root.get_class() == "MeshInstance" and root.mesh:
		count = root.mesh.get_faces().size() / 3
	for child in root.get_children():
		count += count_poly( child )
	if root.get_class() == "dzPortalsZone":
		root._polycount = count
	return count


func update():
	if StatsList:
		StatsList.set_item_text(1,str(dzPortals.get_stat("visible_zones")))
		StatsList.set_item_text(3,str(dzPortals.get_stat("gates_processed")))
		if polycount:
			StatsList.set_item_text(5,str(dzPortals.get_stat("clipped_polys"))+" / "+str(round(dzPortals.get_stat("clipped_polys") / polycount * 100))+" %")
		else:
			StatsList.set_item_text(5,"-")
		StatsList.set_item_text(7,str(dzPortals.get_stat("processing_time"))+" msec")


func _set_owner_recursive(node,owner):
	node.owner = owner
	for child in node.get_children():
		_set_owner_recursive(child,owner)


func _add_child_deferred(node,child):
	var owner = child.owner
	if child.get_parent():
		child.get_parent().remove_child(child)
	node.add_child(child)
	child.owner = owner
	
#	node.owner = null
#	var editor = child.get_node("/root/EditorNode")
#
#	_set_owner_recursive(child,node)
#	node.get_tree().get_root().print_tree_pretty ( )
#	editor.set_edited_scene(node)


func _on_CreateZones_pressed():
	var nodes = dzPortals.plugin.get_editor_interface().get_selection().get_selected_nodes()
	for node in nodes:
		createZone( node )

func createZone( node ):
	var parent = node.get_parent()
	var _owner = node.owner
	if not _owner:
		#dont know how to make root
		printerr("Cannot make zone to scene root. Create a new scene root. Create the zone. Then make the zone the new scene root.")
		return
	var zone = dzPortals.plugin.dzPortalsZone.new()
	var name = node.name+"Zone"
	zone.name = name
	zone.connect("ready",self,"_add_child_deferred",[zone,node],CONNECT_ONESHOT )
	zone.translation = node.translation
	parent.add_child(zone)
	zone.owner = _owner
	node.translation = Vector3.ZERO
	return zone


func _on_CreateAreas_pressed():
	var nodes = dzPortals.plugin.get_editor_interface().get_selection().get_selected_nodes()
	for node in nodes:
		createArea( node )


func createArea( node ):
	var area = dzPortals.plugin.dzPortalsArea.new()
	var name = node.name+"Area"
	area.name = name
	if node.owner:
		area.connect("ready",area,"set_owner",[node.owner],CONNECT_ONESHOT )
	else:
		area.connect("ready",area,"set_owner",[node],CONNECT_ONESHOT )
	node.add_child(area)
	area.translation = Vector3.ZERO
	area.assign_to_parent()

	if node.get_class() == "dzPortalsZone":
		area.resize_to_zone()
	if node.get_class() == "MeshInstance":
		area.resize_to_mesh(node)


func _on_CreateZonesAndAreas_pressed():
	var zones = []
	var nodes = dzPortals.plugin.get_editor_interface().get_selection().get_selected_nodes()
	for node in nodes:
		zones.append( createZone( node ))
	
	for node in zones:
		createArea( node )


func _on_ConnectMagneticGates_pressed():
	var nodes
	if _onlyOnSelected():
		nodes = dzPortals.plugin.get_editor_interface().get_selection().get_selected_nodes()
	else:
		nodes = get_tree().get_nodes_in_group("dzPortalsGates")
	for node in nodes:
		if node.get_class() == "dzPortalsGate":
			node.auto_find_magnetic_gate()


func _on_AutoDetectZones_pressed():
	var nodes
	if _onlyOnSelected():
		nodes = dzPortals.plugin.get_editor_interface().get_selection().get_selected_nodes()
	else:
		nodes = get_tree().get_nodes_in_group("dzPortalsGates")
	for node in nodes:
		if node.get_class() == "dzPortalsGate":
			node.auto_connect_zones()


func _on_HideAreas_toggled(button_pressed):
	var mat = load("res://addons/dzPortals/materials/area.material")
	if button_pressed:
		mat.params_use_alpha_scissor = true
		mat.params_alpha_scissor_threshold = 1
	else:
		mat.params_use_alpha_scissor = false


func _on_HideGates_toggled(button_pressed):
	var mat = load("res://addons/dzPortals/materials/gate.material")
	if button_pressed:
		mat.params_use_alpha_scissor = true
		mat.params_alpha_scissor_threshold = 1
	else:
		mat.params_use_alpha_scissor = false


func _on_AutoBlacklist_pressed():
	var nodes
	if _onlyOnSelected():
		nodes = dzPortals.plugin.get_editor_interface().get_selection().get_selected_nodes()
	else:
		nodes = get_tree().get_nodes_in_group("dzPortalsZones")
	for node in nodes:
		if node.get_class() == "dzPortalsZone":
			node.auto_blacklist()


func _on_ClearZoneBlacklists_pressed():
	var nodes
	if _onlyOnSelected():
		nodes = dzPortals.plugin.get_editor_interface().get_selection().get_selected_nodes()
	else:
		nodes = get_tree().get_nodes_in_group("dzPortalsZones")
	for node in nodes:
		if node.get_class() == "dzPortalsZone":
			node._set_blackList( [] )
			node.property_list_changed_notify()


func _on_AsignToParent_pressed():
	var nodes
	if _onlyOnSelected():
		nodes = dzPortals.plugin.get_editor_interface().get_selection().get_selected_nodes()
	else:
		nodes = get_tree().get_nodes_in_group("dzPortalsAreas")
	for node in nodes:
		if node.get_class() == "dzPortalsArea":
			node.assign_to_parent()


func _on_ResizeToZone_pressed():
	var nodes
	if _onlyOnSelected():
		nodes = dzPortals.plugin.get_editor_interface().get_selection().get_selected_nodes()
	else:
		nodes = get_tree().get_nodes_in_group("dzPortalsAreas")
	for node in nodes:
		if node.get_class() == "dzPortalsArea":
			node.resize_to_zone()


func _onlyOnSelected():
	return find_node("onlyOnSelectedNodes").pressed
	
