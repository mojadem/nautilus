@tool
extends XRToolsPickable
class_name WhiskeyGlass

@export var shader: ShaderMaterial

@export_range(0, 1) var fill_percent: float = 1.0:
	set(value):
		if not shader:
			return

		fill_percent = value
		var fill := calculate_fill(fill_percent)
		shader.set_shader_parameter("fill_amount", fill)


func calculate_fill(percent: float) -> float:
	return 0.48 + percent * 0.04
