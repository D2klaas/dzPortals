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
extends EditorPlugin

var dzPortalsControl
var dzPortalsArea
var dzPortalsZone
var dzPortalsGate

func _enter_tree():
	add_to_group("___dzPortalsPlugin___")
	add_autoload_singleton( "dzPortals", "res://addons/dzPortals/scripts/dzPortals.gd" )

func init():
	# Initialization of the plugin goes here
	# Add the new type with a name, a parent type, a script and an icon
	
	dzPortalsArea = load("res://addons/dzPortals/scripts/dzPortalsArea.gd")
	dzPortalsZone = load("res://addons/dzPortals/scripts/dzPortalsZone.gd")
	dzPortalsGate = load("res://addons/dzPortals/scripts/dzPortalsGate.gd")
	
	add_custom_type("dzPortalsArea", "ImmediateGeometry", dzPortalsArea, preload("icons/gate.svg"))
	add_custom_type("dzPortalsZone", "Position3D", dzPortalsZone, preload("icons/gate.svg"))
	add_custom_type("dzPortalsGate", "ImmediateGeometry", dzPortalsGate, preload("icons/gate.svg"))
	
	dzPortalsControl = load("res://addons/dzPortals/controls/dzPortalsControl.tscn").instance()
	
	add_control_to_bottom_panel(dzPortalsControl, "dzPortals")
	dzPortalsControl.init()


func _exit_tree():
	# Clean-up of the plugin goes here
	# Always remember to remove it from the engine when deactivated
	remove_custom_type("dzPortalsArea")
	remove_custom_type("dzPortalsZone")
	remove_custom_type("dzPortalsGate")
	remove_control_from_bottom_panel(dzPortalsControl)
	remove_autoload_singleton ("dzPortals")
