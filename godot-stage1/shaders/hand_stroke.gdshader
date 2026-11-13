shader_type canvas_item;
uniform float curl : hint_range(0.0, 1.0) = 0.0;
varying vec4 vertex_tint;
void vertex() { vertex_tint=COLOR; }
void fragment() {
 vec2 uv=UV;
 // Bend only the finger section; keep the palm and wrist registered.
 if (uv.y<0.56) {
  uv.y=0.56+(uv.y-0.56)/(1.0-0.12*curl);
 }
 vec4 sample_color=texture(TEXTURE,uv);
 if (uv.y<0.0 || uv.y>1.0) sample_color.a=0.0;
 COLOR=sample_color*vertex_tint;
}
