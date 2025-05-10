shader_type canvas_item;

uniform float purple_team : hint_range(0.0, 1.0);
uniform float green_team : hint_range(0.0, 1.0) = 1.0;

void vertex() {
	// Called for every vertex the material is visible on.
}

void fragment() {
	if (UV.x < purple_team && COLOR.b > 0.2)
	{
		COLOR = vec4(COLOR.r, 0, COLOR.b, COLOR.a);
	}
	if (UV.x > green_team && COLOR.b > 0.2)
	{
		COLOR = vec4(0, COLOR.g, 0, COLOR.a);
	}
}

//void light() {
//	// Called for every pixel for every light affecting the CanvasItem.
//	// Uncomment to replace the default light processing function with this one.
//}
