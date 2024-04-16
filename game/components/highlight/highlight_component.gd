@tool
extends Node3D
class_name HighlightComponent

const HIGHLIGHT_MESH = preload("res://game/components/highlight/highlight_mesh.tres")

@export var parent_mesh: MeshInstance3D

@export var highlight_enabled: bool = false:
	set(value):
		if not parent_mesh:
			return
		
		var material: Material = parent_mesh.get_active_material(0)
		if not material:
			return
		
		highlight_enabled = value
		
		if value:
			var shader = HIGHLIGHT_MESH.duplicate()
			material.next_pass = shader
		else:
			material.next_pass = null
