shader_type canvas_item;

uniform sampler2D map;

vec3 set_square(vec2 uv, float offset_x, float offset_y, vec3 color) {
	if (uv.x >= 0.1 + offset_x * 0.018 && uv.x <= 0.118 + offset_x * 0.018 && uv.y >= 0.1 + offset_y * 0.018 && uv.y <= 0.118 + offset_y * 0.018)
	{
		if (textureLod(map, vec2(offset_x, offset_y), 0.).x < 0.2){
			return vec3(0.25, 0.5, 0.5);
		}
	}
	else {return color;}
}

vec3 test(vec2 uv, float offset_x, float offset_y, vec3 color) {
	return textureLod(map, vec2(offset_x, offset_y), 0.).rgb;
}

void fragment() {
	if (UV.x >= 0.1 && UV.x <= 0.9 && UV.y >= 0.1 && UV.y <= 0.9)
	{
		COLOR.rgb = vec3(0.2);
		for(float i = 0.; i < 52.; i++){
			for(float j = 0.; j < 22.; j++){
				COLOR.rgb = test(UV, i, j, COLOR.rgb);
			}
		}
	}
}

//void light() {
//	// Called for every pixel for every light affecting the CanvasItem.
//	// Uncomment to replace the default light processing function with this one.
//}
