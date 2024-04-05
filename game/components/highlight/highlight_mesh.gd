@tool
extends MeshInstance3D

class_name HighlightMesh

const HIGHLIGHT_MESH = preload("res://game/components/highlight/highlight_mesh.tres")

@export var highlight_enabled: bool = false:
	set(value):
		highlight_enabled = value
		
		if value:
			var shader = HIGHLIGHT_MESH.duplicate()
			get_active_material(0).next_pass = shader
		else:
			get_active_material(0).next_pass = null
