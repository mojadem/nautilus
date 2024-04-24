@tool
extends Node
class_name HighlightComponent

const HIGHLIGHT = preload("res://game/components/highlight/highlight.tres")

@export var mesh: MeshInstance3D
@export var enabled: bool = false: set = _on_set_enabled

func _on_set_enabled(value: bool) -> void:
	if not mesh:
		return

	enabled = value

	var num_materials := mesh.get_surface_override_material_count()
	for i in range(num_materials):
		var material := mesh.get_active_material(i)

		if enabled:
			var shader = HIGHLIGHT
			material.next_pass = shader
		else:
			material.next_pass = null
