@tool
extends Node3D

@export var mesh: MeshInstance3D

@export_enum("Happy", "Sad", "Angry", "Surprised") var expression: int:
	set(value):
		if not mesh:
			return
		
		expression = value
		var offset: float = float(value) / 4.0
		var material: BaseMaterial3D = mesh.get_surface_override_material(1)
		material.uv1_offset = Vector3(offset, 0, 0)
