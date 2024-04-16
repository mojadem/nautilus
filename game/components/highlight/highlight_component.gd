@tool
extends Node3D
class_name HighlightComponent

const HIGHLIGHT_MESH = preload("res://game/components/highlight/highlight_mesh.tres")

@export var parent_mesh: MeshInstance3D

@export var highlight_enabled: bool = false:
	set(value):
		if not parent_mesh:
			return
		
		highlight_enabled = value
		
		var num_materials := parent_mesh.get_surface_override_material_count()
		for i in range(num_materials):
			var material := parent_mesh.get_active_material(i)
			
			if highlight_enabled:
				var shader = HIGHLIGHT_MESH.duplicate()
				material.next_pass = shader
			else:
				material.next_pass = null
