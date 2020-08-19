tool
extends EditorPlugin

var dzPortalsControl

const dzPortalsArea = preload("scripts/dzPortalsArea.gd")
const dzPortalsZone = preload("scripts/dzPortalsZone.gd")
const dzPortalsGate = preload("scripts/dzPortalsGate.gd")

func _enter_tree():
	# Initialization of the plugin goes here
	# Add the new type with a name, a parent type, a script and an icon
	add_autoload_singleton ( "dzPortals", "res://addons/dzPortals/scripts/dzPortals.gd" )

	add_custom_type("dzPortalsArea", "ImmediateGeometry", dzPortalsArea, preload("icons/gate.svg"))
	add_custom_type("dzPortalsZone", "Position3D", dzPortalsZone, preload("icons/gate.svg"))
	add_custom_type("dzPortalsGate", "ImmediateGeometry", dzPortalsGate, preload("icons/gate.svg"))
	
	dzPortalsControl = preload("controls/dzPortalsControl.tscn").instance()
	
	add_control_to_bottom_panel(dzPortalsControl, "dzPortals")
	dzPortalsControl.init()
	dzPortals.control = dzPortalsControl
	dzPortals.plugin = self


func _exit_tree():
	# Clean-up of the plugin goes here
	# Always remember to remove it from the engine when deactivated
	remove_custom_type("dzPortalsArea")
	remove_custom_type("dzPortalsZone")
	remove_custom_type("dzPortalsGate")
	remove_autoload_singleton ("dzPortals")
	remove_control_from_bottom_panel(dzPortalsControl)
	dzPortalsControl.queue_free()
