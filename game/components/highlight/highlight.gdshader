shader_type spatial;
render_mode unshaded, depth_draw_never;

void fragment( )
{
	ALBEDO = vec3(1.0, 1.0, 1.0);
	ALPHA = -cos(TIME * 2.0) / 4.0 + 0.25;
}