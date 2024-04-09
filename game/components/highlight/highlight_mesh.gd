@tool
extends MeshInstance3D

class_name HighlightMesh

const HIGHLIGHT_MESH = preload("res://game/components/highlight/highlight_mesh.tres")

@export var highlight_enabled: bool = false:
	set(value):
		var material: Material = get_active_material(0)
		if not material:
			return
		
		highlight_enabled = value
		
		if value:
			var shader = HIGHLIGHT_MESH.duplicate()
			material.next_pass = shader
		else:
			material.next_pass = null
