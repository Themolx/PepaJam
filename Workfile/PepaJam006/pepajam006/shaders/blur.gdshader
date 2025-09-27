shader_type canvas_item;

uniform sampler2D SCREEN_TEXTURE: hint_screen_texture, filter_linear_mipmap;
uniform float blur_amount : hint_range(0.0, 5.0) = 1.0;

void fragment() {
	vec2 blur_size = blur_amount / SCREEN_PIXEL_SIZE;
	
	vec4 color = vec4(0.0);
	
	// Simple box blur
	for(int x = -2; x <= 2; x++) {
		for(int y = -2; y <= 2; y++) {
			vec2 offset = vec2(float(x), float(y)) * blur_size / 25.0;
			color += texture(SCREEN_TEXTURE, SCREEN_UV + offset);
		}
	}
	
	COLOR = color / 25.0;
}
