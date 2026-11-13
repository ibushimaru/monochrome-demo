shader_type canvas_item;
uniform float pose_index=0.0;
varying vec4 tint;
void vertex(){tint=COLOR;}
void fragment(){
 // One drawn pose at a time: no ghosted hands from crossfading.
 vec2 uv=vec2((clamp(UV.x,.002,.998)+clamp(pose_index,0.0,2.0))/3.0,UV.y);
 COLOR=texture(TEXTURE,uv)*tint;
}
