shader_type spatial;
render_mode diffuse_toon, specular_toon;

//const float threshold = 0.01;
//const vec2 threshold_array[4] = { vec2(0.0, threshold), vec2(0.0, -threshold), vec2(-threshold, 0.0), vec2(threshold, 0.0) };
//
//uniform sampler2D screen_texture : hint_screen_texture;

void vertex() {
	// Called for every vertex the material is visible on.
}

//bool is_border(sampler2D TEXTURE2, vec2 uv){
    //
    //for(int i = 0; i < 4; i++){
        //vec4 threshold_color = texture(TEXTURE2, uv + threshold_array[i]);   
        //if(threshold_color.a <= 1.0){
            //return true;
        //} 
        //continue;
    //}
    //return false;
//}

void fragment() {
    METALLIC = 0.0;
    ROUGHNESS = 0.5;
    ALBEDO = vec3(0.1, 0.3, 0.5);
}

//void light() {
//	// Called for every pixel for every light affecting the material.
//	// Uncomment to replace the default light processing function with this one.
//}
