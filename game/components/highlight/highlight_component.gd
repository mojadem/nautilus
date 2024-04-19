@tool
extends Node
class_name HighlightComponent

@export var highlight: ShaderMaterial
@export var parent_mesh: MeshInstance3D

@export var enabled: bool = false: set = _on_set_enabled

func _on_set_enabled(value: bool) -> void:
	if not parent_mesh:
		return

	enabled = value

	var num_materials := parent_mesh.get_surface_override_material_count()
	for i in range(num_materials):
		var material := parent_mesh.get_active_material(i)

		if enabled:
			var shader = highlight
			material.next_pass = shader
		else:
			material.next_pass = null
