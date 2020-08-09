tool
extends EditorPlugin

func _enter_tree():
	# Initialization of the plugin goes here
	# Add the new type with a name, a parent type, a script and an icon
	add_autoload_singleton ( "dzPortals", "res://addons/dzPortals/scripts/dzPortals.gd" )
	add_custom_type("dzPortalsArea", "ImmediateGeometry", preload("scripts/dzPortalsArea.gd"), preload("icons/gate.svg"))
	add_custom_type("dzPortalsZone", "Position3D", preload("scripts/dzPortalsZone.gd"), preload("icons/gate.svg"))
	add_custom_type("dzPortalsGate", "ImmediateGeometry", preload("scripts/dzPortalsGate.gd"), preload("icons/gate.svg"))
	add_custom_type("dzPortalsCamera", "Camera", preload("scripts/dzPortalsCamera.gd"), preload("icons/gate.svg"))

func _exit_tree():
	# Clean-up of the plugin goes here
	# Always remember to remove it from the engine when deactivated
	remove_custom_type("dzPortalsArea")
	remove_custom_type("dzPortalsZone")
	remove_custom_type("dzPortalsGate")
	remove_custom_type("dzPortalsCamera")
	remove_autoload_singleton ("dzPortals")
