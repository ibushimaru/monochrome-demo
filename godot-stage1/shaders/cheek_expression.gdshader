shader_type canvas_item;
uniform sampler2D relaxed_face : source_color;
uniform sampler2D closed_face : source_color;
uniform float comfort=0.0;
uniform float closed=0.0;
varying vec4 tint;
void vertex(){tint=COLOR;}
void fragment(){
 vec4 original=texture(TEXTURE,UV);
 vec4 expression=mix(texture(relaxed_face,UV),texture(closed_face,UV),closed);
 // Only facial features change. Hair, head outline and body remain the original art.
 vec2 edge=min(UV-vec2(.375,.096),vec2(.615,.173)-UV);
 float mask=smoothstep(0.0,.009,edge.x)*smoothstep(0.0,.005,edge.y);
 COLOR=mix(original,expression,comfort*mask)*tint;
}
