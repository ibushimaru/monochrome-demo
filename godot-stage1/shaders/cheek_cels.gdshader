shader_type canvas_item;
uniform float frame_position=0.0;
varying vec4 tint;
void vertex(){tint=COLOR;}
void fragment(){
 float first=mod(floor(frame_position),6.0);
 float second=mod(first+1.0,6.0);
 vec2 cell_a=vec2(mod(first,3.0),floor(first/3.0));
 vec2 cell_b=vec2(mod(second,3.0),floor(second/3.0));
 vec2 uv=clamp(UV,vec2(.002),vec2(.998));
 vec4 a=texture(TEXTURE,(uv+cell_a)/vec2(3.0,2.0));
 vec4 b=texture(TEXTURE,(uv+cell_b)/vec2(3.0,2.0));
 float blend=smoothstep(.25,.9,fract(frame_position));
 float alpha=mix(a.a,b.a,blend);
 vec3 rgb=mix(a.rgb*a.a,b.rgb*b.a,blend)/max(alpha,.0001);
 COLOR=vec4(rgb,alpha)*tint;
}
